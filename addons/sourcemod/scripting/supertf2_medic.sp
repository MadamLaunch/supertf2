#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


new Handle:cvBlutsauger;
new Handle:cvBonesaw;
new Handle:cvMedigun;
new Handle:cvNeedles;
new Handle:cvSyringeMilk;


public void MedicVariables() {
	cvBlutsauger = CreateConVar("supertf2_blutsauger", "1.2",
		"Modify the speed of Blutsauger needles");
	cvBonesaw = CreateConVar("supertf2_bonesaws", "10.0",
		"Bonesaws inflict bleed");
	cvMedigun = CreateConVar("supertf2_medigun", "1.8",
		"Modify the Medigun's charge rate");
	cvNeedles = CreateConVar("supertf2_needles", "2.2",
		"Modify the damage of syringe guns");
	cvSyringeMilk = CreateConVar("supertf2_syringe_milk", "1.0",
		"Modify or not the Syringe Gun applies Mad Milk");
}


public int MedicItems(String:classname[], itemDefinitionIndex,
		&Handle:old_item, Handle:new_item) {
	/******************************************************************/
	/*                                                                */
	/*                          SYRINGE GUNS                          */
	/*                                                                */
	/******************************************************************/
	if(StrEqual(classname, "tf_weapon_syringegun_medic")) {
		switch(itemDefinitionIndex) {
			/**********************************************************/
			/*                         STOCK                          */
			/**********************************************************/
			case 17, 204: {
				// +X% damage bonus
				TF2Items_SetAttribute(
					new_item, 0, 2, GetConVarFloat(cvNeedles));
				
				int num = 1;
				if(GetConVarBool(cvSyringeMilk)) {
					// Syringes deliver a highly concentrated dose of
					// Mad Milk. Duration increases per hit to a max of
					// 4 seconds.
					TF2Items_SetAttribute(new_item, 1, 484, 1.0);
					num = 2;
				}

				TF2Items_SetNumAttributes(new_item, num);
				
				old_item = CloneHandle(new_item);
				return 1;
			}
			/**********************************************************/
			/*                     THE BLUTSAUGER                     */
			/**********************************************************/
			case 36: {
				int num = 0;
				// The Blutsauger always does half the damage of stock.
				float damage = GetConVarFloat(cvNeedles) * 0.5;
				if(damage < 1.0) {
					// X% damage penalty
					TF2Items_SetAttribute(new_item, 0, 1, damage);
					num++;
				}
				else if(damage > 1.0) {
					// +X% damage bonus
					TF2Items_SetAttribute(new_item, 0, 2, damage);
					num++;
				}
				
				float speed = GetConVarFloat(cvBlutsauger);
				if(speed > 1.0) {
					// +X% projectile speed
					TF2Items_SetAttribute(new_item, num, 103, speed);
					num++;
				}
				else if(speed < 1.0) {
					// X% projectile speed
					TF2Items_SetAttribute(new_item, num, 104, speed);
					num++;
				}
				
				// On Hit: X% ÜberCharge added
				TF2Items_SetAttribute(new_item, num, 17, 0.05);
				// X health drained per second on wearer
				TF2Items_SetAttribute(new_item, num + 1, 129, -6.0);
				num += 2;
				
				TF2Items_SetNumAttributes(new_item, num);
				
				old_item = CloneHandle(new_item);
				return 1;
			}
			/**********************************************************/
			/*                      THE OVERDOSE                      */
			/**********************************************************/
			case 412: {
				int num = 0;
				// The Overdose always does half the damage of stock.
				float damage = GetConVarFloat(cvNeedles) * 0.5;
				if(damage < 1.0) {
					// X% damage penalty
					TF2Items_SetAttribute(new_item, 0, 1, damage);
					num++;
				}
				// Be mindful to remove the default damage penalty!
				else if(damage > 1.0) {
					// X% damage penalty
					TF2Items_SetAttribute(new_item, 0, 1, 1.0);
					// +X% damage bonus
					TF2Items_SetAttribute(new_item, 1, 2, damage);
					num += 2;
				}
				else {
					// X% damage penalty
					TF2Items_SetAttribute(new_item, 0, 1, 1.0);
					num++;
				}
				// On Hit: X% ÜberCharge added
				TF2Items_SetAttribute(new_item, num, 17, 0.01);
				// This weapon holsters X% faster
				TF2Items_SetAttribute(new_item, num + 1, 199, 0.8);
				// This weapon deploys X% faster
				TF2Items_SetAttribute(new_item, num + 2, 547, 0.8);
				// While active, movement speed increases based on
				// ÜberCharge percentage to a maximum of +X%
				TF2Items_SetAttribute(new_item, num + 3, 792, 1.3);
				num += 4;
				
				TF2Items_SetNumAttributes(new_item, num);
				
				old_item = CloneHandle(new_item);
				return 1;
			}
		}
	}
	/******************************************************************/
	/*                                                                */
	/*                            MEDIGUNS                            */
	/*                                                                */
	/******************************************************************/
	else if(StrEqual(classname, "tf_weapon_medigun")) {
		// The Quick-Fix always charges 50% faster than other mediguns.
		float charge_speed = GetConVarFloat(cvMedigun);
		if(itemDefinitionIndex == 411) {
			charge_speed *= 1.5;
		}
		
		// +X% ÜberCharge rate
		TF2Items_SetAttribute(new_item, 0, 10, charge_speed);
		
		TF2Items_SetNumAttributes(new_item, 1);
		
		old_item = CloneHandle(new_item);
		return 1;
	}
	/******************************************************************/
	/*                                                                */
	/*                            BONESAWS                            */
	/*                                                                */
	/******************************************************************/
	else if(StrEqual(classname, "tf_weapon_bonesaw")) {
		switch(itemDefinitionIndex) {
			/**********************************************************/
			/*                         STOCK                          */
			/**********************************************************/
			case 8, 198, 1143: {
				// 	On Hit: Bleed for X seconds
				TF2Items_SetAttribute(
					new_item, 0, 149, GetConVarFloat(cvBonesaw));
				
				TF2Items_SetNumAttributes(new_item, 1);
				
				old_item = CloneHandle(new_item);
				return 1;
			}
		}
	}
	
	return 0;
}
