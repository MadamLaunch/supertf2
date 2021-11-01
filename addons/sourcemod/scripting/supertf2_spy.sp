#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


new Handle:cvBlink;


public void SpyVariables() {
	cvBlink = CreateConVar("supertf2_blink", "-0.6",
		"Cloak activation time is manipulated");
}


public int SpyItems(String:classname[], itemDefinitionIndex,
		&Handle:old_item, Handle:new_item) {
	if(StrEqual(classname, "tf_weapon_invis")) {
		TF2Items_SetAttribute(new_item, 0, 253, GetConVarFloat(cvBlink));
		
		TF2Items_SetNumAttributes(new_item, 1);

		old_item = CloneHandle(new_item);
		return 1;
	}
	
	return 0;
}
