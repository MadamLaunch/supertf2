#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2attributes>
#include <tf2items>


new Handle:cvFlameBoost;

bool DegreaserUsers[MAXPLAYERS + 1];
Handle DegreaserTimers[MAXPLAYERS + 1];


public void PyroVariables() {
	cvFlameBoost = CreateConVar("supertf2_flameboost", "8.5",
		"The damage point from which direct flame damage ramps up and down");
}


public int PyroItems(client, String:classname[], itemDefinitionIndex,
		&Handle:old_item, &Handle:new_item) {
	/******************************************************************/
	/*                            SHOTGUNS                            */
	/******************************************************************/
	float shotguns = GetConVarFloat(cvShotguns);
	
	if(StrEqual(classname, "tf_weapon_shotgun")) {
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
	
	switch(itemDefinitionIndex) {
		/**************************************************************/
		/*                       THE BACKBURNER                       */
		/**************************************************************/
		case 40, 1146: {
			int foo[][] = {
				{165, 100}, // Airblast can now be charged, which will push enemies further
				{170, 100}, // +X% airblast cost [NEGATED]
			};
			ModifyWeapon(old_item, new_item, foo, sizeof(foo));
			return 1;
		}
		/**************************************************************/
		/*                       DRAGON'S FURY                        */
		/**************************************************************/
		case 1178: {
			int foo[][] = {
				{171, 40}, // X% airblast cost
			};
			ModifyWeapon(old_item, new_item, foo, sizeof(foo));
			return 1;
		}
		/**************************************************************/
		/*                       THE DEGREASER                        */
		/**************************************************************/
		case 215: {
			int foo[][] = {
				{72, 100}, // X% afterburn damage penalty [NEGATED]
				{74, 1}, // X% afterburn duration
				{170, 100}, // +X% airblast cost [NEGATED]
				{171, 50}, // X% airblast cost
				{77, 50}, // X% max primary ammo on wearer
			//	{178, 20}, // X% faster weapon switch
				{199, 100}, // This weapon holsters X% faster [NEGATED]
				{547, 100}, // This weapon deploys X% faster [NEGATED]
				{1008, 100}, // Halloween Fire
			};
			ModifyWeapon(old_item, new_item, foo, sizeof(foo));
			return 1;
		}
		/**************************************************************/
		/*                THE DETONATOR / SCORCH SHOT                 */
		/**************************************************************/
		case 351, 740: {
			int foo[][] = {
				{59, 100}, // X% self damage force [NEGATED]
				{65, 100}, // X% explosive damage vulnerability on wearer [NEGATED]
			};
			ModifyWeapon(old_item, new_item, foo, sizeof(foo));
			return 1;
		}
		/**************************************************************/
		/*                     BASE FLAMETHROWERS                     */
		/**************************************************************/
		default: {
			if(StrEqual(classname, "tf_weapon_flamethrower")) {
				int foo[][] = {
					{171, 50}, // X% airblast cost
				};
				ModifyWeapon(old_item, new_item, foo, sizeof(foo));
				return 1;
			}
		}
	}
	
	return 0;
}


public void PyroHooks(int client) {
	SDKHook(client, SDKHook_WeaponSwitch, DegreaserSwitch);
}


public Action:DegreaserSwitch(client, weapon) {
	if(weapon == -1) return Plugin_Continue;
	
	int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"); // Exception reported: Entity -1 (-1) is invalid
	
	if(index == 215) {
		TF2Attrib_SetByDefIndex(weapon, 178, 0.275);
		
		if(DegreaserTimers[client] != null) {
			KillTimer(DegreaserTimers[client]);
			DegreaserTimers[client] = null;
		}
		
		DegreaserUsers[client] = true;
		return Plugin_Changed;
	}
	else {
		if(DegreaserUsers[client]) {
			DegreaserTimers[client]
				= CreateTimer(0.33, DebuffDegreaser, client);
		}
		
		DegreaserUsers[client] = false;
	}
	
	return Plugin_Continue;
}


public Action DebuffDegreaser(Handle timer, any client) {
	if(!IsValidEntity(client))
		return;
	
	int primary = GetPlayerWeaponSlot(client, 0);
	TF2Attrib_SetByDefIndex(primary, 178, 1.0);
	
	DegreaserTimers[client] = null;
}


public int PyroDamagePre(victim, &attacker, &inflictor, 
		&Float:damage, &damagetype, &weapon, Float:damageForce[3],
		Float:damagePosition[3]) {
	int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	
	decl String:classname[64];
	classname[0] = '\0';
	GetEntityClassname(inflictor, classname, sizeof(classname));
	
	if(StrEqual(classname, "tf_weapon_flamethrower")) {
		switch(index) {
			/**********************************************************/
			/*                     THE BACKBURNER                     */
			/**********************************************************/
			case 40, 1146: {
				
			}
			/**********************************************************/
			/*                     THE DEGREASER                      */
			/**********************************************************/
			case 215: {
				
			}
			/**********************************************************/
			/*                   BASE FLAMETHROWERS                   */
			/**********************************************************/
			default: {
				if(GetConVarBool(cvFlameBoost)) {
					float o_dmg = damage;
					float n_dmg = damage;
					
					float min = GetConVarFloat(cvFlameBoost);
				//	if(damage < min) {
					float percentage = damage / min;
					n_dmg *= percentage;
					
					if(percentage < 1.0)
						n_dmg -= 1.0;
					else if(percentage > 1.0)
						n_dmg += 1.0;
					
					if(n_dmg < 0.0)
						n_dmg = 1.2;
					
					damage = float(RoundToFloor(n_dmg));
				//	}
				//	else if(damage > 0) { // ???
				//		damage *= GetConVarFloat(cvFlameBoost);
				//	}
					
					if(GetConVarBool(cvVerbose)) {
						PrintToChat(
							attacker, "%f → %d", o_dmg, RoundFloat(damage));
						PrintCenterText(
							attacker, "%d", RoundFloat(damage - o_dmg));
					}
					
					return 1;
				}
			}
		}
	}

	return 0;
}


public void PyroDamagePost(int victim, int attacker, int inflictor,
		float damage, int damagetype, int weapon,
		const float damageForce[3], const float damagePosition[3],
		int damagecustom) {
	int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	
	switch(index) {
		/**************************************************************/
		/*                       THE BACKBURNER                       */
		/**************************************************************/
		case 40, 1146: {
			
		}
		/**************************************************************/
		/*                       THE DEGREASER                        */
		/**************************************************************/
		case 215: {
			TF2_RemoveCondition(victim, TFCond_OnFire);
			TF2_IgnitePlayer(victim, attacker, 1.0);
		}
	}
}
