waitUntil {uiSleep 5; !(isNil "DGCore_Initialized")}; // Wait until DGCore was initialized

["Starting DagovaxGames Drop Event"] call DGCore_fnc_log;
execvm "\x\addons\a3_dg_dropEvent\config\DGDE_config.sqf";
execvm "\x\addons\a3_dg_dropEvent\init\dropEvent.sqf";
