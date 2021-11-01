#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#include <tf2>
#include <tf2_stocks>
#include <tf2items>


/*
enum struct AttribMod {
    int attribute;
    float value;
}
*/


void ModifyWeapon(&Handle:old_item, &Handle:new_item, int[][] attributes,
		int arr) {
	for(int j = 0; j < arr; j++) {
		TF2Items_SetAttribute(new_item, j,
			attributes[j][0], attributes[j][1] * 0.01);
	}
	
	TF2Items_SetNumAttributes(new_item, arr);
	old_item = CloneHandle(new_item);
}


/*
AttribMod foo[] = [
	[72, 1.0], // X% afterburn damage penalty [NEGATED]
	[74, 0.01], // X% afterburn duration
	[77, 0.5], // X% max primary ammo on wearer
	[199, 0.2], // This weapon holsters X% faster
	[547, 0.2], // This weapon deploys X% faster
	[1008, 1.0] // Halloween Fire
];
ModifyWeapon(old_item, new_item, foo);
return 1;
*/
