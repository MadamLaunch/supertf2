#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


new Handle:cvBuildings;
new Handle:cvTeleporters;
new Handle:cvWrench;


public void EngineerVariables() {
	cvBuildings = CreateConVar("supertf2_buildings", "1.0",
		"Engineer buildings are automatically level 3");
	cvTeleporters = CreateConVar("supertf2_teleporters", "1.0",
		"Teleporters are made to work in both directions");
	cvWrench = CreateConVar("supertf2_wrench", "2.0",
		"Building upgrade speed is increased");
	
	HookEvent("player_builtobject", InstantUpgrade);
}


public int EngineerItems(String:classname[], itemDefinitionIndex,
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
	
	/******************************************************************/
	/*                            WRENCHES                            */
	/******************************************************************/
	if(StrEqual(classname, "tf_weapon_wrench")) {
		TF2Items_SetAttribute(new_item, 0, 2043, GetConVarFloat(cvWrench));
		
		int num = 1;
		if(GetConVarBool(cvTeleporters)) {
			TF2Items_SetAttribute(new_item, 1, 276, 1.0); // Teleporters can be used in both directions
			num = 2;
		}
		
		TF2Items_SetNumAttributes(new_item, num);

		old_item = CloneHandle(new_item);
		return 1;
	}
	
	return 0;
}


/**********************************************************************/
/*                                                                    */
/*                                                                    */
/*                                                                    */
/**********************************************************************/
public Action:InstantUpgrade(Handle:event, const String:name[],
		bool:dontBroadcast) {
	if(!GetConVarBool(cvMasterSwitch) || !GetConVarBool(cvBuildings))
		return Plugin_Continue;

	new building = GetEventInt(event, "index");
	if(GetEntProp(building, Prop_Send, "m_bMiniBuilding")) {
		return Plugin_Continue;
	}

	new weapon = GetPlayerWeaponSlot(
		GetClientOfUserId(GetEventInt(event, "userid")), TFWeaponSlot_Melee);
	if(IsValidEntity(weapon)) {
		SetEntProp(building, Prop_Send, "m_iHighestUpgradeLevel", 3);
	}

	return Plugin_Continue;
}
