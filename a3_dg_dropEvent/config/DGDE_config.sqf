
DGDE_MessageName = "DG Airdrop Event";

if (!isServer) exitWith {
	["Failed to load configuration data, as this code is not being executed by the server!", DGDE_MessageName] call DGCore_fnc_log;
};

["Loading configuration data...", DGDE_MessageName] call DGCore_fnc_log;

/****************************************************************************************************/
/********************************  CONFIG PART. EDIT AS YOU LIKE!!  ************************************/
/****************************************************************************************************/

DGDE_DebugMode			= false; // Only for creator. Leave it on false
DGDE_Min_WaitTime		= 300; // Min amount of seconds for the script to start after server startup
DGDE_TPlayerCheck		= 60; // Amount of seconds for looping and counting online players.
DGDE_Min_Online_Players	= 1; // Mimumum online players for the script to start.
DGDE_MissionTitle		= "Airdrop Event"; // Set the title of this mission.
DGDE_SpawnHeight		= 150;	// Height of the spawned arcraft. Will be good for planes to be high enough
DGDE_FlyHeight			= 75;	// Height of the helicopter flying the stuff in.
DGDE_SpawnDistance		= 4000; // Distance the aircraft will spawn away from the target
DGDE_LimitSpeed			= true; // Limits the speed of the aircraft if inside certain range to 1/3 of its maxSpeed
DGDE_InvinsibleAircraft	= false; // Is the aircraft carrying the cargo invinsible?
DGDE_IsCaptive			= false; // If you enable this, no map marker will be shown and other AI will ignore the aircraft;
DGDE_EnableVehicleDrop	= true; // If disabled, only enemies/allies parachuting down
DGDE_VehicleDropChance	= 50; // Percentage between dropping a vic or spawning a unit group.. 
DGDE_AllowRandomDrop	= true; // Allow random drop on the map, instead of dropping players. Only applies for DGDE_EnableVehicleDrop = true | TODO
DGDE_RandomDropChance	= 25; // Percentage between dropping the vehicle at a random pos on the map  | TODO
DGDE_RedrawPlayers		= true; // If this is set to false (default), players can only get this Airdrop Event once every restart. If set to true, they can be randomly targetted multiple times.
DGDE_MaxActiveDrops		= 2; // The maximum active drops at the same time. If DGDE_RedrawPlayers is set to true, this prevents many drops at the same player. Keep it low for better performance.
DGDE_ForceBad			= false; // If set to true, events will always be of the bad type
DGDE_JunkCleanupTime	= 10 * 60; // Amount of seconds until dead vehicles/bodies will be removed (garbage collector)

// Timers
DGDE_TMin				= 60*10;	// Minimum time in seconds to spawn the request 
DGDE_TMax				= 60*30;	// Maximum time in seconds to spawn the request 
DGDE_ArrivalTime		= 60*2;	// Arrival time before the helicopter's purpose is known
DGDE_ETATime			= 60*2;	// ETA time before the chopper reaches the map (spawning time after arrival time)

// AI Setup
DGDE_EnableLaunchers	= true; // Set to false to have no AI spawned with launchers
DGDE_LauncherChance		= 35; // Percentage of unit being spawned with launcher.
DGDE_ExperienceRange	= [25000, 75000, 150000]; // Range of the player's experience until it reaches next level. [easy > normal, normal > hard, hard > extreme]
DGDE_AIEasySettings		= [0.3, [1,3], 2, 100]; // AI easy general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGDE_AINormalSettings	= [0.5, [2,5], 4, 250]; // AI normal general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGDE_AIHardSettings		= [0.7, [3,6], 7, 500]; // AI hard general level, followed by array containing min - max troops, followed by inventory items | max poptabs
DGDE_AIExtremeSettings	= [0.9, [5,10], 10, 1000]; // AI extreme general level, followed by array containing min - max troops, followed by inventory items | max poptabs

/*Exile Toasts Notification Settings*/
DGDE_ExileToasts_Title_Size		= 25;						// Size for Client Exile Toasts  mission titles.
DGDE_ExileToasts_Title_Font		= "puristaMedium";			// Font for Client Exile Toasts  mission titles.
DGDE_ExileToasts_Message_Color	= "#FFFFFF";				// Exile Toasts color for "ExileToast" client notification type.
DGDE_ExileToasts_Message_Size		= 21; //19;						// Exile Toasts size for "ExileToast" client notification type.
DGDE_ExileToasts_Message_Font		= "PuristaLight";			// Exile Toasts font for "ExileToast" client notification type.
/*Exile Toasts Notification Settings*/

// Plane. Only used for bad AI enemies drop!
DGDE_Planes =
[
	"B_T_VTOL_01_vehicle_F",
	"CUP_B_C130J_Cargo_GB",
	"CUP_B_MV22_USMC",
	"RHS_C130J_Cargo",
	"O_T_VTOL_02_vehicle_dynamicLoadout_F",
	"O_Plane_Fighter_02_F",
	"RHS_C130J"
];

// Helicopter
DGDE_Helicopters =	
[
	"B_Heli_Transport_03_unarmed_F",
	"O_Heli_Transport_04_F",
	"B_Heli_Transport_03_F",
	
	// CUP & RHS
	"CUP_B_CH47F_GB",
	"CUP_B_MH47E_GB",
	"CUP_B_Merlin_HC3_GB",
	"RHS_CH_47F_10",
	"RHS_UH60M",
	"CUP_B_CH53E_VIV_GER",
	"CUP_B_CH53E_GER",
	"CUP_O_MI6T_CHDKZ",
	"CUP_O_MI6T_CSAT_T",
	"CUP_I_Merlin_HC3_PMC_Lux_black",
	"CUP_I_CH47F_RACS"
];


DGDE_DropVehicles =	
[
	"B_Heli_Light_01_dynamicLoadout_F",
	"I_MRAP_03_F",
	"B_T_APC_Tracked_01_CRV_F",
	"B_G_Offroad_01_AT_F",
	"O_G_Offroad_01_armed_F",
	
	// CUP, RHS & other mods.
	"CUP_B_M1030_USA",
	"CUP_B_CH47F_GB",
	"CUP_O_BRDM2_CSAT",
	"CUP_O_T55_CSAT",
	"CUP_B_Mastiff_HMG_GB_W",
	"pook_2S34_OPFOR",
	"rhs_tigr_sts_vdv",
	"rhs_gaz66_repair_vv",
	"pook_CAESAR_BLUFOR",
	"CUP_B_MCV80_GB_W",
	"CUP_B_M113A3_olive_USA",
	"CUP_B_Ural_ZU23_CDF",
	"CUP_O_UH1H_armed_SLA"
];
DGDE_AIFriendlyTypes = 
[
	"Exile_Guard_01",
	"Exile_Guard_02",
	"Exile_Guard_03"					
];
DGDE_AIEnemyTypes = 
[
	"O_A_soldier_F"
];
DGDE_AIWeapons =
[
	"arifle_Katiba_F",
	"arifle_Katiba_C_F",
	"arifle_Katiba_GL_F",
	"arifle_MXC_F",
	"arifle_MX_F",
	"arifle_MX_GL_F",
	"arifle_MXM_F",
	"arifle_SDAR_F",
	"arifle_TRG21_F",
	"arifle_TRG20_F",
	"arifle_TRG21_GL_F",
	"arifle_Mk20_F",
	"arifle_Mk20C_F",
	"arifle_Mk20_GL_F",
	"arifle_Mk20_plain_F",
	"arifle_Mk20C_plain_F",
	"arifle_Mk20_GL_plain_F",
	"srifle_EBR_F",
	"srifle_GM6_F",
	"srifle_LRR_F",
	"srifle_DMR_01_F",
	"MMG_02_sand_F",
	"MMG_02_black_F",
	"MMG_02_camo_F",
	"MMG_01_hex_F",
	"MMG_01_tan_F",
	"srifle_DMR_05_blk_F",
	"srifle_DMR_05_hex_F",
	"srifle_DMR_05_tan_F",
	
	// CUP, RHS & Other mods
	"CUP_srifle_M107_Desert",
	"CUP_srifle_M107_Pristine",
	"CUP_srifle_M107_Snow",
	"CUP_srifle_M107_Woodland"
];
DGDE_AILaunchers = 
[
	"launch_RPG7_F",
	"launch_B_Titan_tna_F",
	"launch_B_Titan_F",
	"launch_O_Titan_short_F",
	"launch_B_Titan_short_F",
	"launch_RPG32_F",
	
	// CUP, RHS & Other mods
	"rhs_weap_igla",
	"CUP_launch_Javelin",
	"CUP_launch_NLAW",
	"CUP_launch_APILAS",
	"CUP_launch_M47"
];
DGDE_AIWeaponOptics	=
[
	"bipod_01_F_snd",
	"bipod_02_F_blk",
	"optic_LRPS",
	"optic_LRPS_tna_F",
	"optic_LRPS_ghex_F",
	"optic_Nightstalker",
	"optic_DMS",
	"optic_tws",
	"optic_tws_mg",
	"optic_AMS",
	"optic_AMS_khk",
	"optic_AMS_snd",
	"optic_DMS",
	"optic_KHS_blk",
	"optic_KHS_hex",
	"optic_KHS_old",
	"optic_KHS_tan",
	"optic_LRPS",
	"optic_Nightstalker",
	"optic_NVS",
	"optic_SOS",
	"optic_tws"
];
						
DGDE_AIVests =
[
	"V_Press_F",
	"V_Rangemaster_belt",
	"V_TacVest_blk",
	"V_TacVest_blk_POLICE",
	"V_TacVest_brn",
	"V_TacVest_camo",
	"V_TacVest_khk",
	"V_TacVest_oli",
	"V_TacVestCamo_khk",
	"V_TacVestIR_blk",
	"V_I_G_resistanceLeader_F",
	"V_BandollierB_blk",
	"V_BandollierB_cbr",
	"V_BandollierB_khk",
	"V_BandollierB_oli",
	"V_BandollierB_rgr",
	"V_Chestrig_blk",
	"V_Chestrig_khk",
	"V_Chestrig_oli",
	"V_Chestrig_rgr",
	"V_HarnessO_brn",
	"V_HarnessO_gry",
	"V_HarnessOGL_brn",
	"V_HarnessOGL_gry",
	"V_HarnessOSpec_brn",
	"V_HarnessOSpec_gry",
	"V_PlateCarrier1_blk",
	"V_PlateCarrier1_rgr",
	"V_PlateCarrier2_rgr",
	"V_PlateCarrier3_rgr",
	"V_PlateCarrierGL_blk",
	"V_PlateCarrierGL_mtp",
	"V_PlateCarrierGL_rgr",
	"V_PlateCarrierH_CTRG",
	"V_PlateCarrierIA1_dgtl",
	"V_PlateCarrierIA2_dgtl",
	"V_PlateCarrierIAGL_dgtl",
	"V_PlateCarrierIAGL_oli",
	"V_PlateCarrierL_CTRG",
	"V_PlateCarrierSpec_blk",
	"V_PlateCarrierSpec_mtp"
];
DGDE_Backpacks =
[
	"B_Carryall_ocamo",
	"B_Carryall_oucamo",
	"B_Carryall_mcamo",
	"B_Carryall_oli",
	"B_Carryall_khk",
	"B_Carryall_cbr"
];
DGDE_Headgear = 
[
	"H_Cap_blk",
	"H_Cap_blk_Raven",
	"H_Cap_blu",
	"H_Cap_brn_SPECOPS",
	"H_Cap_grn",
	"H_Cap_headphones",
	"H_Cap_khaki_specops_UK",
	"H_Cap_oli",
	"H_Cap_press",
	"H_Cap_red",
	"H_Cap_tan",
	"H_Cap_tan_specops_US",
	"H_Watchcap_blk",
	"H_Watchcap_camo",
	"H_Watchcap_khk",
	"H_Watchcap_sgg",
	"H_MilCap_blue",
	"H_MilCap_dgtl",
	"H_MilCap_mcamo",
	"H_MilCap_ocamo",
	"H_MilCap_oucamo",
	"H_MilCap_rucamo",
	"H_Bandanna_camo",
	"H_Bandanna_cbr",
	"H_Bandanna_gry",
	"H_Bandanna_khk",
	"H_Bandanna_khk_hs",
	"H_Bandanna_mcamo",
	"H_Bandanna_sgg",
	"H_Bandanna_surfer",
	"H_Booniehat_dgtl",
	"H_Booniehat_dirty",
	"H_Booniehat_grn",
	"H_Booniehat_indp",
	"H_Booniehat_khk",
	"H_Booniehat_khk_hs",
	"H_Booniehat_mcamo",
	"H_Booniehat_tan",
	"H_Hat_blue",
	"H_Hat_brown",
	"H_Hat_camo",
	"H_Hat_checker",
	"H_Hat_grey",
	"H_Hat_tan",
	"H_StrawHat",
	"H_StrawHat_dark",
	"H_Beret_02",
	"H_Beret_blk",
	"H_Beret_blk_POLICE",
	"H_Beret_brn_SF",
	"H_Beret_Colonel",
	"H_Beret_grn",
	"H_Beret_grn_SF",
	"H_Beret_ocamo",
	"H_Beret_red",
	"H_Shemag_khk",
	"H_Shemag_olive",
	"H_Shemag_olive_hs",
	"H_Shemag_tan",
	"H_ShemagOpen_khk",
	"H_ShemagOpen_tan",
	"H_TurbanO_blk",
	"H_CrewHelmetHeli_B",
	"H_CrewHelmetHeli_I",
	"H_CrewHelmetHeli_O",
	"H_HelmetCrew_I",
	"H_HelmetCrew_B",
	"H_HelmetCrew_O",
	"H_PilotHelmetHeli_B",
	"H_PilotHelmetHeli_I",
	"H_PilotHelmetHeli_O"	
];
DGDE_Helmets = 
[
	"H_HelmetB",
	"H_HelmetB_black",
	"H_HelmetB_camo",
	"H_HelmetB_desert",
	"H_HelmetB_grass",
	"H_HelmetB_light",
	"H_HelmetB_light_black",
	"H_HelmetB_light_desert",
	"H_HelmetB_light_grass",
	"H_HelmetB_light_sand",
	"H_HelmetB_light_snakeskin",
	"H_HelmetB_paint",
	"H_HelmetB_plain_blk",
	"H_HelmetB_sand",
	"H_HelmetB_snakeskin",
	"H_HelmetCrew_B",
	"H_HelmetCrew_I",
	"H_HelmetCrew_O",
	"H_HelmetIA",
	"H_HelmetIA_camo",
	"H_HelmetIA_net",
	"H_HelmetLeaderO_ocamo",
	"H_HelmetLeaderO_oucamo",
	"H_HelmetO_ocamo",
	"H_HelmetO_oucamo",
	"H_HelmetSpecB",
	"H_HelmetSpecB_blk",
	"H_HelmetSpecB_paint1",
	"H_HelmetSpecB_paint2",
	"H_HelmetSpecO_blk",
	"H_HelmetSpecO_ocamo",
	"H_CrewHelmetHeli_B",
	"H_CrewHelmetHeli_I",
	"H_CrewHelmetHeli_O",
	"H_HelmetCrew_I",
	"H_HelmetCrew_B",
	"H_HelmetCrew_O",
	"H_PilotHelmetHeli_B",
	"H_PilotHelmetHeli_I",
	"H_PilotHelmetHeli_O",
	"H_Helmet_Skate",
	"H_HelmetB_TI_tna_F",
	"H_HelmetB_tna_F",
	"H_HelmetB_Enh_tna_F",
	"H_HelmetB_Light_tna_F",
	"H_HelmetSpecO_ghex_F",
	"H_HelmetLeaderO_ghex_F",
	"H_HelmetO_ghex_F",
	"H_HelmetCrew_O_ghex_F"		
];
DGDE_HeadgearList = DGDE_Headgear + DGDE_Helmets;

DGDE_AIItems = 
[
	"Exile_Item_InstaDoc",
	"Exile_Item_BBQSandwich",
	"Exile_Item_BeefParts",
	"Exile_Item_Catfood",
	"Exile_Item_Cheathas",
	"Exile_Item_ChristmasTinner",
	"Exile_Item_Dogfood",
	"Exile_Item_EMRE",
	"Exile_Item_GloriousKnakworst",
	"Exile_Item_InstantCoffee",
	"Exile_Item_MacasCheese",
	"Exile_Item_Moobar",
	"Exile_Item_Noodles",
	"Exile_Item_Raisins",
	"Exile_Item_SausageGravy",
	"Exile_Item_SeedAstics",
	"Exile_Item_Surstromming",
	"Exile_Item_Can_Empty",
	"Exile_Item_Beer",
	"Exile_Item_ChocolateMilk",
	"Exile_Item_EnergyDrink",
	"Exile_Item_MountainDupe",
	"Exile_Item_PlasticBottleCoffee",
	"Exile_Item_PlasticBottleFreshWater",
	"Exile_Item_PowerDrink"
];

//This defines the skin list, some skins are disabled by default to permit players to have high visibility uniforms distinct from those of the AI.
DGDE_SkinList = 
[
	"Exile_Uniform_Woodland",
	"U_BG_Guerilla1_1",
	"U_BG_Guerilla2_1",
	"U_BG_Guerilla2_2",
	"U_BG_Guerilla2_3",
	"U_BG_Guerilla3_1",
	"U_BG_Guerrilla_6_1",
	"U_BG_leader",
	"U_B_CTRG_1",
	"U_B_CTRG_2",
	"U_B_CTRG_3",
	"U_B_CombatUniform_mcam",
	"U_B_CombatUniform_mcam_tshirt",
	"U_B_CombatUniform_mcam_vest",
	"U_B_CombatUniform_mcam_worn",
	"U_B_HeliPilotCoveralls",
	"U_B_PilotCoveralls",
	"U_B_SpecopsUniform_sgg",
	"U_B_Wetsuit",
	"U_B_survival_uniform",
	"U_C_HunterBody_grn",
	"U_C_Journalist",
	"U_C_Poloshirt_blue",
	"U_C_Poloshirt_burgundy",
	"U_C_Poloshirt_salmon",
	"U_C_Poloshirt_stripped",
	"U_C_Poloshirt_tricolour",
	"U_C_Poor_1",
	"U_C_Poor_2",
	"U_C_Poor_shorts_1",
	"U_C_Scientist",
	"U_Competitor",
	"U_IG_Guerilla1_1",
	"U_IG_Guerilla2_1",
	"U_IG_Guerilla2_2",
	"U_IG_Guerilla2_3",
	"U_IG_Guerilla3_1",
	"U_IG_Guerilla3_2",
	"U_IG_leader",
	"U_I_CombatUniform",
	"U_I_CombatUniform_shortsleeve",
	"U_I_CombatUniform_tshirt",
	"U_I_G_Story_Protagonist_F",
	"U_I_G_resistanceLeader_F",
	"U_I_HeliPilotCoveralls",
	"U_I_OfficerUniform",
	"U_I_Wetsuit",
	"U_I_pilotCoveralls",
	"U_NikosAgedBody",
	"U_NikosBody",
	"U_O_CombatUniform_ocamo",
	"U_O_CombatUniform_oucamo",
	"U_O_OfficerUniform_ocamo",
	"U_O_PilotCoveralls",
	"U_O_SpecopsUniform_blk",
	"U_O_SpecopsUniform_ocamo",
	"U_O_Wetsuit",
	"U_OrestesBody",
	"U_Rangemaster",
	"U_B_FullGhillie_ard",
	"U_B_FullGhillie_lsh",
	"U_B_FullGhillie_sard",
	"U_B_GhillieSuit",
	"U_I_FullGhillie_ard",
	"U_I_FullGhillie_lsh",
	"U_I_FullGhillie_sard",
	"U_I_GhillieSuit",
	"U_O_FullGhillie_ard",
	"U_O_FullGhillie_lsh",
	"U_O_FullGhillie_sard",
	"U_O_GhillieSuit"
];

DGDE_Configured = true;
["Configuration loaded", DGDE_MessageName] call DGCore_fnc_log;