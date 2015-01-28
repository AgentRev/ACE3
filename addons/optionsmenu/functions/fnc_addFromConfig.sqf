/**
* fnc_addFromConfig.sqf
* @Descr: N/A
* @Author: PabstMirror
*
* @Arguments: []
* @Return:
* @PublicAPI: false
*/
#include "script_component.hpp"

if (isClass (configFile >> "ACE_Options")) then {
  _countOptions = count (configFile >> "ACE_Options");
  for "_index" from 0 to (_countOptions - 1) do {
    _optionEntry = (configFile >> "ACE_Options") select _index;
    _name = configName _optionEntry;
    _displayName = getText (_optionEntry >> "displayName");
    _description = getText (_optionEntry >> "description");
    _default = getNumber (_optionEntry >> "default");
    _choices = getArray (_optionEntry >> "values");
    if ((count _choices) == 0) then {
      _choices = [(localize "STR_ACE_OptionsMenu_Disabled"), (localize "STR_ACE_OptionsMenu_Enabled")];
    };
    [_name, _displayName, _description, _choices, _default] call FUNC(addClientSideOptions);
  };
};

if (isClass (configFile >> "ACE_Colors")) then {
  _countOptions = count (configFile >> "ACE_Colors");
  for "_index" from 0 to (_countOptions - 1) do {
    _optionEntry = (configFile >> "ACE_Colors") select _index;
    _name = configName _optionEntry;
    _displayName = getText (_optionEntry >> "displayName");
    _description = getText (_optionEntry >> "description");
    _default = getArray (_optionEntry >> "default");
    [_name, _displayName, _description, _default] call FUNC(addClientSideColor);
  };
};