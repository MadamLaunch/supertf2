#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


new Handle:cvMasterSwitch;
new Handle:cvVerbose;

new Handle:cvPistols;
new Handle:cvShotguns;


#include "supertf2_func.sp"

#include "supertf2_scout.sp"
#include "supertf2_soldier.sp"
#include "supertf2_pyro.sp"
#include "supertf2_demoman.sp"
#include "supertf2_heavy.sp"
#include "supertf2_engineer.sp"
#include "supertf2_sniper.sp"
#include "supertf2_medic.sp"
#include "supertf2_spy.sp"


/**********************************************************************/
/*                                                                    */
/*                                                                    */
/*                                                                    */
/**********************************************************************/
public Plugin:myinfo = {
	name = "Super Team Fortress 2",
	author = "Alfonso Crawford",
	description = "A far-reaching rework of TF2's core gameplay",
	version = "2021.10.29",
	url = "http://alfonsocrawford.com"
};


public OnPluginStart() {
	cvMasterSwitch = CreateConVar("supertf2", "1",
		"Master switch to enable Super Team Fortress 2");
	cvVerbose = CreateConVar("supertf2_verbose", "1",
		"Push Super TF2 debug data to all clients");
	
	cvPistols = CreateConVar("supertf2_pistols", "2.0",
		"Modify the damage of pistols");
	cvShotguns = CreateConVar("supertf2_shotguns", "2.0",
		"Modify the damage of shotguns");
	
	ScoutVariables();
	SoldierVariables();
	PyroVariables();
	
	DemomanVariables();
	HeavyVariables();
	EngineerVariables();
	
	MedicVariables();
	SniperVariables();
	SpyVariables();
}


/* ****************************************************************** */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* ****************************************************************** */
public Action:TF2Items_OnGiveNamedItem(
		client, String:classname[], itemDefinitionIndex, &Handle:hItem) {
	if(!GetConVarBool(cvMasterSwitch)) return Plugin_Continue;
	
	Handle item = TF2Items_CreateItem(
		OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);
	
	int changed = 0;
	switch(TF2_GetPlayerClass(client)) {
		case TFClass_Scout:
			changed += ScoutItems(
				classname, itemDefinitionIndex, hItem, item);
		case TFClass_Soldier:
			changed += SoldierItems(
				classname, itemDefinitionIndex, hItem, item);
		case TFClass_Pyro:
			changed += PyroItems(
				client, classname, itemDefinitionIndex, hItem, item);
		case TFClass_DemoMan:
			changed += DemomanItems(
				classname, itemDefinitionIndex, hItem, item);
		case TFClass_Heavy:
			changed += HeavyItems(
				client, classname, itemDefinitionIndex, hItem, item);
		case TFClass_Engineer:
			changed += EngineerItems(
				classname, itemDefinitionIndex, hItem, item);
		case TFClass_Sniper:
			changed += SniperItems(
				classname, itemDefinitionIndex, hItem, item);
		case TFClass_Medic:
			changed += MedicItems(
				classname, itemDefinitionIndex, hItem, item);
		case TFClass_Spy:
			changed += SpyItems(
				classname, itemDefinitionIndex, hItem, item);
	}
	
	return changed ? Plugin_Changed : Plugin_Continue;
}


/* ****************************************************************** */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* ****************************************************************** */
public void OnGameFrame() {
	HeavyOnGameFrame();
}


public OnClientPutInServer(client) {
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamagePre);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	
	PyroHooks(client);
	HeavyHooks(client);
}


public Action:OnTakeDamagePre(victim, &attacker, &inflictor, 
		&Float:damage, &damagetype, &weapon, Float:damageForce[3],
		Float:damagePosition[3]) {
	if(attacker < 1 || attacker > MaxClients
			|| !GetConVarBool(cvMasterSwitch)
			|| !IsValidEntity(weapon))
		return Plugin_Continue;
	
	int changed = 0;
	switch(TF2_GetPlayerClass(attacker)) {
		case TFClass_Pyro:
			changed += PyroDamagePre(victim, attacker, inflictor,
				damage, damagetype, weapon, damageForce, damagePosition);
		case TFClass_DemoMan:
			changed += DemomanDamagePre(victim, attacker, inflictor,
				damage, damagetype, weapon, damageForce, damagePosition);
	}
	
	return changed ? Plugin_Changed : Plugin_Continue;
}


public void OnTakeDamagePost(int victim, int attacker, int inflictor,
		float damage, int damagetype, int weapon,
		const float damageForce[3], const float damagePosition[3],
		int damagecustom) {
	if(attacker < 1 || attacker > MaxClients
			|| !GetConVarBool(cvMasterSwitch)
			|| !IsValidEntity(weapon)) {
		// Do nothing.
	}
	else {
		switch(TF2_GetPlayerClass(attacker)) {
			case TFClass_Pyro:
				PyroDamagePost(victim, attacker, inflictor,
					damage, damagetype, weapon, damageForce,
					damagePosition, damagecustom);
			case TFClass_DemoMan:
				DemomanDamagePost(victim, attacker, inflictor,
					damage, damagetype, weapon, damageForce,
					damagePosition, damagecustom);
		}
	}
	
	if(victim < 1 || victim > MaxClients
			|| !GetConVarBool(cvMasterSwitch)
			|| !IsValidEntity(weapon)) {
		// Do nothing.
	}
	else {
		switch(TF2_GetPlayerClass(victim)) {
			case TFClass_Heavy:
				HeavyDamagePost(victim, attacker, inflictor,
					damage, damagetype, weapon, damageForce,
					damagePosition, damagecustom);
		}
	}
}
