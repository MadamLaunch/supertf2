#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


new Handle:cvPipes;
new Handle:cvStickyCharge;
new Handle:cvStickyCrosshair;
new Handle:cvStickyTime;


public void DemomanVariables() {
	cvPipes = CreateConVar("supertf2_pipes", "1.5",
		"Increase the Grenade Launcher's clip size");
	cvStickyTime = CreateConVar("supertf2_stickytime", "-0.2",
		"How to modify point-blank damage from direct flames");
	cvStickyCharge = CreateConVar("supertf2_stickycharge", "0.5",
		"How to modify point-blank damage from direct flames");
	cvStickyCrosshair = CreateConVar("supertf2_stickycrosshair", "1.0",
		"How to modify point-blank damage from direct flames");
}


public int DemomanItems(String:classname[], itemDefinitionIndex,
		&Handle:old_item, Handle:new_item) {
	/******************************************************************/
	/*                                                                */
	/*                       GRENADE LAUNCHERS                        */
	/*                                                                */
	/******************************************************************/
	if(StrEqual(classname, "tf_weapon_grenadelauncher")) {
		switch(itemDefinitionIndex) {
			/**********************************************************/
			/*                         STOCK                          */
			/**********************************************************/
			case 19, 206, 1007: {
				TF2Items_SetAttribute(new_item, 0, 4, GetConVarFloat(cvPipes));
				
				TF2Items_SetNumAttributes(new_item, 1);
				
				old_item = CloneHandle(new_item);
				return 1;
			}
			/**********************************************************/
			/*                    THE LOCH-n-LOAD                     */
			/**********************************************************/
			case 308: {
				TF2Items_SetAttribute(new_item, 0, 3, 0.5); // X% clip size
				TF2Items_SetAttribute(new_item, 1, 97, 0.85); // X% faster reload time
				
				TF2Items_SetNumAttributes(new_item, 2);
				
				old_item = CloneHandle(new_item);
				return 1;
			}
			/**********************************************************/
			/*                    THE IRON BOMBER                     */
			/**********************************************************/
			case 1151: {
				int foo[][] = {
					{137, 120}, // +X% damage vs buildings
				};
				ModifyWeapon(old_item, new_item, foo, sizeof(foo));
				return 1;
			}
		}
	}
	/******************************************************************/
	/*                                                                */
	/*                      STICKYBOMB LAUNCHERS                      */
	/*                                                                */
	/******************************************************************/
	else if(StrEqual(classname, "tf_weapon_pipebomblauncher")) {
		TF2Items_SetAttribute(new_item, 0, 670, GetConVarFloat(cvStickyCharge));
		TF2Items_SetAttribute(new_item, 1, 119, GetConVarFloat(cvStickyCrosshair));
		TF2Items_SetAttribute(new_item, 2, 121, 0.0);
		TF2Items_SetAttribute(new_item, 3, 126, GetConVarFloat(cvStickyTime));
		
		int num = 4;
		/**************************************************************/
		/*                       STICKY JUMPER                        */
		/**************************************************************/
		if(itemDefinitionIndex == 265) {
			TF2Items_SetAttribute(new_item, 4, 1, 0.0);
			TF2Items_SetAttribute(new_item, 5, 15, 0.0);
			TF2Items_SetAttribute(new_item, 6, 78, 3.0);
			TF2Items_SetAttribute(new_item, 7, 181, 1.0);
			TF2Items_SetAttribute(new_item, 8, 280, 14.0);
			TF2Items_SetAttribute(new_item, 9, 400, 1.0);
			num = 10;
		}
		
		TF2Items_SetNumAttributes(new_item, num);
		
		old_item = CloneHandle(new_item);
		return 1;
	}
	/******************************************************************/
	/*                                                                */
	/*                            SHIELDS                             */
	/*                                                                */
	/******************************************************************/
	else if(StrEqual(classname, "tf_wearable_demoshield")) {
		int foo[][] = {
			{60, 50}, // +X% fire damage resistance on wearer
			{64, 30}, // +X% explosive damage resistance on wearer
			{248, 170}, // +X% increase in charge impact damage
			{249, 150}, // +X% increase in charge recharge rate
			{639, 100}, // Full turning control while charging
			{676, 100}, // Taking damage while shield charging reduces remaining charging time
			{2034, 75}, // Melee kills refill X% of your charge meter.
		};
		ModifyWeapon(old_item, new_item, foo, sizeof(foo));
		return 1;
	}
	
	return 0;
}


public int DemomanDamagePre(victim, &attacker, &inflictor, 
		&Float:damage, &damagetype, &weapon, Float:damageForce[3],
		Float:damagePosition[3]) {
	new index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	
	// Stock is 19.
	// Loch-n-Load is 308.
	if(index != 308) return 0;
	
	if(TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeath)) {
		damagetype |= DMG_CRIT;
	}
	
	return 1;
}


public void DemomanDamagePost(int victim, int attacker, int inflictor,
		float damage, int damagetype, int weapon,
		const float damageForce[3], const float damagePosition[3],
		int damagecustom) {
	new index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	
	// Stock is 19.
	// Loch-n-Load is 308.
	if(index != 308) return;
	
	if(!TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeath)) {
		TF2_AddCondition(victim, TFCond_MarkedForDeath, 2.0);
	}
}
