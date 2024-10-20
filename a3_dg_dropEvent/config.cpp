class CfgPatches {
	class a3_dg_dropEvent {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
	};
};
class CfgFunctions {
	class DGDropEvent {
		tag = "DGDropEvent";
		class Main {
			file = "\x\addons\a3_dg_dropEvent\init";
			class init {
				postInit = 1;
			};
		};
	};
};

