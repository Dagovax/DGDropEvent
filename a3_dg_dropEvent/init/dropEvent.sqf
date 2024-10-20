if (!isServer) exitWith {};

if (isNil "DGDE_Configured") then
{
	["%1 Waiting until configuration completes...", "DG Airdrop Event"] call DGCore_fnc_log;
	waitUntil{uiSleep 10; !(isNil "DGDE_Configured")}
};

["Initializing Dagovax Games Airdrop Event", DGDE_MessageName] call DGCore_fnc_log;

/****************************************************************************************************/
/********************************  DO NOT EDIT THE CODE BELOW!!  ************************************/
/****************************************************************************************************/
if(DGDE_DebugMode) then 
{
	["Running in Debug mode!", DGDE_MessageName, "debug"] call DGCore_fnc_log;
	DGDE_Min_WaitTime 	= 30;
	DGDE_TMin			= 10;
	DGDE_TMax			= 60;
	DGDE_ArrivalTime	= 2;
	DGDE_ETATime		= 5;
	DGDE_TPlayerCheck	= 10;
	DGDE_SpawnDistance 	= 2500;
	DGDE_RedrawPlayers	= true;
	DGDE_EnableVehicleDrop = false;
	DGDE_VehicleDropChance	= 50;
	DGDE_JunkCleanupTime = 30;
	DGDE_MaxActiveDrops = 1; //3; // If you want a mess, this is the way forward (setting this high)...
};

if (DGDE_Min_WaitTime > 0) then
{
	[format["Waiting %1 seconds before firing up.", DGDE_Min_WaitTime], DGDE_MessageName, "debug"] call DGCore_fnc_log;
	uiSleep DGDE_Min_WaitTime;
};

if (DGDE_Min_Online_Players > 0) then
{
	[format["Waiting for %1 players to be online.", DGDE_Min_Online_Players], DGDE_MessageName, "debug"] call DGCore_fnc_log;
	waitUntil { uiSleep 10; count( playableUnits ) > ( DGDE_Min_Online_Players - 1 ) };
};
[format["%1 players reached. Starting Dagovax Games' Drop Event!", DGDE_Min_Online_Players], DGDE_MessageName, "debug"] call DGCore_fnc_log;

// Calculate some base stuff
_middle 		= worldSize/2;
DGDE_MapRadius	= _middle;

// Sleep until first spawn
_initialWaitTime =  (DGDE_TMin) + random((DGDE_TMax) - (DGDE_TMin)); // + diag_tickTime
[format["Waiting %1 seconds before first spawn...", _initialWaitTime], DGDE_MessageName, "debug"] call DGCore_fnc_log;
uiSleep _initialWaitTime; // Wait until the random counter started

DGDE_DroppedQueue = [];
DGDE_ActiveQueue = [];

_reInitialize = true; // Only initialize this when _reInitialize is true
while {true} do
{
	if(_reInitialize) then
	{
		_reInitialize = false;
		
		if(count DGDE_ActiveQueue >= DGDE_MaxActiveDrops) exitWith
		{
			[format["There is not enough space in the active queue [%1] for another drop iteration (max %2)", count DGDE_ActiveQueue, DGDE_MaxActiveDrops], DGDE_MessageName, "debug"] call DGCore_fnc_log;
		};
		
		// Check if there are players online
		_allPlayers = call BIS_fnc_listPlayers;
		_playerCount = count(_allPlayers);
		if(_playerCount > 0) then
		{
			if(!DGDE_RedrawPlayers) then
			{
				{
					_onlinePlayer = name _x;
					if(_onlinePlayer in DGDE_DroppedQueue) then
					{
						[format["Player %1 was already dropped this session! Ignoring him/her this time!", _onlinePlayer], DGDE_MessageName, "debug"] call DGCore_fnc_log;
						_allPlayers deleteAt _forEachIndex;
					};
				} forEach _allPlayers;
			};		
			if(count(_allPlayers) < 1) exitWith // Not enough players!
			{
				[format["After checking dropable players, there are not enough online players [%1] left to perform a drop!", count(_allPlayers)], DGDE_MessageName, "warning"] call DGCore_fnc_log;
			};
			
			// Start main drop
			[_allPlayers] spawn
			{
				params ["_allPlayers"];
				_startMsg = format["Radar on %1 report an incoming aircraft, but its intentions are unknown!", worldName];
				
				// Select a random player as target!
				_targetPlayer = selectRandom _allPlayers;
				
				if(DGDE_DebugMode) then
				{
					_targetPlayer allowDamage false; // Makes sure the debugger survives lol
				};
				
				_targetPlayerName = name _targetPlayer;
				DGDE_ActiveQueue pushBack _targetPlayerName;
				// Start Toaster
				[
					"toastRequest",
					[
						"InfoEmpty",
						[
							format
							[
								"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>%7</t>",
								DGDE_ExileToasts_Title_Size,
								DGDE_ExileToasts_Title_Font,
								DGDE_MissionTitle,
								DGDE_ExileToasts_Message_Color,
								DGDE_ExileToasts_Message_Size,
								DGDE_ExileToasts_Message_Font,
								_startMsg
							]
						]
					]
				] call ExileServer_system_network_send_broadcast;
				uiSleep DGDE_ArrivalTime; // Now wait the Arrival time before continueing
				
				if (isNil "_targetPlayer" || isNull _targetPlayer) exitWith 
				{
					[format["After waiting the arrival time of %1 seconds, the _targetPlayer with name %2 does not exist anymore! Skipping air drop.", DGDE_ArrivalTime, _targetPlayerName], DGDE_MessageName, "warning"] call DGCore_fnc_log;
					DGDE_ActiveQueue deleteAt ( DGDE_ActiveQueue find _targetPlayerName );
				}; 
				_targetPosition = getPosATL _targetPlayer;
				_enemyAIArray = _targetPlayer getVariable "_enemyAIArray";
				if (isNil "_enemyAIArray") then 
				{
					_enemyAIArray = []; // if it's null we need to create a new array.
				};
				_targetPlayer setVariable ["_enemyAIArray", _enemyAIArray];
				
				// ETA Toaster
				[
					"toastRequest",
					[
						"InfoEmpty",
						[
							format
							[
								"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>The incoming aircraft seems to be heading directly to </t><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'>. ETA for reaching the map is %8 seconds!</t>",
								DGDE_ExileToasts_Title_Size,
								DGDE_ExileToasts_Title_Font,
								DGDE_MissionTitle,
								DGDE_ExileToasts_Message_Color,
								DGDE_ExileToasts_Message_Size,
								DGDE_ExileToasts_Message_Font,
								_targetPlayerName,
								DGDE_ETATime
							]
						]
					]
				] call ExileServer_system_network_send_broadcast;
				[format["Aircraft is targeting %1 @ %2! ETA = %3 seconds", _targetPlayerName, _targetPosition, DGDE_ETATime], DGDE_MessageName, "debug"] call DGCore_fnc_log;
				uiSleep DGDE_ETATime; // Now wait the Arrival time before continueing
				if(isNil "_targetPlayer" || isNull _targetPlayer) exitWith 
				{
					[format["After waiting the ETA time of %1 seconds, the _targetPlayer does not exist anymore! Skipping air drop.", DGDE_ETATime], DGDE_MessageName, "warning"] call DGCore_fnc_log;
					DGDE_ActiveQueue deleteAt ( DGDE_ActiveQueue find _targetPlayerName );
				}; // Player could be disconnected after this time
				
				// Set spawn position and orientation
				_heliDirection = random 360;
				_spawnPosition =[(_targetPosition select 0) - (sin _heliDirection) * DGDE_SpawnDistance, (_targetPosition select 1) - (cos _heliDirection) * DGDE_SpawnDistance, (_targetPosition select 2) + DGDE_SpawnHeight];
				_dir = ((_targetPosition select 0) - (_spawnPosition select 0)) atan2 ((_targetPosition select 1) - (_spawnPosition select 1));
				_flyPosition = [(_targetPosition select 0) + (sin _dir) * DGDE_SpawnDistance, (_targetPosition select 1) + (cos _dir) * DGDE_SpawnDistance, (_targetPosition select 2) + DGDE_SpawnHeight];
				_targetPosition set [2, DGDE_FlyHeight];
				_spawnAngle = [_spawnPosition,_targetPosition] call BIS_fnc_dirTo;
				[format["Checking now if event is going to be GOOD or BAD for %1", _targetPlayerName], DGDE_MessageName, "debug"] call DGCore_fnc_log;
				_goodOrBad = switch (floor random 2) do
				{
					case 1: { true; };
					default { false; };
				};
				
				if(DGDE_ForceBad) then
				{
					_goodOrBad = false;
				};
				
				if(_goodOrBad) then
				{
					["The drop will be GOOD!", DGDE_MessageName, "debug"] call DGCore_fnc_log;
				} else
				{
					["The drop will be BAD!", DGDE_MessageName, "debug"] call DGCore_fnc_log;
				};
				
				_groupClass = west; // placeholder!
				_pilotClass = "O_A_soldier_TL_F";	// Set pilot class type
				if(_goodOrBad) then
				{
					_groupClass = independent;
					_pilotClass = selectRandom DGDE_AIFriendlyTypes;
				} else 
				{
					_groupClass = east;
					_pilotClass = selectRandom DGDE_AIEnemyTypes;
				};
				
				_pilotGroup = createGroup _groupClass;
				[format["Created group %1 with side= %2", _pilotGroup, _groupClass], DGDE_MessageName, "debug"] call DGCore_fnc_log;
				_aircraftClass = selectRandom DGDE_Helicopters;
				_isPlane = false;
				if(!_goodOrBad) then
				{
					switch (floor random 2) do
					{
						case 1: { _aircraftClass = selectRandom DGDE_Helicopters; };
						default { _aircraftClass = selectRandom DGDE_Planes; _isPlane = true; };
					};
				};
				
				_aircraftObject = createVehicle [_aircraftClass, _spawnPosition, [], 0, "FLY"];
				_aircraftObject setPosATL (_aircraftObject modelToWorld [0,0,DGDE_SpawnHeight]);
				_aircraftObject setDir _spawnAngle;
				_aircraftObject setVelocity [100 * (sin _spawnAngle), 100 * (cos _spawnAngle), 0];
				_aircraftObject flyInHeight DGDE_FlyHeight;
				_aircraftObject allowCrewInImmobile true; // let AI stay in vehicle
				
				_aircraftName = getText (configFile >> "CfgVehicles" >> (typeOf _aircraftObject) >> "displayName");
				_aircraftMaxSpeed = getNumber (configfile >> "CfgVehicles" >> (typeOf _aircraftObject) >> "maxSpeed");
				[format["Spawned the %1 (%2) @ %3", _aircraftObject, _aircraftName, _spawnPosition], DGDE_MessageName, "debug"] call DGCore_fnc_log;
				
				// Move the pilot in his seat
				_pilotCrew = driver _aircraftObject;
				_pilotCrew = _pilotGroup createUnit [_pilotClass, _spawnPosition, [], 0, "NONE"];
				_pilotCrew moveInDriver _aircraftObject;
				
				if (DGDE_InvinsibleAircraft) then
				{
					_aircraftObject allowDamage false;
					_pilotCrew allowDamage false;
				};

				if (DGDE_IsCaptive) then
				{
					_aircraftObject setCaptive true;  //Let's not let everyone else go after this guy, make him invisible to other Ai
				};
				_pilotGroup setCombatMode "BLUE";
				_pilotGroup setBehaviour "CARELESS";  //Just out for a sunday stroll.
				
				{_x disableAI "AUTOTARGET"; _x disableAI "TARGET"; _x disableAI "FSM"; _x allowfleeing 0;} forEach units _pilotGroup;
			
				_pilotGroup setVariable ["_aircraftObjectAssigned", _aircraftObject];
				_pilotGroup setVariable ["_goodBad", _goodOrBad];
				_pilotGroup setVariable ["_targetPlayer", _targetPlayer];
				// Add the vehicle if enabled (and random percent)
				_percentage = floor random 100;
				_vehicleSpawned = false;
				if(DGDE_EnableVehicleDrop && _goodOrBad && _percentage <= DGDE_VehicleDropChance) then // Chance to spawn vehicle (only if good)
				{
					_objectDropClass = selectRandom DGDE_DropVehicles;
					_objectSpawnPos = [(_spawnPosition select 0), (_spawnPosition select 1), (_spawnPosition select 2) - 10];
					_object = [_objectDropClass, _objectSpawnPos, 0, FALSE] call ExileServer_object_vehicle_createNonPersistentVehicle;
					// Add lock and basic repair stuff to the dropped vehicle.
					_object addItemCargoGlobal ["Exile_Item_JunkMetal", 2];
					_object addItemCargoGlobal ["Exile_Item_DuctTape", 2];
					_object addItemCargoGlobal ["Exile_Item_Wrench", 1];
					_object addItemCargoGlobal ["Exile_Item_Foolbox", 1];
					_object addItemCargoGlobal ["Exile_Item_CodeLock", 1];
					_object addItemCargoGlobal ["Exile_Item_CarWheel", 2];
					_object attachTo [_aircraftObject, [0,0,-15]]; //Attach Object to the aircraft
					_object allowDamage false; //Let's not let these things get destroyed on the way there, shall we?
					_objectName = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "displayName");
					[format ["Spawned a %1 underneath the %2 at %3", _objectName, _aircraftName, position _object], DGDE_MessageName, "debug"] call DGCore_fnc_log;
					_pilotGroup setVariable ["_dropObjectAssigned", _object];
					_pilotGroup setVariable ["_vehicleDropped", false];
					// Friendly Toaster with vehicle
					[
						"toastRequest",
						[
							"InfoEmpty",
							[
								format
								[
									"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>The aircraft heading to </t><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'> is a friendly %8 and is lifting a %9!</t>",
									DGDE_ExileToasts_Title_Size,
									DGDE_ExileToasts_Title_Font,
									DGDE_MissionTitle,
									DGDE_ExileToasts_Message_Color,
									DGDE_ExileToasts_Message_Size,
									DGDE_ExileToasts_Message_Font,
									_targetPlayerName,
									_aircraftName,
									_objectName
								]
							]
						]
					] call ExileServer_system_network_send_broadcast;
					if(!isNil "_object" && !isNull _object) then
					{
						_vehicleSpawned = true;
					};
				} else
				{
					_goodText = "a friendly";
					if(!_goodOrBad) then
					{
						_goodText = "an enemy";
					};
					// ETA Toaster
					[
						"toastRequest",
						[
							"InfoEmpty",
							[
								format
								[
									"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>The aircraft heading to </t><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'> is %8 %9 and will arrive shortly!</t>",
									DGDE_ExileToasts_Title_Size,
									DGDE_ExileToasts_Title_Font,
									DGDE_MissionTitle,
									DGDE_ExileToasts_Message_Color,
									DGDE_ExileToasts_Message_Size,
									DGDE_ExileToasts_Message_Font,
									_targetPlayerName,
									_goodText,
									_aircraftName
								]
							]
						]
					] call ExileServer_system_network_send_broadcast;
				};
			
				// Lets fly this heli to the target right?
				_pilotGroup move _targetPosition;
				
				// Let us now wait and move until the helicopter reached this point!
				_targetReached = false;
				while {alive _aircraftObject} do
				{
					if (isNil "_targetPlayer" || isNull _targetPlayer) exitWith
					{
						[format["Player %1 disconnected or is bugged, because _targetPlayer equals undefined! Cleaning up and stopping this drop now!", _targetPlayerName], DGDE_MessageName, "warning"] call DGCore_fnc_log;
						_targetReached = false;
					};
					_targetPos = getPos _targetPlayer;
					_currPos = getPos _aircraftObject;
					_distance = _aircraftObject distance2D _targetPlayer;
					
					if (_distance <= 750) then
					{
						_aircraftObject flyInHeight 70;
						if(DGDE_LimitSpeed) then
						{
							_aircraftObject limitSpeed (_aircraftMaxSpeed / 3);
						};
					} else
					{
						_aircraftObject flyInHeight DGDE_FlyHeight;
						if(DGDE_LimitSpeed) then
						{
							_aircraftObject limitSpeed (2 * _aircraftMaxSpeed);
						};
					};

					if (_distance <= 150) exitWith 
					{
						_targetReached = true;
					};
					if(!_goodOrBad && _distance <= 220) exitWith // exit if bad drop and in 220m range
					{
						_targetReached = true;
					};
					
					// Use BIS_fnc_dirTo to calculate the direction from the aircraft to the target
					_dir = [_currPos, _targetPos] call BIS_fnc_dirTo;
					
					// Calculate the fly position based on the current distance and DGDE_SpawnDistance
					_flyPosition = [
						(_currPos select 0) + (sin _dir) * (_distance + DGDE_SpawnDistance),
						(_currPos select 1) + (cos _dir) * (_distance + DGDE_SpawnDistance),
						(_currPos select 2) + DGDE_SpawnHeight
					];
					
					if(!_goodOrBad) then
					{
						if(_isPlane) then
						{
							_pilotGroup move _targetPos;
						} else
						{
							_pilotGroup move _flyPosition;
						};

						uiSleep 2;
					} else
					{
						_pilotGroup move _targetPos;
						uiSleep 5;
					};
					
				};
				
				if(!_targetReached) exitWith
				{
					[format["The %1 failed to reach _targetPlayer %2! Cleaning the mess up now!", _aircraftName, _targetPlayerName], DGDE_MessageName, "debug"] call DGCore_fnc_log;
					_aircraftObject flyInHeight 200;
					_aircraftObject move _flyPosition;
					DGDE_ActiveQueue deleteAt ( DGDE_ActiveQueue find _targetPlayerName );
					_vehicleDropped = _pilotGroup getVariable "_vehicleDropped";
					_dropObject = _pilotGroup getVariable "_dropObjectAssigned";
					if(!isNil "_vehicleDropped" && !isNil "_dropObject") then
					{
						if(!_vehicleDropped && !isNull _dropObject) then
						{
							[format["Deleted the %1, because the drop did not reach player %2! _vehicleDropped = %3", _dropObject, _targetPlayerName, _vehicleDropped], DGDE_MessageName, "debug"] call DGCore_fnc_log;
							deleteVehicle _dropObject;
						};
					};
					if(!alive _aircraftObject) then // Already destroyed.
					{
						uiSleep DGDE_JunkCleanupTime;
					} else
					{
						while{not unitReady _aircraftObject} do
						{
							if(!alive _aircraftObject) exitWith
							{
								uiSleep DGDE_JunkCleanupTime;
							};
							uiSleep 5;
						};
					};

					deleteVehicleCrew _aircraftObject;
					deleteGroup _pilotGroup;
					deleteVehicle _aircraftObject;
				};
				
				[format["The %1 reached _targetPlayer %2!", _aircraftName, _targetPlayerName], DGDE_MessageName, "debug"] call DGCore_fnc_log;
				_safeSpot = [getPos _targetPlayer, 2,75,5,0,0.45,0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
				_safeUnload = true;
				if(_safeSpot isEqualTo [0,0,0]) then
				{
					[format["Could not find a valid position for safe drop unloading!. _safeSpot equals %1", _safeSpot], DGDE_MessageName, "debug"] call DGCore_fnc_log;
					_safeUnload = false;
				};
				// _safeUnload = false;
				if(_safeUnload && _goodOrBad) then // Move the heli to safe position, and then hover low!
				{
					_aircraftObject move _safeSpot;					
					
					_canContinue = true;
					while { alive _aircraftObject && not unitReady _aircraftObject } do
					{
						if(isNil "_targetPlayer" || isNull _targetPlayer) exitWith
						{
							[format["Player %1 disconnected before safely dropping the cargo to the ground! Finishing without dropping anything!", _targetPlayerName], DGDE_MessageName, "warning"] call DGCore_fnc_log;
							_canContinue = false;
						};
						if(!alive _targetPlayer) exitWith
						{
							[format["Player %1 died before receiving the cargo!", _targetPlayerName], DGDE_MessageName, "warning"] call DGCore_fnc_log;
							_canContinue = false;
						};
						uiSleep 1;
					};
					if(!_canContinue) exitWith
					{
						[format["Group %1 is unable to continue to move to player %2 (disconnected?), skipping drop and moving to _flyPosition @ %3", _pilotGroup, _targetPlayerName, _flyPosition], DGDE_MessageName, "warning"] call DGCore_fnc_log;
					};			
					
					private _dropObject = _pilotGroup getVariable "_dropObjectAssigned";
					_safeFlyHeight = 3;
					if(_vehicleSpawned) then // If a vehicle is underneath, calculate the flyheight before vehicle drop.
					{	
						if(isNil "_dropObject" || isNull _dropObject) exitWith{};
						_zHeli = (position _aircraftObject) select 2;
						_zObj = (position _dropObject) select 2;
						_safeFlyHeight = _zHeli - _zObj + 3; // fly height for heli with drop.	 	
						if(_safeFlyHeight < 3) then
						{
							[format["We calculated _safeFlyHeight for vehicle drop to be %1 > %2", _safeFlyHeight, 3], DGDE_MessageName, "warning"] call DGCore_fnc_log;
							_safeFlyHeight = 3;
						} else
						{
							[format["We calculated _safeFlyHeight and will be %1", _safeFlyHeight], DGDE_MessageName, "warning"] call DGCore_fnc_log;
						};
					};
					_heliPadPos = [_safeSpot select 0, _safeSpot select 1, _safeFlyHeight];
					_heliPadClass = "Land_HelipadEmpty_F";
					_invisibleHelipad = createVehicle [_heliPadClass, _heliPadPos, [], 0, "CAN_COLLIDE"];
					_aircraftObject land "LAND";
					
					while{alive _aircraftObject} do
					{
						_zATL = position _aircraftObject select 2;
						if (_zATL < (_safeFlyHeight + 3)) exitWith
						{
							[format["Reached safe dropping altitude of %1! Dropping cargo and moving away!", _safeFlyHeight], DGDE_MessageName, "debug"] call DGCore_fnc_log;
							DGDE_DroppedQueue pushBack _targetPlayerName;
						};
						uiSleep 1;
					};
					if(_vehicleSpawned) then // Drop
					{
						detach _dropObject; // detach hehe
						_pilotGroup setVariable ["_vehicleDropped", true];
						[format["Group %1 succesfully dropped the %1 safely to the ground, and will now be going home.", _pilotGroup, _dropObject], DGDE_MessageName, "debug"] call DGCore_fnc_log;
						[
							"toastRequest",
							[
								"InfoEmpty",
								[
									format
									[
										"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'>, succesfully delivered the %8! Claim or sell it before restart!</t>",
										DGDE_ExileToasts_Title_Size,
										DGDE_ExileToasts_Title_Font,
										DGDE_MissionTitle,
										DGDE_ExileToasts_Message_Color,
										DGDE_ExileToasts_Message_Size,
										DGDE_ExileToasts_Message_Font,
										_targetPlayerName,
										getText (configFile >> "CfgVehicles" >> (typeOf _dropObject) >> "displayName")
									]
								]
							]
						] call ExileServer_system_network_send_broadcast;
						
						uiSleep 2;
						_dropObject allowDamage true;
					} else // Drop GOOD infantry
					{
						_aiGroup = [DGCore_playerSide, position _aircraftObject, -1, _targetPlayer] call DGCore_fnc_spawnGroup;
						[
							"toastRequest",
							[
								"InfoEmpty",
								[
									format
									[
										"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'>, you now have a total of %8 friendly paratrooper(s)! You are their commander until you die or disconnect.</t>",
										DGDE_ExileToasts_Title_Size,
										DGDE_ExileToasts_Title_Font,
										DGDE_MissionTitle,
										DGDE_ExileToasts_Message_Color,
										DGDE_ExileToasts_Message_Size,
										DGDE_ExileToasts_Message_Font,
										_targetPlayerName,
										([_aiGroup] call DGCore_fnc_countAI)
									]
								]
							]
						] call ExileServer_system_network_send_broadcast;
					};
					_aircraftObject land "NONE";
					deleteVehicle _invisibleHelipad;
				} else // Just drop the cargo at once
				{
					_dropInfantry = false;
					if(DGDE_EnableVehicleDrop) then
					{
						_dropObject = _pilotGroup getVariable "_dropObjectAssigned";
						if (isNil "_dropObject") then // Spawn infantry.. No vehicle
						{
							_dropInfantry = true;
						} 
						else  // We have a vehicle! Don't spawn infantry...
						{
							_aircraftObject flyInHeight 85;
							WaitUntil {((((position _aircraftObject) select 2) < 95))};
							[format["Group %1 succesfully dropped the %1 with parachute, and will now be going home.", _pilotGroup, _dropObject], DGDE_MessageName, "debug"] call DGCore_fnc_log;
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
											_targetPlayerName,
											getText (configFile >> "CfgVehicles" >> (typeOf _dropObject) >> "displayName")
										]
									]
								]
							] call ExileServer_system_network_send_broadcast;
							_dropInfantry = false;
							detach _dropObject; // detach hehe
							[_dropObject, _pilotGroup] spawn
							{
								params ["_dropObject", "_pilotGroup"];
								_pilotGroup setVariable ["_vehicleDropped", true];
								WaitUntil {(((position _dropObject) select 2) < 70)};
								_objectPosDrop = [(position _dropObject select 0), (position _dropObject select 1), ((position _dropObject select 2)+ 1.5)];
								_para = createVehicle ["B_Parachute_02_F", _objectPosDrop, [], 0, ""];
								_dropObject attachTo [_para,[0,0,-1.5]];
								WaitUntil {((((position _dropObject) select 2) < 3) || (isNil "_para"))};
								detach _dropObject;
								_dropObject allowDamage true;
							};
						};
					} else
					{
						_dropInfantry = true;
					};
					
					if(_dropInfantry) then
					{
						if(_goodOrBad) then
						{
							_allyGroup = [DGCore_playerSide, position _aircraftObject, -1, _targetPlayer] call DGCore_fnc_spawnGroup;
							[
								"toastRequest",
								[
									"InfoEmpty",
									[
										format
										[
											"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'>, you now have a total of %8 friendly paratrooper(s)! You are their commander until you die or disconnect.</t>",
											DGDE_ExileToasts_Title_Size,
											DGDE_ExileToasts_Title_Font,
											DGDE_MissionTitle,
											DGDE_ExileToasts_Message_Color,
											DGDE_ExileToasts_Message_Size,
											DGDE_ExileToasts_Message_Font,
											_targetPlayerName,
											([_allyGroup] call DGCore_fnc_countAI)
										]
									]
								]
							] call ExileServer_system_network_send_broadcast;
						} else
						{
							_enemyGroup = [DGCore_Side, position _aircraftObject, -1, _targetPlayer] call DGCore_fnc_spawnGroup;
							[
								"toastRequest",
								[
									"InfoEmpty",
									[
										format
										[
											"<t color='#ff66ff' size='%1' font='%2'>%3</t><br/><t color='#7EAD35' size='%1' font='%6'>%7</t><t color='%4' size='%5' font='%6'>, watch out for the %8 enemy paratrooper(s)! They are hunting you.</t>",
											DGDE_ExileToasts_Title_Size,
											DGDE_ExileToasts_Title_Font,
											DGDE_MissionTitle,
											DGDE_ExileToasts_Message_Color,
											DGDE_ExileToasts_Message_Size,
											DGDE_ExileToasts_Message_Font,
											_targetPlayerName,
											([_enemyGroup] call DGCore_fnc_countAI)
										]
									]
								]
							] call ExileServer_system_network_send_broadcast;
							_destination = getPos _targetPlayer;
							_enemyGroup move _destination;
						};
					};
				};
				
				_aircraftObject flyInHeight DGDE_FlyHeight;
				_aircraftObject limitSpeed (2 * _aircraftMaxSpeed);
				
				_aircraftObject move _flyPosition;

				DGDE_ActiveQueue deleteAt ( DGDE_ActiveQueue find _targetPlayerName );
				
				if(!alive _aircraftObject) then // Already destroyed.
				{
					uiSleep DGDE_JunkCleanupTime;
				} else
				{
					while{not unitReady _aircraftObject} do
					{
						if(!alive _aircraftObject) exitWith
						{
							uiSleep DGDE_JunkCleanupTime;
						};
						uiSleep 5;
					};
				};
				_dropObject = _pilotGroup getVariable "_dropObjectAssigned";
				_vehicleDropped = _pilotGroup getVariable "_vehicleDropped";
				if(!isNil "_vehicleDropped" && !isNil "_dropObject") then
				{
					if(!_vehicleDropped && !isNull _dropObject) then
					{
						[format["Deleted the %1, because the drop did not reach player %2! _vehicleDropped = %3", _dropObject, _targetPlayerName, _vehicleDropped], DGDE_MessageName, "debug"] call DGCore_fnc_log;
						deleteVehicle _dropObject;
					};
				};

				deleteVehicleCrew _aircraftObject;
				deleteGroup _pilotGroup;
				deleteVehicle _aircraftObject;
			};
		} else
		{
			[format["There are currently not online players [%1] to start this airdrop iteration. Skipping it now.", _playerCount], DGDE_MessageName, "debug"] call DGCore_fnc_log;
		};
	};
	_reInitialize = true;
	[format["List of active queue [%1]: %2", count DGDE_ActiveQueue,DGDE_ActiveQueue], DGDE_MessageName, "debug"] call DGCore_fnc_log;
	[format["List of dropped players [%1]: %2", count DGDE_DroppedQueue,DGDE_DroppedQueue], DGDE_MessageName, "debug"] call DGCore_fnc_log;
	_nextWaitTime =  (DGDE_TMin) + random((DGDE_TMax) - (DGDE_TMin)); // + diag_tickTime
	[format["Waiting %1 seconds for next airdrop event!", _nextWaitTime], DGDE_MessageName, "debug"] call DGCore_fnc_log;
	uiSleep _nextWaitTime;
};