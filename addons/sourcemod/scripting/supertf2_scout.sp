#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


public void ScoutVariables() {
	
}


public int ScoutItems(String:classname[], itemDefinitionIndex,
		&Handle:old_item, Handle:new_item) {
	/******************************************************************/
	/*                            PISTOLS                             */
	/******************************************************************/
	if(StrEqual(classname, "tf_weapon_pistol")) {
		float pistols = GetConVarFloat(cvPistols);
		
		if(pistols > 1.0) {
			TF2Items_SetAttribute(new_item, 0, 2, pistols); // +X% damage bonus
		}
		else {
			TF2Items_SetAttribute(new_item, 0, 1, pistols); // X% damage penalty
		}
		
		if(pistols != 1.0) {
			TF2Items_SetNumAttributes(new_item, 1);

			old_item = CloneHandle(new_item);
			return 1;
		}
	}
	
	return 0;
}
