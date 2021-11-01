#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


new Handle:cvSMG;
new Handle:cvSMGHeadshots;


public void SniperVariables() {
	cvSMG = CreateConVar("supertf2_smg", "2.0",
		"Increase the damage of the Submachine Gun");
	cvSMGHeadshots = CreateConVar("supertf2_smgheadhots", "1.0",
		"Headshots from the Submachine Gun are critical hits");
}


public int SniperItems(String:classname[], itemDefinitionIndex,
		&Handle:old_item, Handle:new_item) {
	/******************************************************************/
	/*                                                                */
	/*                              SMGs                              */
	/*                                                                */
	/******************************************************************/
	if(StrEqual(classname, "tf_weapon_smg")) {
		TF2Items_SetAttribute(new_item, 0, 2, GetConVarFloat(cvSMG)); // +X% damage bonus
		
		int num = 1;
		if(GetConVarBool(cvSMGHeadshots)) {
			TF2Items_SetAttribute(new_item, 1, 51, 1.0); // Crits on headshot
			num = 2;
		}
		
		TF2Items_SetNumAttributes(new_item, num);

		old_item = CloneHandle(new_item);
		return 1;
	}
	
	return 0;
}
