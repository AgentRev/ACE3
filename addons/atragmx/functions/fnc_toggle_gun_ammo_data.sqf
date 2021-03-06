/*
 * Author: Ruthberg
 * Toggles the gun ammo data screen on/off
 *
 * Arguments:
 * Apply new data? <NUMBER>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * 1 call ace_atragmx_fnc_toggle_gun_ammo_data
 *
 * Public: No
 */
#include "script_component.hpp"

if (ctrlVisible 12000) then {
    false call FUNC(show_gun_ammo_data);
    true call FUNC(show_main_page);
    
    if (_this == 1) then {
        call FUNC(update_zero_range);
        call FUNC(calculate_target_solution);
    };
} else {
    true call FUNC(show_gun_ammo_data);
    false call FUNC(show_main_page);
};
