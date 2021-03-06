/*
 * Author: Glowbal
 * Handles the bandage of a patient.
 *
 * Arguments:
 * 0: The target <OBJECT>
 * 1: The impact <NUMBER>
 * 2: Selection part number <NUMBER>
 * 3: Injury index <NUMBER>
 * 4: Injury <ARRAY>
 * 5: Used Bandage type <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

#include "script_component.hpp"

private ["_target", "_impact", "_part", "_injuryIndex", "_injury", "_bandage", "_classID", "_className", "_reopeningChance", "_reopeningMinDelay", "_reopeningMaxDelay", "_config", "_woundTreatmentConfig", "_bandagedWounds", "_exist", "_injuryId", "_existingInjury", "_delay", "_openWounds", "_selectedInjury", "_bandagedInjury"];
_target = _this select 0;
_impact = _this select 1;
_part = _this select 2;
_injuryIndex = _this select 3;
_injury = _this select 4;
_bandage = _this select 5;

_classID = _injury select 1;
_className = GVAR(woundClassNames) select _classID;

// default, just in case..
_reopeningChance = 0.1;
_reopeningMinDelay = 120;
_reopeningMaxDelay = 200;

// Get the default values for the used bandage
_config = (ConfigFile >> "ACE_Medical_Advanced" >> "Treatment" >> "Bandaging");
if (isClass (_config >> _bandage)) then {
    _config = (_config >> _bandage);
    _reopeningChance = getNumber (_config >> "reopeningChance");
    _reopeningMinDelay = getNumber (_config >> "reopeningMinDelay");
    _reopeningMaxDelay = getNumber (_config >> "reopeningMaxDelay") max _reopeningMinDelay;
};

if (isClass (_config >> _className)) then {
    _woundTreatmentConfig = (_config >> _className);
    if (isNumber (_woundTreatmentConfig >> "reopeningChance")) then {
        _reopeningChance = getNumber (_woundTreatmentConfig >> "reopeningChance");
     };
    if (isNumber (_woundTreatmentConfig >> "reopeningMinDelay")) then {
        _reopeningMinDelay = getNumber (_woundTreatmentConfig >> "reopeningMinDelay");
     };
    if (isNumber (_woundTreatmentConfig >> "reopeningMaxDelay")) then {
        _reopeningMaxDelay = getNumber (_woundTreatmentConfig >> "reopeningMaxDelay") max _reopeningMinDelay;
    };
};

_bandagedWounds = _target getvariable [QGVAR(bandagedWounds), []];
_exist = false;
_injuryId = _injury select 0;
_bandagedInjury = [];
{
    if ((_x select 0) == _injuryId) exitwith {
        _exist = true;
        _existingInjury = _x;
        _existingInjury set [3, (_existingInjury select 3) + _impact];
        _bandagedWounds set [_foreachIndex, _existingInjury];

        _bandagedInjury = _existingInjury;
    };
}foreach _bandagedWounds;

if !(_exist) then {
    // [ID, classID, bodypart, percentage treated, bloodloss rate]
    _bandagedInjury = [_injuryId, _injury select 1, _injury select 2, _impact, _injury select 4];
    _bandagedWounds pushback _bandagedInjury;
};

_target setvariable [QGVAR(bandagedWounds), _bandagedWounds, !USE_WOUND_EVENT_SYNC];

if (USE_WOUND_EVENT_SYNC) then {
    // sync _bandagedInjury

};

// Check if we are ever going to reopen this
if (random(1) <= _reopeningChance) then {
    _delay = _reopeningMinDelay + random(_reopeningMaxDelay - _reopeningMinDelay);
    [{
        private ["_target", "_impact", "_part", "_injuryIndex", "_bandage", "_injury", "_openWounds", "_selectedInjury","_bandagedWounds","_exist"];
        _target = _this select 0;
        _impact = _this select 1;
        _part = _this select 2;
        _injuryIndex = _this select 3;
        _injury = _this select 4;

        if (alive _target) then {
            _openWounds = _target getvariable [QGVAR(openWounds), []];
            if ((count _openWounds)-1 < _injuryIndex) exitwith {};
            _selectedInjury = _openWounds select _injuryIndex;
            if (_selectedInjury select 0 == _injury select 0) then { // matching the IDs
                _selectedInjury set [3, (_selectedInjury select 3) + _impact];
                _openWounds set [_injuryIndex, _selectedInjury];
                _target setvariable [QGVAR(openWounds), _openWounds, !USE_WOUND_EVENT_SYNC];
                if (USE_WOUND_EVENT_SYNC) then {
                    ["medical_propagateWound", [_target, _selectedInjury]] call EFUNC(common,globalEvent);
                };
                _bandagedWounds = _target getvariable [QGVAR(bandagedWounds), []];
                _exist = false;
                _injuryId = _injury select 0;
                {
                    if ((_x select 0) == _injuryId) exitwith {
                        _exist = true;
                        _existingInjury = _x;
                        _existingInjury set [3, ((_existingInjury select 3) - _impact) max 0];
                        _bandagedWounds set [_foreachIndex, _existingInjury];
                    };
                }foreach _bandagedWounds;

                if (_exist) then {
                    _target setvariable [QGVAR(bandagedWounds), _bandagedWounds, !USE_WOUND_EVENT_SYNC];
                };
            };
            // Otherwise something went wrong, we we don't reopen them..
        };
    }, [_target, _impact, _part, _injuryIndex, _injury], _delay, 0] call EFUNC(common,waitAndExecute);
};
