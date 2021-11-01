#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


public void SoldierVariables() {
	
}


public int SoldierItems(String:classname[], itemDefinitionIndex,
		&Handle:old_item, Handle:new_item) {
	/******************************************************************/
	/*                            SHOTGUNS                            */
	/******************************************************************/
	if(StrEqual(classname, "tf_weapon_shotgun")) {
		float shotguns = GetConVarFloat(cvShotguns);
		
		if(shotguns > 1.0) {
			TF2Items_SetAttribute(new_item, 0, 2, shotguns); // +X% damage bonus
		}
		else {
			TF2Items_SetAttribute(new_item, 0, 1, shotguns); // X% damage penalty
		}
		
		if(shotguns != 1.0) {
			TF2Items_SetNumAttributes(new_item, 1);

			old_item = CloneHandle(new_item);
			return 1;
		}
	}
	
	return 0;
}
