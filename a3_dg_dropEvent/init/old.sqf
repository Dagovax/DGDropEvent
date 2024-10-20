
			// _MPEventHandlersIndeces = _targetPlayer getVariable "_mpEventHandlerIndeces";
			// if (isNil "_MPEventHandlersIndeces") then 
			// {
				// _MPEventHandlersIndeces = []; // if it's null we need to create a new event handler.
			// };
			// if(count _MPEventHandlersIndeces < 1) then
			// {
				// _indexMP = _targetPlayer addMPEventHandler ["MPKILLED",  
				// {
					// _this spawn
					// {
						// params ["_unit", "_killer", "_instigator"];
						// if (isNull _killer || {isNull _instigator}) exitWith {};
						// diag_log format["%1 %2 killed %3! Is he part of the enemy AI group?", DGDE_MessageName, _instigator, name _unit];
						// _enemyAIArray = _unit getVariable "_enemyAIArray";
						// if (isNil "_enemyAIArray") exitWith {};
						// _MPEventHandlersIndeces = _unit getVariable "_mpEventHandlerIndeces";
						// if (isNil "_MPEventHandlersIndeces") exitWith {};
						// if(_instigator in _enemyAIArray) then
						// {
							// diag_log format["%1 Paratrooper %2 killed %3! Sending message to the clients now.", DGDE_MessageName, name _instigator, name _unit];
							// // ETA Toaster
							// [
								// "toastRequest",
								// [
									// "InfoEmpty",
									// [
										// format
										// [
											// "<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'> got killed by the enemy paratrooper %8! FeelsBadMan</t>",
											// DGDE_ExileToasts_Title_Size,
											// DGDE_ExileToasts_Title_Font,
											// DGDE_MissionTitle,
											// DGDE_ExileToasts_Message_Color,
											// DGDE_ExileToasts_Message_Size,
											// DGDE_ExileToasts_Message_Font,
											// name _unit,
											// name _instigator
										// ]
									// ]
								// ]
							// ] call ExileServer_system_network_send_broadcast;
						// };
						// {
							// diag_log format["%1 Removing the added MPKilled EventHandler from player %2 at index %3", DGDE_MessageName, name _unit, _x];
							// _unit removeMPEventHandler ["MPKilled", _x];
							// _MPEventHandlersIndeces deleteAt (_MPEventHandlersIndeces find _x); // Remove AI from alive array
							// _unit setVariable ["_mpEventHandlerIndeces", _MPEventHandlersIndeces];
						// } forEach _MPEventHandlersIndeces;
					// };
				// }];
				// _MPEventHandlersIndeces pushBack _indexMP; // Add new event handler to the index array
				// _targetPlayer setVariable ["_mpEventHandlerIndeces", _MPEventHandlersIndeces];
			// };

			
			// Event handler for reaching the first waypoint
			_pilotGroup addEventHandler ["WaypointComplete", {
				_this spawn
				{
					params ["_group", "_waypointIndex"];
					_waypointPosition = waypointPosition [_group,_waypointIndex];
					_aircraftObject = _group getVariable "_aircraftObjectAssigned";
					_goodOrBad = _group getVariable "_goodBad";
					_targetPlayer = _group getVariable "_targetPlayer";
					if (isNil "_aircraftObject") exitWith 
					{
						diag_log format["%1 ERROR: The vehicle of group %2 reached a waypoint, but has no vehicle assigned as variable!", DGDE_MessageName, _group];
					};
					if (isNil "_targetPlayer") exitWith 
					{
						diag_log format["%1 ERROR: The vehicle of group %2 reached a waypoint, but the target player left!!", DGDE_MessageName, _group];
					};
					_aircraftName = getText (configFile >> "CfgVehicles" >> (typeOf _aircraftObject) >> "displayName");
					diag_log format["%1 The %2 reached waypoint %3 @ %4", DGDE_MessageName, _aircraftName, _waypointIndex, _waypointPosition];
					if(_waypointIndex == 1) then // Only when reaching first waypoint.. Duh
					{
						diag_log format["%1 The %2 reached %3. Dropping cargo now...", DGDE_MessageName, _aircraftName, name _targetPlayer];
						//_aircraftObject fire "CMFlareLauncher";
						_flrObj = "F_20mm_Red" createvehicle ((_aircraftObject) modelToWorld [-5,-5,10]); _flrObj setVelocity [0,0,-65];
						_flrObj = "F_20mm_Red" createvehicle ((_aircraftObject) modelToWorld [5,-5,10]); _flrObj setVelocity [0,0,-65];
						_flrObj = "F_20mm_Red" createvehicle ((_aircraftObject) modelToWorld [-5,5,10]); _flrObj setVelocity [0,0,-65];
						_flrObj = "F_20mm_Red" createvehicle ((_aircraftObject) modelToWorld [5,5,10]); _flrObj setVelocity [0,0,-65];
						
						_dropInfantry = false;
						if(DGDE_EnableVehicleDrop) then
						{
							_dropObject = _group getVariable "_dropObjectAssigned";
							if (isNil "_dropObject") then // Spawn infantry.. No vehicle
							{
								_dropInfantry = true;
							} 
							else  // We have a vehicle! Don't spawn infantry...
							{
								[
									"toastRequest",
									[
										"InfoEmpty",
										[
											format
											[
												"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'>, check the sky and claim or sell the delivered %8!</t>",
												DGDE_ExileToasts_Title_Size,
												DGDE_ExileToasts_Title_Font,
												DGDE_MissionTitle,
												DGDE_ExileToasts_Message_Color,
												DGDE_ExileToasts_Message_Size,
												DGDE_ExileToasts_Message_Font,
												name _targetPlayer,
												getText (configFile >> "CfgVehicles" >> (typeOf _dropObject) >> "displayName")
											]
										]
									]
								] call ExileServer_system_network_send_broadcast;
								_dropInfantry = false;
								detach _dropObject; // detach hehe
								WaitUntil {(((position _dropObject) select 2) < (DGDE_FlyHeight-20))};
								_objectPosDrop = position _dropObject;
								_para = createVehicle ["B_Parachute_02_F", _objectPosDrop, [], 0, ""];
								_dropObject attachTo [_para,[0,0,-1.5]];
								WaitUntil {((((position _dropObject) select 2) < 3) || (isNil "_para"))};
								detach _dropObject;
								_dropObject allowDamage true;
							};
						} else
						{
							_dropInfantry = true;
						};
						
						helpedArray pushBack name _targetPlayer; // Add this player to the already 'helped' array...
						
						// Drop infantry
						if(_dropInfantry) then
						{
							_playerExperience = _targetPlayer getVariable ["ExileScore", 0]; // 5000; // GET EXILE PLAYER EXPERIENCE
							if (isNil "_playerExperience") then // Spawn infantry.. No vehicle
							{
								_playerExperience = 10000; // Default
							};
							_skillList = DGDE_AIEasySettings;
							if((_playerExperience < (DGDE_ExperienceRange select 0))) then // EASY 
							{
								_skillList = DGDE_AIEasySettings;
							};
							if((_playerExperience >= (DGDE_ExperienceRange select 0)) && (_playerExperience < (DGDE_ExperienceRange select 1))) then // NORMAL 
							{
								_skillList = DGDE_AINormalSettings;
							};
							if((_playerExperience >= (DGDE_ExperienceRange select 1)) && (_playerExperience < (DGDE_ExperienceRange select 2))) then // HARD 
							{
								_skillList = DGDE_AIHardSettings;
							};
							if((_playerExperience >= (DGDE_ExperienceRange select 2))) then // EXTREME 
							{
								_skillList = DGDE_AIExtremeSettings;
							};
							_troopCount = ((_skillList select 1) call BIS_fnc_randomInt);
							_squadGroup = null;
							_spawnClass = selectRandom DGDE_AIFriendlyTypes;
							if(_goodOrBad) then 
							{
								_squadGroup = group _targetPlayer; 
								if (isNil "_squadGroup") then
								{
									_spawnClass = selectRandom DGDE_AIEnemyTypes;
									diag_log format["%1 Created a new paratrooper group with side EAST!", DGDE_MessageName];
									_squadGroup = createGroup east; // We need a group!
								} else
								{
									diag_log format["%1 Adding paratroopers to group %2!", DGDE_MessageName, group _targetPlayer];
								};
							}
							else
							{
								_spawnClass =selectRandom DGDE_AIEnemyTypes;
								diag_log format["%1 Created a new paratrooper group with side EAST!", DGDE_MessageName];
								_squadGroup = createGroup east;
							};
							
							if (isNil "_squadGroup") exitWith {}; // Should be something now
							_squadGroup setVariable ["DMS_AllowFreezing",false];
							_squadGroup setVariable ["DMS_LockLocality",false];
							_squadGroup setVariable ["DMS_SpawnedGroup",true];
							_squadGroup setVariable ["DMS_Group_Side", east];     
							// Spawn units and give them parachutes
							for "_i" from 1 to _troopCount do 
							{ 
								_aircraftPos = position _aircraftObject;
								_unitPos = [(_aircraftPos select 0), (_aircraftPos select 1), (_aircraftPos select 2) - 10];
								_unitVest = selectRandom DGDE_AIVests;
								_skillLevel = _skillList select 0;
								_inventoryItems = _skillList select 2; // Instadoc and foot etc.
								_money = ceil(random((_skillList select 3)));
								_unit = _squadGroup createUnit [_spawnClass, _unitPos, [], 0, "FORM"];
								if(!_goodOrBad) then 
								{
									_enemyArray = _targetPlayer getVariable "_enemyAIArray";
									if (isNil "_enemyArray") then 
									{
										_enemyArray = []; // if it's null we need to create a new array.
									};
									_enemyArray pushBack _unit; // Add this unit to the enemy AI array...
									_targetPlayer setVariable ["_enemyAIArray", _enemyArray];
								} else
								{
									_alliesCount = _targetPlayer getVariable "_alliesCount";
									if (alive _unit) then
									{
										if (isNil "_alliesCount") then 
										{
											_alliesCount = 1;
										} else {
											_alliesCount = _alliesCount + 1;
										};
										_targetPlayer setVariable ["_alliesCount", _alliesCount]; // Ally counter
									};
								};
								removeAllWeapons _unit;
								removeBackpack _unit;
								_unit addBackpack "B_Parachute"; // First parachute lol
								_unit setVariable ["_targetPlayer", _targetPlayer];
								_unit setVariable ["_goodBad", _goodOrBad];
								_unit addMPEventHandler ["MPKILLED",  
								{
									_this spawn
									{
										params ["_unit", "_killer", "_instigator"];
										if (isNull _killer || {isNull _instigator}) exitWith {};
										_targetPlayer = _unit getVariable "_targetPlayer";
										if (isNil "_targetPlayer") exitWith {};
										_goodOrBad = _unit getVariable "_goodBad";
										if (isNil "_goodOrBad") exitWith {};
										if (!_goodOrBad) then
										{
											_enemyArray = _targetPlayer getVariable "_enemyAIArray";
											if (isNil "_enemyArray") exitWith {}; 
											if (DGDE_DebugMode) then
											{
												diag_log format["%1 Unit %2 from side %3 got himself killed. _enemyAIArray = %4. _targetPlayer = %5", DGDE_MessageName, _unit, side _unit, _enemyArray, _targetPlayer];
											};
											_enemyArray deleteAt (_enemyArray find _unit); // Remove AI from alive array
											_targetPlayer setVariable ["_enemyAIArray", _enemyArray];
											_msg = format[
												"%1 killed %2 with %3 at %4 meters!",
												name _instigator, 
												name _unit, 
												getText(configFile >> "CfgWeapons" >> currentWeapon _instigator >> "displayName"), 
												_unit distance _instigator
											];
											[_msg] remoteExec["systemChat",-2];
										}
										else
										{
											_alliesCount = _targetPlayer getVariable "_alliesCount";
											if (isNil "_alliesCount") exitWith {};
											if (DGDE_DebugMode) then
											{
												diag_log format["%1 Unit %2 from side %3 got himself killed. _alliesCount = %4. _targetPlayer = %5", DGDE_MessageName, _unit, side _unit, _alliesCount, _targetPlayer];
											};
											_alliesCount = _alliesCount - 1;
											_targetPlayer setVariable ["_alliesCount", _alliesCount]; // Ally counter
											_msg = format[
												"%1 lost group member %2! Only %3 group member(s) left!",
												name _targetPlayer, 
												name _unit, 
												_alliesCount
											];
											[_msg] remoteExec["systemChat",-2];
										};
									};
								}];
								_unit setVariable ["ExileMoney",_money ,true]; // Add some money
								_unit forceAddUniform selectRandom DGDE_SkinList;
								_unit addHeadgear selectRandom DGDE_HeadgearList;
								_unit setskill ["aimingAccuracy",_skillLevel];
								_unit setskill ["aimingShake",_skillLevel];
								_unit setskill ["aimingSpeed",_skillLevel];
								_unit setskill ["spotDistance",_skillLevel];
								_unit setskill ["spotTime",_skillLevel];
								_unit setskill ["courage",_skillLevel];
								_unit setskill ["reloadSpeed",_skillLevel];
								_unit setskill ["commanding",_skillLevel];
								_unit setskill ["general",_skillLevel];
								_unit setCombatMode "RED";
								for "_i" from 1 to _inventoryItems do
								{
									_invItem = (selectRandom DGDE_AIItems);
									if(DGDE_DebugMode) then
									{
										diag_log format["%1 Added a %2 to unit %3!", DGDE_MessageName, _invItem, _unit];
									};
									_unit addItem _invItem;
								};
								_unit enableAI "TARGET";
								_unit enableAI "AUTOTARGET";
								_unit enableAI "MOVE";
								_unit enableAI "ANIM";
								//_unit disableAI "TEAMSWITCH";
								_unit enableAI "FSM";
								_unit enableAI "AIMINGERROR";
								_unit enableAI "SUPPRESSION";
								_unit enableAI "CHECKVISIBLE";
								_unit enableAI "COVER";
								_unit enableAI "AUTOCOMBAT";
								_unit enableAI "PATH";
							};
							
							if(!_goodOrBad) then
							{
								[
									"toastRequest",
									[
										"InfoEmpty",
										[
											format
											[
												"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'>, watch out for the enemy paratroopers! They are hunting you.</t>",
												DGDE_ExileToasts_Title_Size,
												DGDE_ExileToasts_Title_Font,
												DGDE_MissionTitle,
												DGDE_ExileToasts_Message_Color,
												DGDE_ExileToasts_Message_Size,
												DGDE_ExileToasts_Message_Font,
												name _targetPlayer
											]
										]
									]
								] call ExileServer_system_network_send_broadcast;
							} 
							else
							{
								[
									"toastRequest",
									[
										"InfoEmpty",
										[
											format
											[
												"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'>, you received %8 friendly paratroopers! You are their commander now until you die.</t>",
												DGDE_ExileToasts_Title_Size,
												DGDE_ExileToasts_Title_Font,
												DGDE_MissionTitle,
												DGDE_ExileToasts_Message_Color,
												DGDE_ExileToasts_Message_Size,
												DGDE_ExileToasts_Message_Font,
												name _targetPlayer,
												_troopCount
											]
										]
									]
								] call ExileServer_system_network_send_broadcast;
							};
							
							// Deploy parachutes and wait until they touch the ground
							{
							  _x spawn {   
								params ["_trooper"];
								if (local _trooper) then {
									//waituntil {sleep 0.5; isNull objectParent _trooper && getPosAtl _trooper select 2 > 30 && (getPosAtl _trooper select 2 < 150 or isPlayer _trooper)};
									//_trooper addBackpackGlobal "B_Parachute"; // First parachute lol
									waitUntil {isTouchingGround _trooper};
									uisleep 1;
									if (alive _trooper) then
									{
										removeBackpack _trooper;
										_backpack = (selectRandom DGDE_Backpacks);
										_trooper addBackpackGlobal _backpack; // Add random backpack
										_unitWeapon = selectRandom DGDE_AIWeapons;
										_percentageLauncher = floor random 100;
										_ammo = _unitWeapon call DGDropEvent_fnc_selectMagazine;
										for "_i" from 1 to 3 do 
										{ 
											_trooper addMagazineGlobal _ammo;
										};
										_trooper addWeaponGlobal _unitWeapon;
										_trooper addPrimaryWeaponItem selectRandom DGDE_AIWeaponOptics;
										if(DGDE_EnableLaunchers && _percentageLauncher <= DGDE_LauncherChance) then // Add launchers
										{
											_unitLauncher = selectRandom DGDE_AILaunchers;
											_launcherAmmo = _unitLauncher call DGDropEvent_fnc_selectMagazine;
											for "_i" from 1 to 2 do
											{ 
												_trooper addMagazineGlobal _launcherAmmo;
											};
											_trooper addWeaponGlobal _unitLauncher;
										};
										if(DGDE_DebugMode) then
										{
											diag_log format["%1 Paratrooper %2 reached the ground! Adding backpack with weapon and ammo.", DGDE_MessageName, _trooper];
										};
									};
								};
							  };   
							} forEach units _squadGroup;
							if(!_goodOrBad) then // Lead the enemy troops to the player
							{
								_groupLeader = leader _squadGroup;
								if(isNil "_groupLeader" OR !alive _groupLeader) then
								{
									_groupMembers = units _squadGroup;
									_groupLeader = _groupMembers call BIS_fnc_selectRandom;	
									_squadGroup selectLeader _groupLeader;								
								};
								//[_squadGroup, position _targetPlayer, 1000] call bis_fnc_taskPatrol;
								_destination = getPos _targetPlayer;
								_squadGroup reveal[_targetPlayer, 1.5];
								_squadGroup move _destination;	
							} 
							else
							{
								_groupLeader = leader _squadGroup;
								if(isNil "_groupLeader" OR !alive _groupLeader) then
								{
									_groupMembers = units _squadGroup;
									{
										if (_x isKindOf "Exile_Unit_Player") exitWith
										{
											_squadGroup selectLeader _x;
										};
									} forEach _groupMembers;		
								};
							};
							_squadGroup allowFleeing 0;
							_squadGroup setBehaviour "COMBAT";
							_squadGroup setCombatBehaviour "COMBAT";
							_squadGroup setCombatMode "RED";
							diag_log format["%1 Spawned %2 paratroopers with AI level %3, because the player experience is %4!", DGDE_MessageName, _troopCount, _skillList select 0, _playerExperience];
							if(!_goodOrBad) then // Add fancy waypoint to the player
							{
								_squadWP = _squadGroup addWaypoint [position _targetPlayer, 0, 1];
								[_squadGroup,1] setWaypointBehaviour "COMBAT";
								[_squadGroup,1] setWaypointCombatMode "RED";
								[_squadGroup, 1] waypointAttachVehicle _targetPlayer;
								_squadWP setWaypointType "SAD";
								While {true} do { // Let the enemy squad hunt the player
									uiSleep 1;
									if (!alive _targetPlayer) exitWith 
									{
										diag_log format["%1 Cleaning up AI of group %2, because %3 got himself killed! (perhaps these AI were too strong after all...)", DGDE_MessageName, _squadGroup, name _targetPlayer];
										{_x setDamage 1;} forEach units _squadGroup;
									};
									_squadWP setWaypointPosition [position _targetPlayer, 0];
								};
							} else {
								While {true} do { // Let the enemy squad hunt the player
									uiSleep 1;
									if (!alive _targetPlayer) exitWith 
									{
										diag_log format["%1 Cleaning up AI of group %2, because %3 got himself killed!", DGDE_MessageName, _squadGroup, name _targetPlayer];
										{_x setDamage 1;} forEach units _squadGroup;
									};
								};
							};
						};			
					};
					if(_waypointIndex == 2) then // Clear stuff
					{
						diag_log format["%1 The %2 reached its end. Cleaning up the aircraft.", DGDE_MessageName, _aircraftName];
						deleteVehicleCrew _aircraftObject;
						deleteVehicle _aircraftObject;
						deleteGroup _group;
					};
				};
			}];
			
			While {true} do { // Wait until heli reaches the correct waypoint (or dies)
				uiSleep 0.5;
				if (!alive _pilotCrew || !alive _aircraftObject) exitWith {}; // If the aircraft crashed somehow...
				if (currentWaypoint _pilotGroup >= 2) exitWith
				{
					diag_log format["%1 The pilot of the %2 reached %3, initializing next spawn.", DGDE_MessageName, _aircraftName, _targetPlayerName];
					//deleteWaypoint [_pilotGroup, 1];
				}; 
				
				_wp0 setWaypointPosition [position _targetPlayer, 0];
			};
			
			//Wait for next cycle
			reInitialize = true;
			_nextWaitTime =  (DGDE_TMin) + random((DGDE_TMax) - (DGDE_TMin)); // + diag_tickTime
			diag_log format["%1 Waiting %2 seconds before next spawn...", DGDE_MessageName, _nextWaitTime];
			uiSleep _nextWaitTime; // Wait until the random counter started
		} else 
		{ // No more players online, so nobody to select from. Disbanding...
			// Sleep until first spawn
			reInitialize = true;
			_nextWaitTime =  (DGDE_TMin) + random((DGDE_TMax) - (DGDE_TMin)); // + diag_tickTime
			diag_log format["%1 Disbanding Airdrop event... No more players online", DGDE_MessageName];
			diag_log format["%1 Waiting %2 seconds before next spawn...", DGDE_MessageName, _nextWaitTime];
			uiSleep _nextWaitTime; // Wait until the random counter started
		};
	};
	uiSleep 10;
	diag_log text format ["%1 Waiting for %2 players to be online.",DGDE_MessageName, DGDE_Min_Online_Players];
	waitUntil { uiSleep DGDE_TPlayerCheck; count( playableUnits ) > ( DGDE_Min_Online_Players - 1 ) };
};