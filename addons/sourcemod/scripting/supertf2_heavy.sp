#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>

#include <dhooks>


new Handle:cvFists;
new Handle:cvHeavySpeed;
new Handle:cvMinigunSpeed;
new Handle:cvMinigunSpread;

bool NataschaUsers[MAXPLAYERS + 1];
bool FastHeavies[MAXPLAYERS + 1];

Handle Hook_OnMyWeaponFired;


public void HeavyVariables() {
	cvFists = CreateConVar("supertf2_fists", "2.0",
		"Increase the damage of Heavy's fists");
	cvHeavySpeed = CreateConVar("supertf2_heavyspeed", "1.3",
		"Heavy moves faster when not wielding his primary weapon");
	cvMinigunSpeed = CreateConVar("supertf2_minigunspeed", "0.8",
		"Make all miniguns as accurate as the vanilla Tomislav");
	cvMinigunSpread = CreateConVar("supertf2_minigunspread", "0.8",
		"Make all miniguns as fast as the vanilla Tomislav");
	
	Handle config = LoadGameConfigFile("tf2.onmyweaponfired");
	
	int offset = GameConfGetOffset(config, "CBasePlayer::OnMyWeaponFired");
	if (offset == -1)
		SetFailState("Missing offset for CBasePlayer::OnMyWeaponFired");
	
	Hook_OnMyWeaponFired = DHookCreate(
		offset, HookType_Entity, ReturnType_Void,
		ThisPointer_CBaseEntity, OnMyWeaponFired);
	DHookAddParam(Hook_OnMyWeaponFired, HookParamType_Int);
	
	delete config;
	
	for(int j = 1; j <= MaxClients; j++) {
		if(IsClientInGame(j))
			OnClientPutInServer(j);
	}
}


public int HeavyItems(client, String:classname[], itemDefinitionIndex,
		&Handle:old_item, Handle:new_item) {
	/* ************************************************************** */
	/*              ATTEMPT TO FIX LOADOUT-SWITCH BUG #1              */
	/* ************************************************************** */
	TF2_RemoveCondition(client, TFCond_Dazed);
	
	/* ************************************************************** */
	/*                                                                */
	/*                            MINIGUNS                            */
	/*                                                                */
	/* ************************************************************** */
	if(StrEqual(classname, "tf_weapon_minigun")) {
		float speed = GetConVarFloat(cvMinigunSpeed);
		float spread = GetConVarFloat(cvMinigunSpread);
		
		int num = 3;
		bool is_natascha = false;
		switch(itemDefinitionIndex) {
			/* ****************************************************** */
			/*                        NATASCHA                        */
			/* ****************************************************** */
			case 41: {
				spread *= 0.7;
				
				TF2Items_SetAttribute(new_item, 3, 1, 0.8); // X% damage penalty
				TF2Items_SetAttribute(new_item, 4, 16, 10.0); // On Hit: Gain up to +X health
				TF2Items_SetAttribute(new_item, 5, 32, 0.0); // On Hit: X% chance to slow target [NEGATED]
				TF2Items_SetAttribute(new_item, 6, 37, 2.25); // +X% max primary ammo on wearer [HIDDEN]
				TF2Items_SetAttribute(new_item, 7, 75, 1.2); // +X% faster move speed while deployed
				num = 8;
				
				is_natascha = true;
			}
			/* ****************************************************** */
			/*                    THE BRASS BEAST                     */
			/* ****************************************************** */
			case 312: {
				TF2Items_SetAttribute(new_item, 3, 86, 1.0); // X% slower spin up time [NEGATED]
				TF2Items_SetAttribute(new_item, 4, 183, 0.2); // X% slower move speed while deployed
				num = 5;
			}
			/* ****************************************************** */
			/*                        TOMISLAV                        */
			/* ****************************************************** */
			case 424: {
				speed *= 0.6;
				spread *= 1.25;
			}
			/* ****************************************************** */
			/*                  THE HUO-LONG HEATER                   */
			/* ****************************************************** */
			case 811, 832: {
				speed *= 0.8;
			}
		}
		
		NataschaUsers[client] = is_natascha;
		
		TF2Items_SetAttribute(new_item, 0, 87, speed); // X% faster spin up time
		TF2Items_SetAttribute(new_item, 1, 106, spread); // X% more accurate
		TF2Items_SetAttribute(new_item, 2, 851, 0.77); // +X% faster move speed on wearer
		
		TF2Items_SetNumAttributes(new_item, num);
		
		old_item = CloneHandle(new_item);
		return 1;
	}
	/* ************************************************************** */
	/*                                                                */
	/*                            SHOTGUNS                            */
	/*                                                                */
	/* ************************************************************** */
	else if(StrEqual(classname, "tf_weapon_shotgun")) {
		float shotguns = GetConVarFloat(cvShotguns);
		
		TF2Items_SetAttribute(new_item, 0, 2, shotguns); // X% damage bonus
		
		int num = 1;
		/* ********************************************************** */
		/*                    THE FAMILY BUSINESS                     */
		/* ********************************************************** */
		if(itemDefinitionIndex == 425) {
			/*
			int foo[][] = {
				{2, shotguns}, // X% damage bonus
				{1, 100}, // X% damage penalty [NEGATED]
				{3, 50}, // X% clip size
				{4, 100}, // +X% clip size [NEGATED]
				{5, 115}, // X% slower firing speed
				{6, 100}, // X% faster firing speed [NEGATED]
				{36, 300}, // X% less accurate
				{45, 280}, // +X% bullets per shot
				{96, 150}, // +X% slower reload time
				{309, 100}, // Killing an enemy with a critical hit will dismember your victim. Painfully.
				{397, 400}, // Bullets penetrate +X enemies
			};
			ModifyWeapon(old_item, new_item, foo, sizeof(foo));
			return 1;
			*/
			
			TF2Items_SetAttribute(new_item, 1, 1, 1.0); // X% damage penalty [NEGATED]
			TF2Items_SetAttribute(new_item, 2, 3, 0.5); // X% clip size
			TF2Items_SetAttribute(new_item, 3, 4, 1.0); // +X% clip size [NEGATED]
			TF2Items_SetAttribute(new_item, 4, 5, 1.15); // X% slower firing speed
			TF2Items_SetAttribute(new_item, 5, 6, 1.0); // X% faster firing speed [NEGATED]
			TF2Items_SetAttribute(new_item, 6, 36, 3.0); // X% less accurate
			TF2Items_SetAttribute(new_item, 7, 45, 2.8); // +X% bullets per shot
			TF2Items_SetAttribute(new_item, 8, 96, 1.5); // +X% slower reload time
			TF2Items_SetAttribute(new_item, 9, 309, 1.0); // Killing an enemy with a critical hit will dismember your victim. Painfully.
			TF2Items_SetAttribute(new_item, 10, 397, 4.0); // Bullets penetrate +X enemies
			num = 11;
		}
		/*
		else {
			int foo[][] = {
				{2, shotguns}, // X% damage bonus
			};
			ModifyWeapon(old_item, new_item, foo, sizeof(foo));
			return 1;
		}
		*/
		
		TF2Items_SetNumAttributes(new_item, num);

		old_item = CloneHandle(new_item);
		return 1;
	}
	/* ************************************************************** */
	/*                                                                */
	/*                              FOOD                              */
	/*                                                                */
	/* ************************************************************** */
	else if(StrEqual(classname, "tf_weapon_lunchbox")) {
		
	}
	/* ************************************************************** */
	/*                                                                */
	/*                         THESE MF HANDS                         */
	/*                                                                */
	/* ************************************************************** */
	else if(StrEqual(classname, "tf_weapon_fists")) {
		TF2Items_SetAttribute(new_item, 0, 2, GetConVarFloat(cvFists)); // X% damage bonus
		TF2Items_SetAttribute(new_item, 1, 855, 0.0); // Maximum health is drained while item is active [NEGATED]
		
		int num = 2;
		switch(itemDefinitionIndex) {
			/* ****************************************************** */
			/*                KILLER GLOVES OF BOXING                 */
			/* ****************************************************** */
			case 43: {
				TF2Items_SetAttribute(new_item, 2, 5, 0.65); // X% slower firing speed
				TF2Items_SetAttribute(new_item, 3, 216, 1.0); // apply look velocity on damage
				num = 4;
			}
			/* ****************************************************** */
			/*               GLOVES OF RUNNING URGENTLY               */
			/* ****************************************************** */
			case 239, 1084, 1100, 1184: {
				TF2Items_SetAttribute(new_item, 0, 2, 1.0); // X% damage bonus [NEGATED]
				
				TF2Items_SetAttribute(new_item, 2, 1, 0.4); // X% damage penalty
				TF2Items_SetAttribute(new_item, 3, 5, 1.2); // X% slower firing speed
				TF2Items_SetAttribute(new_item, 4, 772, 2.0); // This weapon holsters X% slower
				TF2Items_SetAttribute(new_item, 5, 851, 1.2); // +X% faster move speed on wearer
				num = 6;
			}
			/* ****************************************************** */
			/*                    WARRIOR'S SPIRIT                    */
			/* ****************************************************** */
			case 310: {
				TF2Items_SetAttribute(new_item, 0, 2, 1.0); // X% damage bonus [NEGATED]
				
				TF2Items_SetAttribute(new_item, 2, 180, 100.0); // +X health restored on kill
				TF2Items_SetAttribute(new_item, 3, 396, 0.6); // +X% faster melee attack speed
				num = 4;
			}
			/* ****************************************************** */
			/*                     FISTS OF STEEL                     */
			/* ****************************************************** */
			case 331: {
				TF2Items_SetAttribute(new_item, 2, 206, 1.0); // +X% damage from melee sources while active [NEGATED]
				TF2Items_SetAttribute(new_item, 3, 851, 0.77); // +X% faster move speed on wearer
				// remove healing nerfs
				// reduce punch speed
				num = 4;
			}
			/* ****************************************************** */
			/*                  THE EVICTION NOTICE                   */
			/* ****************************************************** */
			case 426: {
			//	TF2Items_SetAttribute(new_item, 0, 2, 1.0); // X% damage bonus [NEGATED]
				TF2Items_SetAttribute(new_item, 2, 772, 1.5); // This weapon holsters X% slower
				num = 3;
			}
		}
		
		TF2Items_SetNumAttributes(new_item, num);

		old_item = CloneHandle(new_item);
		return 1;
	}
	
	return 0;
}


void HeavyOnGameFrame() {
	for(int j = 0; j < MaxClients; j++) {
		if(!NataschaUsers[j]) {
			continue;
		}
		else {
			if(!IsClientInGame(j)) {
				NataschaUsers[j] = false;
				continue;
			}
			else if(!IsPlayerAlive(j)) {
				continue;
			}
			else if(TF2_GetPlayerClass(j) == TFClass_Heavy) {
				int weapon = GetPlayerWeaponSlot(j, TFWeaponSlot_Primary);
				int bullet = GetEntProp(
					weapon, Prop_Send, "m_iPrimaryAmmoType");
				
				int health = GetEntProp(j, Prop_Send, "m_iHealth");
				
				SetEntProp(j, Prop_Data, "m_iAmmo", health, _, bullet);
			}
			else {
				NataschaUsers[j] = false;
			}
		}
	}
}


public void HeavyDamagePost(int victim, int attacker, int inflictor,
		float damage, int damagetype, int weapon,
		const float damageForce[3], const float damagePosition[3],
		int damagecustom) {
	if(damagetype == DMG_CLUB || damagetype == DMG_SLASH) return;
	
	int entity = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	if(entity == -1) return;
	
	int active = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"); // Exception reported: Entity -1 (-1) is invalid
	
	if(attacker > 0 && active == 310) {
		TF2_AddCondition(attacker, TFCond_MarkedForDeath, 10.0, victim);
	}
}


public void HeavySpawnSpeed(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(TFClassType:event.GetInt("class") == TFClass_Heavy) {
		TF2Attrib_SetByDefIndex(client, 442, GetConVarFloat(cvHeavySpeed)); // major move speed bonus
	}
	else {
		TF2Attrib_SetByDefIndex(client, 442, 1.0); // major move speed bonus [NEGATED]
	}
}


public void HeavyHooks(int client) {
	DHookEntity(Hook_OnMyWeaponFired, true, client);
	SDKHook(client, SDKHook_WeaponSwitch, SpeedBoostSwitch);
	
	HookEvent("player_spawn", HeavySpawnSpeed);
}


public MRESReturn OnMyWeaponFired(
		int client, Handle hReturn, Handle hParams) {
	if(client < 1 || client > MaxClients)
		return MRES_Ignored;
	if(!NataschaUsers[client])
		return MRES_Ignored;
	if(!IsValidEntity(client)) {
		NataschaUsers[client] = false;
		return MRES_Ignored;
	}
	if(!IsPlayerAlive(client))
		return MRES_Ignored;
	
	int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int weapon = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
	
	if(weapon != 41) return MRES_Ignored;
	
	int health = GetEntProp(client, Prop_Send, "m_iHealth");
	SetEntityHealth(client, health - 1);
	
	return MRES_Ignored;
}


public Action:SpeedBoostSwitch(client, weapon) {
	if(weapon == -1) return Plugin_Continue;
	
	int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"); // Exception reported: Entity -1 (-1) is invalid
	
	if(index == 239 || index == 426 || index == 1084
			|| index == 1100 || index == 1184) {
		TF2_RemoveCondition(client, TFCond_Dazed);
		
		FastHeavies[client] = true;
		return Plugin_Changed;
	}
	else {
		if(FastHeavies[client]) {
			TF2_StunPlayer(client, 10.0, 0.85, TF_STUNFLAG_SLOWDOWN);
		}
		FastHeavies[client] = false;
	}
	
	return Plugin_Continue;
}
