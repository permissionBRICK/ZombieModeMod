#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	init_weapons();
	init_weapon_upgrade();
	init_pay_turret();
	init_weapon_cabinet();
	treasure_chest_init();
	level thread add_limited_tesla_gun();
	level.box_moved = false;
	level.onlyteddy=false;
}

add_zombie_weapon( weapon_name, hint, cost, weaponVO, variation_count, ammo_cost  )
{
	if( IsDefined( level.zombie_include_weapons ) && !IsDefined( level.zombie_include_weapons[weapon_name] ) )
	{
		return;
	}
	
	add_weapon_to_sound_array(weaponVO,variation_count);

	// Check the table first
	table = "mp/zombiemode.csv";
	table_cost = TableLookUp( table, 0, weapon_name, 1 );
	table_ammo_cost = TableLookUp( table, 0, weapon_name, 2 );

	if( IsDefined( table_cost ) && table_cost != "" )
	{
		cost = round_up_to_ten( int( table_cost ) );
	}

	if( IsDefined( table_ammo_cost ) && table_ammo_cost != "" )
	{
		ammo_cost = round_up_to_ten( int( table_ammo_cost ) );
	}

	PrecacheItem( weapon_name );
	PrecacheString( hint );

	struct = SpawnStruct();

	if( !IsDefined( level.zombie_weapons ) )
	{
		level.zombie_weapons = [];
	}

	struct.weapon_name = weapon_name;
	struct.weapon_classname = "weapon_" + weapon_name;
	struct.hint = hint;
	struct.cost = cost;
	struct.sound = weaponVO;
	struct.variation_count = variation_count;
	struct.is_in_box = level.zombie_include_weapons[weapon_name];

	if( !IsDefined( ammo_cost ) )
	{
		ammo_cost = round_up_to_ten( int( cost * 0.5 ) );
	}

	struct.ammo_cost = ammo_cost;

	level.zombie_weapons[weapon_name] = struct;
}

default_weighting_func()
{
	return 1;
}

default_tesla_weighting_func()
{
	num_to_add = 1;
	if( isDefined( level.pulls_since_last_tesla_gun ) )
	{
		// player has dropped the tesla for another weapon, so we set all future polls to 20%
		if( isDefined(level.player_drops_tesla_gun) && level.player_drops_tesla_gun == true )
		{						
			num_to_add += int(.2 * level.zombie_include_weapons.size);		
		}
		
		// player has not seen tesla gun in late rounds
		if( !isDefined(level.player_seen_tesla_gun) || level.player_seen_tesla_gun == false )
		{
			// after round 10 the Tesla gun percentage increases to 20%
			if( level.round_number > 10 )
			{
				num_to_add += int(.2 * level.zombie_include_weapons.size);
			}		
			// after round 5 the Tesla gun percentage increases to 15%
			else if( level.round_number > 5 )
			{
				// calculate the number of times we have to add it to the array to get the desired percent
				num_to_add += int(.15 * level.zombie_include_weapons.size);
			}						
		}
		num_to_add +=1;
	}
	return num_to_add;
}

default_ray_gun_weighting_func()
{
	if( level.box_moved == true )
	{	
		num_to_add = 1;
		// increase the percentage of ray gun
		if( isDefined( level.pulls_since_last_ray_gun ) )
		{
			// after 12 pulls the ray gun percentage increases to 15%
			if( level.pulls_since_last_ray_gun > 11 )
			{
				num_to_add += int(level.zombie_include_weapons.size*0.15);			
			}			
			// after 8 pulls the Ray Gun percentage increases to 10%
			else if( level.pulls_since_last_ray_gun > 7 )
			{
				num_to_add += int(.1 * level.zombie_include_weapons.size);
			}		
		}
		num_to_add +=1;
		return num_to_add;	
	}
	else
	{
		return 0;
	}
}


//
//	Slightly elevate the chance to get it until someone has it, then make it even
default_cymbal_monkey_weighting_func()
{
	players = get_players();
	count = 0;
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] has_weapon_or_upgrade( "zombie_cymbal_monkey" ) )
		{
			count++;
		}
	}
	if ( count > 0 )
	{
		return 1;
	}
	else
	{
		if( level.round_number < 10 )
		{
			return 3;
		}
		else
		{
			return 5;
		}
	}
}


include_zombie_weapon( weapon_name, in_box, weighting_func )
{
	if( !IsDefined( level.zombie_include_weapons ) )
	{
		level.zombie_include_weapons = [];
	}
	if( !isDefined( in_box ) )
	{
		in_box = true;
	}

	level.zombie_include_weapons[weapon_name] = in_box;
	
	if( !isDefined( weighting_func ) )
	{
		level.weapon_weighting_funcs[weapon_name] = maps\_zombiemode_weapons::default_weighting_func;
	}
	else
	{
		level.weapon_weighting_funcs[weapon_name] = weighting_func;
	}
}

init_weapons()
{
	// Zombify
	PrecacheItem( "zombie_melee" );


	// Pistols
	add_zombie_weapon( "colt", 									&"ZOMBIE_WEAPON_COLT_50", 					50,		"vox_crappy",	8 );
	add_zombie_weapon( "colt_dirty_harry", 						&"ZOMBIE_WEAPON_COLT_DH_100", 				100,	"vox_357",		5 );
	add_zombie_weapon( "nambu", 								&"ZOMBIE_WEAPON_NAMBU_50", 					50, 	"vox_crappy",	8 );
	add_zombie_weapon( "sw_357", 								&"ZOMBIE_WEAPON_SW357_100", 				100, 	"vox_357",		5 );
	add_zombie_weapon( "zombie_sw_357", 						&"ZOMBIE_WEAPON_SW357_100", 				100, 	"vox_357",		5 );
	add_zombie_weapon( "zombie_sw_357_upgraded", 				&"ZOMBIE_WEAPON_SW357_100", 				100, 	"vox_357",		5 );
	add_zombie_weapon( "tokarev", 								&"ZOMBIE_WEAPON_TOKAREV_50", 				50, 	"vox_crappy",	8 );
	add_zombie_weapon( "walther", 								&"ZOMBIE_WEAPON_WALTHER_50", 				50, 	"vox_crappy",	8 );
	add_zombie_weapon( "zombie_colt", 							&"ZOMBIE_WEAPON_ZOMBIECOLT_25", 			25, 	"vox_crappy",	8 );
	add_zombie_weapon( "zombie_colt_upgraded", 					&"ZOMBIE_WEAPON_ZOMBIECOLT_25", 			25, 	"vox_crappy",	8 );

	// Bolt Action                                      		
	add_zombie_weapon( "kar98k", 								&"ZOMBIE_WEAPON_KAR98K_200", 				200,	"",				0);
	add_zombie_weapon( "zombie_kar98k", 						&"ZOMBIE_WEAPON_KAR98K_200", 				200,	"vox_tesla",	0);
	add_zombie_weapon( "zombie_kar98k_upgraded", 				&"ZOMBIE_WEAPON_KAR98K_200", 				200,	"",				0);
	add_zombie_weapon( "kar98k_bayonet", 						&"ZOMBIE_WEAPON_KAR98K_B_200", 				200,	"",				0);
	add_zombie_weapon( "mosin_rifle", 							&"ZOMBIE_WEAPON_MOSIN_200", 				200,	"",				0); 
	add_zombie_weapon( "mosin_rifle_bayonet", 					&"ZOMBIE_WEAPON_MOSIN_B_200", 				200,	"",				0 );
	add_zombie_weapon( "springfield", 							&"ZOMBIE_WEAPON_SPRINGFIELD_200", 			200,	"",				0 );
	add_zombie_weapon( "zombie_springfield", 					&"ZOMBIE_WEAPON_SPRINGFIELD_200", 			200,	"",				0 );
	add_zombie_weapon( "springfield_bayonet", 					&"ZOMBIE_WEAPON_SPRINGFIELD_B_200", 		200,	"",				0 );
	add_zombie_weapon( "zombie_type99_rifle", 					&"ZOMBIE_WEAPON_TYPE99_200", 				200,	"",				0 );
	add_zombie_weapon( "zombie_type99_rifle_upgraded", 			&"ZOMBIE_WEAPON_TYPE99_200", 				200,	"",				0 );
	add_zombie_weapon( "type99_rifle_bayonet", 					&"ZOMBIE_WEAPON_TYPE99_B_200", 				200,	"",				0 );

	// Semi Auto                                        		
	add_zombie_weapon( "zombie_gewehr43", 						&"ZOMBIE_WEAPON_GEWEHR43_600", 				600,	"" ,			0 );
	add_zombie_weapon( "zombie_gewehr43_upgraded", 				&"ZOMBIE_WEAPON_GEWEHR43_600", 				600,	"" ,			0 );
	add_zombie_weapon( "zombie_m1carbine", 						&"ZOMBIE_WEAPON_M1CARBINE_600",				600,	"" ,			0 );
	add_zombie_weapon( "zombie_m1carbine_upgraded", 			&"ZOMBIE_WEAPON_M1CARBINE_600",				600,	"" ,			0 );
	add_zombie_weapon( "m1carbine_bayonet", 					&"ZOMBIE_WEAPON_M1CARBINE_B_600", 			600,	"" ,			0 );
	add_zombie_weapon( "zombie_m1garand", 						&"ZOMBIE_WEAPON_M1GARAND_600", 				600,	"" ,			0 );
	add_zombie_weapon( "zombie_m1garand_upgraded", 				&"ZOMBIE_WEAPON_M1GARAND_600", 				600,	"" ,			0 );
	add_zombie_weapon( "m1garand_bayonet", 						&"ZOMBIE_WEAPON_M1GARAND_B_600", 			600,	"" ,			0 );
	add_zombie_weapon( "svt40", 								&"ZOMBIE_WEAPON_SVT40_600", 				600,	"" ,			0 );

	// Grenades                                         		
	add_zombie_weapon( "fraggrenade", 							&"ZOMBIE_WEAPON_FRAGGRENADE_250", 			250,	"" ,			0 );
	add_zombie_weapon( "molotov", 								&"ZOMBIE_WEAPON_MOLOTOV_200", 				200,	"vox_crappy",	8 );
	add_zombie_weapon( "molotov_zombie", 						&"ZOMBIE_WEAPON_MOLOTOV_200", 				200,	"vox_crappy",	8 );
	add_zombie_weapon( "stick_grenade", 						&"ZOMBIE_WEAPON_STICKGRENADE_250", 			250,	"" ,			0 );
	add_zombie_weapon( "stielhandgranate", 						&"ZOMBIE_WEAPON_STIELHANDGRANATE_250", 		250,	"" ,			0, 250 );
	add_zombie_weapon( "type97_frag", 							&"ZOMBIE_WEAPON_TYPE97FRAG_250", 			250,	"" ,			0 );

	// Scoped
	add_zombie_weapon( "kar98k_scoped_zombie", 					&"ZOMBIE_WEAPON_KAR98K_S_750", 				750,	"vox_ppsh",		5);
	add_zombie_weapon( "kar98k_scoped_bayonet_zombie", 			&"ZOMBIE_WEAPON_KAR98K_S_B_750", 			750,	"vox_ppsh",		5);
	add_zombie_weapon( "mosin_rifle_scoped_zombie", 			&"ZOMBIE_WEAPON_MOSIN_S_750", 				750,	"vox_ppsh",		5);
	add_zombie_weapon( "mosin_rifle_scoped_bayonet_zombie", 	&"ZOMBIE_WEAPON_MOSIN_S_B_750", 			750,	"vox_ppsh",		5);
	add_zombie_weapon( "ptrs41_zombie", 						&"ZOMBIE_WEAPON_PTRS41_750", 				750,	"vox_ppsh",		5);
	add_zombie_weapon( "ptrs41_zombie_upgraded", 				&"ZOMBIE_WEAPON_PTRS41_750", 				750,	"vox_ppsh",		5);
	add_zombie_weapon( "springfield_scoped_zombie", 			&"ZOMBIE_WEAPON_SPRINGFIELD_S_750", 		750,	"vox_ppsh",		5);
	add_zombie_weapon( "springfield_scoped_bayonet_zombie", 	&"ZOMBIE_WEAPON_SPRINGFIELD_S_B_750", 		750,	"vox_ppsh",		5);
	add_zombie_weapon( "type99_rifle_scoped_zombie", 			&"ZOMBIE_WEAPON_TYPE99_S_750", 				750,	"vox_ppsh",		5);
	add_zombie_weapon( "type99_rifle_scoped_bayonet_zombie", 	&"ZOMBIE_WEAPON_TYPE99_S_B_750", 			750,	"vox_ppsh",		5);

	// Full Auto                                                                                	
	add_zombie_weapon( "zombie_mp40", 							&"ZOMBIE_WEAPON_MP40_1000", 				1000,	"vox_mp40",		2 ); 
	add_zombie_weapon( "zombie_mp40_upgraded", 					&"ZOMBIE_WEAPON_MP40_1000", 				1000,	"vox_mp40",		2 ); 
	add_zombie_weapon( "zombie_ppsh", 							&"ZOMBIE_WEAPON_PPSH_2000", 				2000,	"vox_ppsh",		5 );
	add_zombie_weapon( "zombie_ppsh_upgraded", 					&"ZOMBIE_WEAPON_PPSH_2000", 				2000,	"vox_ppsh",		5 );
	add_zombie_weapon( "zombie_stg44", 							&"ZOMBIE_WEAPON_STG44_1200", 				1200,	"vox_mg",		9 );
	add_zombie_weapon( "zombie_stg44_upgraded", 				&"ZOMBIE_WEAPON_STG44_1200", 				1200,	"vox_mg",		9 );
	add_zombie_weapon( "zombie_thompson", 						&"ZOMBIE_WEAPON_THOMPSON_1200", 			1200,	"",				0 );
	add_zombie_weapon( "zombie_thompson_upgraded", 				&"ZOMBIE_WEAPON_THOMPSON_1200", 			1200,	"",				0 );
	add_zombie_weapon( "zombie_type100_smg", 					&"ZOMBIE_WEAPON_TYPE100_1000", 				1000,	"",				0 );
	add_zombie_weapon( "zombie_type100_smg_upgraded", 			&"ZOMBIE_WEAPON_TYPE100_1000", 				1000,	"",				0 );

	// Shotguns                                         	
	add_zombie_weapon( "zombie_doublebarrel", 					&"ZOMBIE_WEAPON_DOUBLEBARREL_1200", 		1200,	"vox_shotgun", 6);
	add_zombie_weapon( "zombie_doublebarrel_upgraded", 			&"ZOMBIE_WEAPON_DOUBLEBARREL_1200", 		1200,	"vox_shotgun", 6);
	add_zombie_weapon( "zombie_doublebarrel_sawed", 			&"ZOMBIE_WEAPON_DOUBLEBARREL_SAWED_1200", 	1200,	"vox_shotgun", 6);
	add_zombie_weapon( "zombie_doublebarrel_sawed_upgraded",	&"ZOMBIE_WEAPON_DOUBLEBARREL_SAWED_1200", 	1200,	"vox_shotgun", 6);
	add_zombie_weapon( "zombie_shotgun", 						&"ZOMBIE_WEAPON_SHOTGUN_1500", 				1500,	"vox_shotgun", 6);
	add_zombie_weapon( "zombie_shotgun_upgraded", 				&"ZOMBIE_WEAPON_SHOTGUN_1500", 				1500,	"vox_shotgun", 6);

	// Heavy Machineguns                                	
	add_zombie_weapon( "zombie_30cal", 							&"ZOMBIE_WEAPON_30CAL_3000", 				3000,	"vox_mg",		9 );
	add_zombie_weapon( "zombie_30cal_upgraded", 				&"ZOMBIE_WEAPON_30CAL_3000", 				3000,	"vox_mg",		9 );
	add_zombie_weapon( "zombie_bar", 							&"ZOMBIE_WEAPON_BAR_1800", 					1800,	"vox_bar",		5 );
	add_zombie_weapon( "zombie_bar_upgraded", 					&"ZOMBIE_WEAPON_BAR_1800", 					1800,	"vox_bar",		5 );
	add_zombie_weapon( "dp28", 									&"ZOMBIE_WEAPON_DP28_2250", 				2250,	"vox_mg" ,		9 );
	add_zombie_weapon( "zombie_fg42", 							&"ZOMBIE_WEAPON_FG42_1500", 				1500,	"vox_mg" ,		9 ); 
	add_zombie_weapon( "zombie_fg42_upgraded", 					&"ZOMBIE_WEAPON_FG42_1500", 				1500,	"vox_mg" ,		9 ); 
	add_zombie_weapon( "fg42_scoped", 							&"ZOMBIE_WEAPON_FG42_S_1500", 				1500,	"vox_mg" ,		9 ); 
	add_zombie_weapon( "zombie_mg42", 							&"ZOMBIE_WEAPON_MG42_3000", 				3000,	"vox_mg" ,		9 ); 
	add_zombie_weapon( "zombie_mg42_upgraded", 					&"ZOMBIE_WEAPON_MG42_3000", 				3000,	"vox_mg" ,		9 );
	add_zombie_weapon( "type99_lmg", 							&"ZOMBIE_WEAPON_TYPE99_LMG_1750", 			1750,	"vox_mg" ,		9 ); 

	// Grenade Launcher                                 	
	add_zombie_weapon( "m1garand_gl_zombie", 					&"ZOMBIE_WEAPON_M1GARAND_GL_1500", 			1500,	"",				0 );
	add_zombie_weapon( "m1garand_gl_zombie_upgraded", 			&"ZOMBIE_WEAPON_M1GARAND_GL_1500", 			1500,	"",				0 );
	add_zombie_weapon( "mosin_launcher_zombie", 				&"ZOMBIE_WEAPON_MOSIN_GL_1200",				1200,	"",				0 );

	// Bipods                               				
	add_zombie_weapon( "30cal_bipod", 							&"ZOMBIE_WEAPON_30CAL_BIPOD_3500", 			3500,	"vox_mg",		5 ); 
	add_zombie_weapon( "bar_bipod", 							&"ZOMBIE_WEAPON_BAR_BIPOD_2500", 			2500,	"vox_bar",		5 ); 
	add_zombie_weapon( "dp28_bipod", 							&"ZOMBIE_WEAPON_DP28_BIPOD_2500", 			2500,	"vox_mg",		5 ); 
	add_zombie_weapon( "fg42_bipod", 							&"ZOMBIE_WEAPON_FG42_BIPOD_2000", 			2000,	"vox_mg",		5 ); 
	add_zombie_weapon( "mg42_bipod", 							&"ZOMBIE_WEAPON_MG42_BIPOD_3250", 			3250,	"vox_mg",		5 ); 
	add_zombie_weapon( "type99_lmg_bipod", 						&"ZOMBIE_WEAPON_TYPE99_LMG_BIPOD_2250", 	2250,	"vox_mg",		5 ); 

	// Rocket Launchers
	add_zombie_weapon( "bazooka", 								&"ZOMBIE_WEAPON_BAZOOKA_2000", 				2000,	"",				0 ); 
	add_zombie_weapon( "panzerschrek_zombie", 					&"ZOMBIE_WEAPON_PANZERSCHREK_2000", 		2000,	"vox_panzer",	5 ); 
	add_zombie_weapon( "panzerschrek_zombie_upgraded", 			&"ZOMBIE_WEAPON_PANZERSCHREK_2000", 		2000,	"vox_panzer",	5 ); 

	// Flamethrower                                     	
	add_zombie_weapon( "m2_flamethrower_zombie", 				&"ZOMBIE_WEAPON_M2_FLAMETHROWER_3000", 		3000,	"vox_flame",	7);	
	add_zombie_weapon( "m2_flamethrower_zombie_upgraded", 		&"ZOMBIE_WEAPON_M2_FLAMETHROWER_3000", 		3000,	"vox_flame",	7);	

	// Special                                          	
	add_zombie_weapon( "mine_bouncing_betty",					&"ZOMBIE_WEAPON_SATCHEL_2000",				2000,	"" );
	add_zombie_weapon( "mortar_round", 							&"ZOMBIE_WEAPON_MORTARROUND_2000", 			2000,	"" );
	add_zombie_weapon( "satchel_charge", 						&"ZOMBIE_WEAPON_SATCHEL_2000", 				2000,	"vox_monkey",	3 );
	add_zombie_weapon( "zombie_cymbal_monkey",					&"ZOMBIE_WEAPON_SATCHEL_2000", 				2000,	"vox_monkey",	3 );
	add_zombie_weapon( "ray_gun", 								&"ZOMBIE_WEAPON_RAYGUN_10000", 				10000,	"vox_raygun",	6 );
	add_zombie_weapon( "ray_gun_upgraded", 						&"ZOMBIE_WEAPON_RAYGUN_10000", 				10000,	"vox_raygun",	6 );
	add_zombie_weapon( "tesla_gun",								&"ZOMBIE_BUY_TESLA", 						10,		"vox_tesla",	5 );
	add_zombie_weapon( "tesla_gun_upgraded",					&"ZOMBIE_BUY_TESLA", 						10,		"vox_tesla",	5 );

	if(level.script != "nazi_zombie_prototype")
	{
		Precachemodel("zombie_teddybear");
	}
	// ONLY 1 OF THE BELOW SHOULD BE ALLOWED
	add_limited_weapon( "m2_flamethrower_zombie", 1 );
	add_limited_weapon( "tesla_gun", 1);
	add_limited_weapon( "zmbie_kar98k", 1);
}   

//remove this function and whenever it's call for production. this is only for testing purpose.
add_limited_tesla_gun()
{

	weapon_spawns = GetEntArray( "weapon_upgrade", "targetname" ); 

	for( i = 0; i < weapon_spawns.size; i++ )
	{
		hint_string = weapon_spawns[i].zombie_weapon_upgrade; 
		if(hint_string == "tesla_gun")
		{
			weapon_spawns[i] waittill("trigger");
			weapon_spawns[i] trigger_off();
			break;

		}
		
	}

}


add_limited_weapon( weapon_name, amount )
{
	if( !IsDefined( level.limited_weapons ) )
	{
		level.limited_weapons = [];
	}

	level.limited_weapons[weapon_name] = amount;
}                                          	

// For pay turrets
init_pay_turret()
{
	pay_turrets = [];
	pay_turrets = GetEntArray( "pay_turret", "targetname" );
	
	for( i = 0; i < pay_turrets.size; i++ )
	{
		cost = level.pay_turret_cost;
		if( !isDefined( cost ) )
		{
			cost = 1000;
		}
		pay_turrets[i] SetHintString( &"ZOMBIE_PAY_TURRET", cost );
		pay_turrets[i] SetCursorHint( "HINT_NOICON" );
		pay_turrets[i] UseTriggerRequireLookAt();
		
		pay_turrets[i] thread pay_turret_think( cost );
	}
}

// For buying weapon upgrades in the environment
init_weapon_upgrade()
{
	weapon_spawns = [];
	weapon_spawns = GetEntArray( "weapon_upgrade", "targetname" ); 

	for( i = 0; i < weapon_spawns.size; i++ )
	{
		hint_string = get_weapon_hint( weapon_spawns[i].zombie_weapon_upgrade ); 

		weapon_spawns[i] SetHintString( hint_string ); 
		weapon_spawns[i] setCursorHint( "HINT_NOICON" ); 
		weapon_spawns[i] UseTriggerRequireLookAt();

		weapon_spawns[i] thread weapon_spawn_think(); 
		model = getent( weapon_spawns[i].target, "targetname" ); 
		model hide(); 
	}
}

// weapon cabinets which open on use
init_weapon_cabinet()
{
	// the triggers which are targeted at doors
	weapon_cabs = GetEntArray( "weapon_cabinet_use", "targetname" ); 

	for( i = 0; i < weapon_cabs.size; i++ )
	{

		weapon_cabs[i] SetHintString( &"ZOMBIE_CABINET_OPEN_1500" ); 
		weapon_cabs[i] setCursorHint( "HINT_NOICON" ); 
		weapon_cabs[i] UseTriggerRequireLookAt();
	}

	array_thread( weapon_cabs, ::weapon_cabinet_think ); 
}

// returns the trigger hint string for the given weapon
get_weapon_hint( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	return level.zombie_weapons[weapon_name].hint;
}

get_weapon_cost( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	return level.zombie_weapons[weapon_name].cost;
}

get_ammo_cost( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );

	return level.zombie_weapons[weapon_name].ammo_cost;
}

get_is_in_box( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );
	
	return level.zombie_weapons[weapon_name].is_in_box;
}

is_weapon_upgraded( weaponname )
{
	if( !isdefined( weaponname ) )
	{
		return false;
	}

	weaponname = ToLower( weaponname );

	upgraded = issubstr( weaponname, "_upgraded" );

	return upgraded;

}

has_upgrade( weaponname )
{
	has_upgrade = false;
	if( IsDefined( level.zombie_include_weapons[weaponname+"_upgraded"] ) )
	{
		has_upgrade = self HasWeapon( weaponname+"_upgraded" );
	}
	return has_upgrade;
}

has_weapon_or_upgrade( weaponname )
{
	has_weapon = false;
	if (self maps\_laststand::player_is_in_laststand())
	{
		for( m = 0; m < self.weaponInventory.size; m++ )
		{
			if (self.weaponInventory[m] == weaponname || self.weaponInventory[m] == weaponname+"_upgraded" )
			{
				has_weapon = true;
			}
		}
	}
	else
	{
		// If the weapon you're checking doesn't exist, it will return undefined
		if( IsDefined( level.zombie_include_weapons[weaponname] ) )
		{
			has_weapon = self HasWeapon( weaponname );
		}
	
		if( !has_weapon && isdefined( level.zombie_include_weapons[weaponname+"_upgraded"] ) )
		{
			has_weapon = self HasWeapon( weaponname+"_upgraded" );
		}
	}

	return has_weapon;
}

using_weapon_or_upgrade( weaponname )
{
	if( self GetCurrentWeapon() == weaponname || self GetCurrentWeapon() == weaponname+"_upgraded" )
	{
		return true;
	}
	return false;
}

// for the random weapon chest
treasure_chest_init()
{
	flag_init("moving_chest_enabled");
	flag_init("moving_chest_now");
	flag_init("player_got_teddy");
	
	level.chests = GetEntArray( "treasure_chest_use", "targetname" );

	if (level.chests.size > 1)
	{

		flag_set("moving_chest_enabled");
	
		while ( 1 )
		{
			level.chests = array_randomize(level.chests);

			if( isdefined( level.random_pandora_box_start ) )
				break;
    
			if ( !IsDefined( level.chests[0].script_noteworthy ) || ( level.chests[0].script_noteworthy != "start_chest" ) )
			{
				break;
			}

		}		
		
		level.chest_index = 0;

		while(level.chest_index < level.chests.size)
		{
				
			if( isdefined( level.random_pandora_box_start ) )
				break;

            if(level.chests[level.chest_index].script_noteworthy == "start_chest")
            {
                 break;
            }
            
            level.chest_index++;     
      }

		//init time chest accessed amount.
		
		if(level.script != "nazi_zombie_prototype")
		{
			level.chest_accessed = 0;
		}

		if(level.script == "nazi_zombie_sumpf" || level.script == "nazi_zombie_factory" )
		{
			// Anchor target will grab the weapon spawn point inside the box, so the fx will be centered on it too
			anchor = GetEnt(level.chests[level.chest_index].target, "targetname");
			anchorTarget = GetEnt(anchor.target, "targetname");

			level.pandora_light = Spawn( "script_model", anchorTarget.origin );
			level.pandora_light.angles = anchorTarget.angles + (-90, 0, 0);
			//temp_fx_origin rotateto((-90, (box_origin.angles[1] * -1), 0), 0.05);
			level.pandora_light SetModel( "tag_origin" );
			playfxontag(level._effect["lght_marker"], level.pandora_light, "tag_origin");
		}
		else //Bug von irgend so einem noob gefixt damit das licht wieder wandert
		{
			// Anchor target will grab the weapon spawn point inside the box, so the fx will be centered on it too
			anchor = GetEnt(level.chests[level.chest_index].target, "targetname");
			anchorTarget = GetEnt(anchor.target, "targetname");

			level.pandora_light = Spawn( "script_model", anchorTarget.origin );
			level.pandora_light.angles = (-90, 0, 0);
			level.pandora_light SetModel( "tag_origin" );
			//playfxontag(level._effect["lght_marker"], level.pandora_light, "tag_origin");
		}		
		
		//determine magic box starting location at random or normal
		init_starting_chest_location();
	
	}

	array_thread( level.chests, ::treasure_chest_think );

}

init_starting_chest_location()
{

	for( i = 0; i < level.chests.size; i++ )
	{

		if( isdefined( level.random_pandora_box_start ) && level.random_pandora_box_start == true )
		{
			if( i != 0 )
			{
				level.chests[i] hide_chest();	
			}
			else
			{
				level.chest_index = i;
				unhide_magic_box( i );
			}

		}
		else
		{
			if ( !IsDefined(level.chests[i].script_noteworthy ) || ( level.chests[i].script_noteworthy != "start_chest" ) )
			{
				level.chests[i] hide_chest();	
			}
			else
			{
				level.chest_index = i;
				unhide_magic_box( i );
			}
		}
	}


}

unhide_magic_box( index )
{
	
	//PI CHANGE - altered to allow for more than one piece of rubble
	rubble = getentarray( level.chests[index].script_noteworthy + "_rubble", "script_noteworthy" );
	if ( IsDefined( rubble ) )
	{
		for ( x = 0; x < rubble.size; x++ )
		{
			rubble[x] hide();
		}
		//END PI CHANGE
	}
	else
	{
		println( "^3Warning: No rubble found for magic box" );
	}
}

set_treasure_chest_cost( cost )
{
	level.zombie_treasure_chest_cost = cost;
}

hide_chest()
{
	pieces = self get_chest_pieces();

	for(i=0;i<pieces.size;i++)
	{
		pieces[i] disable_trigger();
		pieces[i] hide();
	}	
}

get_chest_pieces()
{
	// self = trigger

	lid = GetEnt(self.target, "targetname");
	org = GetEnt(lid.target, "targetname");
	box = GetEnt(org.target, "targetname");

	pieces = [];
	pieces[pieces.size] = self;
	pieces[pieces.size] = lid;
	pieces[pieces.size] = org;
	pieces[pieces.size] = box;

	return pieces;
}

play_crazi_sound()
{
	self playlocalsound("laugh_child");
}

show_magic_box(effect)
{
	if(!IsDefined(effect))
	{
	effect=true;
	}
	pieces = self get_chest_pieces();
	for(i=0;i<pieces.size;i++)
	{
		pieces[i] enable_trigger();
	}
	
	// PI_CHANGE_BEGIN - JMA - we want to play another effect on swamp
	anchor = GetEnt(self.target, "targetname");
	anchorTarget = GetEnt(anchor.target, "targetname");

	if(isDefined(level.script) && (level.script != "nazi_zombie_sumpf") && (level.script != "nazi_zombie_factory") )
	{
		playfx( level._effect["poltergeist"],pieces[0].origin);
	}
	else
	{		
	if(effect)
	{
		level.pandora_light.angles = (-90, anchorTarget.angles[1] + 180, 0);
		level.pandora_light moveto(anchorTarget.origin, 0.1);
		wait(1);
		}	
		playfx( level._effect["lght_marker_flare"],level.pandora_light.origin );
//		playfxontag(level._effect["lght_marker_flare"], level.pandora_light, "tag_origin");
	}
	// PI_CHANGE_END
	
	playsoundatposition( "box_poof", pieces[0].origin );
	wait(.5);
	for(i=0;i<pieces.size;i++)
	{
		if( pieces[i].classname != "trigger_use" )
		{
			pieces[i] show();
		}
	}
	pieces[0] playsound ( "box_poof_land" );
	pieces[0] playsound( "couch_slam" );
}

treasure_chest_think()
{	
	cost = 950;
	if( IsDefined( level.zombie_treasure_chest_cost ) )
	{
		cost = level.zombie_treasure_chest_cost;
	}
	else
	{
		cost = self.zombie_cost;
	}

	self set_hint_string( self, "default_treasure_chest_" + cost );
	self setCursorHint( "HINT_NOICON" );

	//self thread decide_hide_show_chest_hint( "move_imminent" );

	// waittill someuses uses this
	user = undefined;
	while( 1 )
	{
		self waittill( "trigger", user ); 
	if( IsDefined( level.zombie_treasure_chest_cost ) )
	{
		cost = level.zombie_treasure_chest_cost;
	}
	else
	{
		cost = self.zombie_cost;
	}
	if(IsDefined(level.firesaleactive)&&level.firesaleactive==true)
	{
		cost=10;
	}
		if( user in_revive_trigger()||(IsDefined(user.haslaserpower)&&user.haslaserpower==true) )
		{
			wait( 0.1 );
			continue;
		}
		// make sure the user is a player, and that they can afford it
		if( is_player_valid( user ) && user.score >= cost )
		{
			user maps\_zombiemode_score::minus_to_player_score( cost ); 
			break; 
		}
		else if ( user.score < cost )
		{
			user thread maps\_zombiemode_perks::play_no_money_perk_dialog();
			continue;	
		}

		wait 0.05; 
	}

	// trigger_use->script_brushmodel lid->script_origin in radiant
	lid = getent( self.target, "targetname" ); 
	weapon_spawn_org = getent( lid.target, "targetname" ); 

	//open the lid
	lid thread treasure_chest_lid_open();

	// SRS 9/3/2008: added to help other functions know if we timed out on grabbing the item
	self.timedOut = false;

	// mario kart style weapon spawning
	weapon_spawn_org thread treasure_chest_weapon_spawn( self, user ); 

	// the glowfx	
	weapon_spawn_org thread treasure_chest_glowfx(); 

	// take away usability until model is done randomizing
	self disable_trigger(); 

	weapon_spawn_org waittill( "randomization_done" ); 

	
if (flag("player_got_teddy"))
	{
	self.grab_weapon_hint = true;
		self.chest_user = user;
		if( maps\_laststand::player_any_player_in_laststand() == true)
		{
		self sethintstring( "Press F to revive the Teddy!" ); 
		self setvisibletoall();
		}
		else
		{
		self sethintstring( "Press F to try your LUCK!" ); 
		self setvisibletoplayer(user);
		}
		self setCursorHint( "HINT_NOICON" ); 
		//self setvisibletoplayer( user );

		self enable_trigger(); 
		self thread treasure_chest_timeout();

		// make sure the guy that spent the money gets the item
		// SRS 9/3/2008: ...or item goes back into the box if we time out
		while( 1 )
		{
			self waittill( "trigger", grabber ); 

			if(maps\_laststand::player_any_player_in_laststand()|| grabber == user || grabber == level ||self.canbetakenbyall==true)
			{
				if( (maps\_laststand::player_any_player_in_laststand()||grabber == user||self.canbetakenbyall==true) && is_player_valid( user ) && user GetCurrentWeapon() != "mine_bouncing_betty" && !IsDefined( user.is_drinking )&&grabber!=level&&(!IsDefined(grabber.haslaserpower)||grabber.haslaserpower==false) )
				{
					//if( maps\_laststand::player_any_player_in_laststand() == false){
					
					self.isgambling=false;
					self random_teddy(grabber,lid);
					if(self.isgambling==true) 
					{
						self sethintstring( &"ZOMBIE_TRADE_WEAPONS" );
						self waittill( "trigger", grabber ); 
						grabber thread treasure_chest_give_weapon( self.currentweapon );
						self.isgambling=false;
					}
					self notify( "user_grabbed_weapon" );
					self.dontdelete=false;
					break;
				}
				else if( grabber == level )
				{
					// it timed out
					self.timedOut = true;
					break;
				}
			}

			wait 0.05; 
		}
		wait 0.1;
		if(!Flag("moving_chest_now"))
		{
			self.grab_weapon_hint = false;

			weapon_spawn_org notify( "weapon_grabbed" );
			self disable_trigger();

			// spend cash here...
			// give weapon here...
			lid thread treasure_chest_lid_close( self.timedOut );

			//Chris_P
			//magic box dissapears and moves to a new spot after a predetermined number of uses

			wait 3;
			if(!IsDefined(self.isblocked)||self.isblocked==false)
			{
				self enable_trigger();
				self setvisibletoall();
			}
		}
	}
	else
	{
		// Let the player grab the weapon and re-enable the box //

		self.grab_weapon_hint = true;
		self.chest_user = user;
		self sethintstring( &"ZOMBIE_TRADE_WEAPONS" ); 
		self setCursorHint( "HINT_NOICON" ); 
		self setvisibletoplayer( user );

		self enable_trigger(); 
		self thread treasure_chest_timeout();

		// make sure the guy that spent the money gets the item
		// SRS 9/3/2008: ...or item goes back into the box if we time out
		oncehacked=false;
		while( 1 )
		{
			self waittill( "trigger", bgrabber ); 
			grabber=bgrabber;
			if(grabber maps\_zombiemode::can_hack(self)&&(grabber == user||self.canbetakenbyall==true)&&oncehacked==false)
			{
				success = grabber maps\_zombiemode::hack(self,3);
				if(success)
				{
					oncehacked=true;
					self.weaponmodel moveto( weapon_spawn_org.origin +( 0, 0, 40 ), 3, 2, 0.9 ); 
					self.weaponmodel SetModel("zombie_teddybear");
					self.weaponmodel.angles = weapon_spawn_org.angles;
					self sethintstring( "Press F to Try your LUCK!" ); 
					self setvisibletoall();
					self waittill( "trigger", ograbber ); 
					grabber=ograbber;
					if(grabber!=level)
					{
						self random_teddy(grabber,lid,true);
						self.dontdelete=false;
						self sethintstring( &"ZOMBIE_TRADE_WEAPONS" ); 
						self setvisibletoplayer( user );
						modelname = GetWeaponModel( weapon_spawn_org.weapon_string );
						self.weaponmodel SetModel(modelname);
						self.weaponmodel.angles = weapon_spawn_org.angles +( 0, 90, 0 );
						continue;
					}
				}
				else
				{
					continue;
				}
			}
			if( grabber == user || grabber == level||self.canbetakenbyall==true )
			{
				if((self.canbetakenbyall==true|| grabber == user) && is_player_valid( user ) && user GetCurrentWeapon() != level.hacker&& user GetCurrentWeapon() != "mine_bouncing_betty"&&grabber!=level )
				{
				if(grabber!=user)
				{
				user achievement_notify("DLC3_ZOMBIE_GAVE_WEAPON");
				user iprintln(grabber.playername + " took your weapon.");
				grabber iprintln("You took " + user.playername + "'s Weapon.");
				}
					bbPrint( "zombie_uses: playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type magic_accept",
						user.playername, user.score, level.round_number, cost, weapon_spawn_org.weapon_string, self.origin );
					self notify( "user_grabbed_weapon" );
					grabber thread treasure_chest_give_weapon( weapon_spawn_org.weapon_string );
					break; 
				}
				else if( grabber == level )
				{
					// it timed out
					self.timedOut = true;
					bbPrint( "zombie_uses: playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type magic_reject",
						user.playername, user.score, level.round_number, cost, weapon_spawn_org.weapon_string, self.origin );
					break;
				}
			}

			wait 0.05; 
		}
		wait(0.1);
		if(!Flag("moving_chest_now"))
		{
		self.grab_weapon_hint = false;

		weapon_spawn_org notify( "weapon_grabbed" );

		//increase counter of amount of time weapon grabbed.
		
		if(level.script != "nazi_zombie_prototype")
		{
			level.chest_accessed += 1;
			
			// PI_CHANGE_BEGIN
			// JMA - we only update counters when it's available
			if( isDefined(level.script) && level.script == "nazi_zombie_sumpf" && level.box_moved == true && isDefined(level.pulls_since_last_ray_gun) )
			{
				level.pulls_since_last_ray_gun += 1;
			}
			
			if( isDefined(level.script) && level.script == "nazi_zombie_sumpf" && isDefined(level.pulls_since_last_tesla_gun) )
			{				
				level.pulls_since_last_tesla_gun += 1;
			}
			// PI_CHANGE_END
		}
		
		self disable_trigger();

		// spend cash here...
		// give weapon here...
		lid thread treasure_chest_lid_close( self.timedOut );

		//Chris_P
		//magic box dissapears and moves to a new spot after a predetermined number of uses

		wait 3;
		if(!IsDefined(self.isblocked)||self.isblocked==false)
		{
		self enable_trigger();
		self setvisibletoall();
		}
		
		}
	}
	
	self thread treasure_chest_think();
}


//
//	Disable trigger if can't buy weapon and also if someone else is using the chest
decide_hide_show_chest_hint( endon_notify )
{
	if( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}

	while( true )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			// chest_user defined if someone bought a weapon spin, false when chest closed
			if ( (IsDefined(self.chest_user) && players[i] != self.chest_user ) ||
				 !players[i] can_buy_weapon() )
			{
				self SetInvisibleToPlayer( players[i], true );
			}
			else
			{
				self SetInvisibleToPlayer( players[i], false );
			}
		}
		wait( 0.1 );
	}
}

decide_hide_show_hint( endon_notify )
{
	if( isDefined( endon_notify ) )
	{
		self endon( endon_notify );
	}

	while( true )
	{
		players = get_players();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] can_buy_weapon() )
			{
				self SetInvisibleToPlayer( players[i], false );
			}
			else
			{
				self SetInvisibleToPlayer( players[i], true );
			}
		}
		wait( 0.1 );
	}
}

can_buy_weapon()
{
	if( isDefined( self.is_drinking ) && self.is_drinking )
	{
		return false;
	}
	if( self GetCurrentWeapon() == "mine_bouncing_betty" )
	{
		return false;
	}
	if( self in_revive_trigger() )
	{
		return false;
	}
	
	return true;
}

treasure_chest_move_vo()
{

	self endon("disconnect");

	index = maps\_zombiemode_weapons::get_player_index(self);
	sound = undefined;

	if(!isdefined (level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}
	variation_count = 5;
	sound = "plr_" + index + "_vox_box_move" + "_" + randomintrange(0, variation_count);


	//This keeps multiple voice overs from playing on the same player (both killstreaks and headshots).
	if (level.player_is_speaking != 1 && isDefined(sound))
	{	
		level.player_is_speaking = 1;
		self playsound(sound, "sound_done");			
		self waittill("sound_done");
		level.player_is_speaking = 0;
	}

}


treasure_chest_move(lid)
{
	//level waittill("weapon_fly_away_start");
wait(1);
	players = get_players();
	
	array_thread(players, ::play_crazi_sound);

	//level waittill("weapon_fly_away_end");
wait(3);
flag_clear("moving_chest_now");
	lid thread treasure_chest_lid_close(false);
	self setvisibletoall();

	fake_pieces = [];
	pieces = self get_chest_pieces();

	for(i=0;i<pieces.size;i++)
	{
		if(pieces[i].classname == "script_model")
		{
			fake_pieces[fake_pieces.size] = spawn("script_model",pieces[i].origin);
			fake_pieces[fake_pieces.size - 1].angles = pieces[i].angles;
			fake_pieces[fake_pieces.size - 1] setmodel(pieces[i].model);
			pieces[i] disable_trigger();
			pieces[i] hide();
		}
		else
		{
			pieces[i] disable_trigger();
			pieces[i] hide();
		}
	}

	anchor = spawn("script_origin",fake_pieces[0].origin);
	soundpoint = spawn("script_origin", anchor.origin);
    playfx( level._effect["poltergeist"],anchor.origin);

	anchor playsound("box_move");
	for(i=0;i<fake_pieces.size;i++)
	{
		fake_pieces[i] linkto(anchor);
	}

	playsoundatposition ("whoosh", soundpoint.origin );
	playsoundatposition ("ann_vox_magicbox", soundpoint.origin );


	anchor moveto(anchor.origin + (0,0,50),5);
	//anchor rotateyaw(360 * 10,5,5);
	if(level.chests[level.chest_index].script_noteworthy == "magic_box_south" || level.chests[level.chest_index].script_noteworthy == "magic_box_bathroom" || level.chests[level.chest_index].script_noteworthy == "magic_box_hallway")
	{
		anchor Vibrate( (50, 0, 0), 10, 0.5, 5 );
	}
	else if(level.script != "nazi_zombie_sumpf")
	{
		anchor Vibrate( (0, 50, 0), 10, 0.5, 5 );
	}
	else
	{
	   //Get the normal of the box using the positional data of the box and lid
	   direction = pieces[3].origin - pieces[1].origin;
	   direction = (direction[1], direction[0], 0);
	   
	   if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0))
	   {
            direction = (direction[0], direction[1] * -1, 0);
       }
       else if(direction[0] < 0)
       {
            direction = (direction[0] * -1, direction[1], 0);
       }
	   
        anchor Vibrate( direction, 10, 0.5, 5);
	}
	
	//anchor thread rotateroll_box();
	anchor waittill("movedone");
	//players = get_players();
	//array_thread(players, ::play_crazi_sound);
	//wait(3.9);
	
	playfx(level._effect["poltergeist"], anchor.origin);
	
	//TUEY - Play the 'disappear' sound
	playsoundatposition ("box_poof", soundpoint.origin);
	for(i=0;i<fake_pieces.size;i++)
	{
		fake_pieces[i] delete();
	}


	//gzheng-Show the rubble
	//PI CHANGE - allow for more than one object of rubble per box
	rubble = getentarray(self.script_noteworthy + "_rubble", "script_noteworthy");
	
	if ( IsDefined( rubble ) )
	{
		for (i = 0; i < rubble.size; i++)
		{
			rubble[i] show();
		}
	}
	else
	{
		println( "^3Warning: No rubble found for magic box" );
	}

	wait(0.1);
	anchor delete();
	soundpoint delete();

	old_chest_index = level.chest_index;

	wait(5);

	//chest moving logic
	//PI CHANGE - for sumpf, this doesn't work because chest_index is always incremented twice (here and line 724) - while this would work with an odd number of chests, 
	//		     with an even number it skips half of the chest locations in the map

	level.verify_chest = false;
	//wait(3);
	//make sure level is asylum, factory, or sumpf and make magic box only appear in location player have open, it's off by default
	//also make sure box doesn't respawn in old location.
	//PI WJB: removed check on "magic_box_explore_only" dvar because it is only ever used here and when it is set in _zombiemode.gsc line 446
	// where it is declared and set to 0, causing this while loop to never happen because the check was to see if it was equal to 1
	if( level.script == "nazi_zombie_asylum" || level.script == "nazi_zombie_factory" || level.script == "nazi_zombie_sumpf")
	{
		level.chest_index++;

	/*	while(level.chests[level.chest_index].origin == level.chests[old_chest_index].origin)
		{	
			level.chest_index++;
		}*/

		if (level.chest_index >= level.chests.size)
		{
			//PI CHANGE - this way the chests won't move in the same order the second time around
			temp_chest_name = level.chests[level.chest_index - 1].script_noteworthy;
			level.chest_index = 0;
			level.chests = array_randomize(level.chests);
			//in case it happens to randomize in such a way that the chest_index now points to the same location
			// JMA - want to avoid an infinite loop, so we use an if statement
			if (temp_chest_name == level.chests[level.chest_index].script_noteworthy)
			{
				level.chest_index++;
			}
			//END PI CHANGE
		}

		//verify_chest_is_open();
		wait(0.01);
			
	}
	level.chests[level.chest_index] show_magic_box();
	
	//turn off magic box light.
	level notify("magic_box_light_switch");
	//PI CHANGE - altered to allow for more than one object of rubble per box
	unhide_magic_box( level.chest_index );
	
}

rotateroll_box()
{
	angles = 40;
	angles2 = 0;
	//self endon("movedone");
	while(isdefined(self))
	{
		self RotateRoll(angles + angles2, 0.5);
		wait(0.7);
		angles2 = 40;
		self RotateRoll(angles * -2, 0.5);
		wait(0.7);
	}
	


}
//verify if that magic box is open to players or not.
verify_chest_is_open()
{

	//for(i = 0; i < 5; i++)
	//PI CHANGE - altered so that there can be more than 5 valid chest locations
	for (i = 0; i < level.open_chest_location.size; i++)
	{
		if(isdefined(level.open_chest_location[i]))
		{
			if(level.open_chest_location[i] == level.chests[level.chest_index].script_noteworthy)
			{
				level.verify_chest = true;
				return;		
			}
		}

	}

	level.verify_chest = false;


}


treasure_chest_timeout()
{
	self endon( "user_grabbed_weapon" );

	wait( 6 );
	//self disable_trigger();
	self.canbetakenbyall=true;
	//wait( 0.1 );
	self sethintstring( &"ZOMBIE_TRADE_WEAPONS" ); 
		self setCursorHint( "HINT_NOICON" ); 
		self setvisibletoall();
		//self enable_trigger();
	wait( 6 );
	self notify( "trigger", level ); 
}

treasure_chest_lid_open()
{
	openRoll = 105;
	openTime = 0.5;
	self.isopen=true;
	self RotateRoll( 105, openTime, ( openTime * 0.5 ) );

	play_sound_at_pos( "open_chest", self.origin );
	play_sound_at_pos( "music_chest", self.origin );
}

treasure_chest_lid_close( timedOut )
{
	closeRoll = -105;
	closeTime = 0.5;
	self.isopen=false;
	self RotateRoll( closeRoll, closeTime, ( closeTime * 0.5 ) );
	play_sound_at_pos( "close_chest", self.origin );
}

treasure_chest_ChooseRandomWeapon( player )
{

	keys = GetArrayKeys( level.zombie_weapons );

	// Filter out any weapons the player already has
	filtered = [];
	for( i = 0; i < keys.size; i++ )
	{
		if( !get_is_in_box( keys[i] ) )
		{
			continue;
		}
		
		if( player has_weapon_or_upgrade( keys[i] ) )
		{
			continue;
		}

		if( !IsDefined( keys[i] ) )
		{
			continue;
		}

		filtered[filtered.size] = keys[i];
	}
	
	// Filter out the limited weapons
	if( IsDefined( level.limited_weapons ) )
	{
		keys2 = GetArrayKeys( level.limited_weapons );
		players = get_players();
		pap_triggers = GetEntArray("zombie_vending_upgrade", "targetname");
		for( q = 0; q < keys2.size; q++ )
		{
			count = 0;
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] has_weapon_or_upgrade( keys2[q] ) )
				{
					count++;
				}
			}

			// Check the pack a punch machines to see if they are holding what we're looking for
			for ( k=0; k<pap_triggers.size; k++ )
			{
				if ( IsDefined(pap_triggers[k].current_weapon) && pap_triggers[k].current_weapon == keys2[q] )
				{
					count++;
				}
			}

			if( count >= level.limited_weapons[keys2[q]] )
			{
				filtered = array_remove( filtered, keys2[q] );
			}
		}
	}

	return filtered[RandomInt( filtered.size )];
}

treasure_chest_ChooseWeightedRandomWeapon( player )
{

	keys = GetArrayKeys( level.zombie_weapons );

	// Filter out any weapons the player already has
	filtered = [];
	for( i = 0; i < keys.size; i++ )
	{
		if( !get_is_in_box( keys[i] ) )
		{
			continue;
		}
		
		if( player has_weapon_or_upgrade( keys[i] ) )
		{
			continue;
		}

		if( !IsDefined( keys[i] ) )
		{
			continue;
		}

		num_entries = [[ level.weapon_weighting_funcs[keys[i]] ]]();
		
		if((keys[i]=="tesla_gun"||keys[i]=="ray_gun"||keys[i]=="zombie_cymbal_monkey")&&player.adpl)
		{
			num_entries = num_entries * 30;
			//self WriteScreenText(num_entries + " Times");
		}
		for( j = 0; j < num_entries; j++ )
		{
			filtered[filtered.size] = keys[i];
		}
	}
	
	// Filter out the limited weapons
	if( IsDefined( level.limited_weapons ) )
	{
		keys2 = GetArrayKeys( level.limited_weapons );
		players = get_players();
		pap_triggers = GetEntArray("zombie_vending_upgrade", "targetname");
		for( q = 0; q < keys2.size; q++ )
		{
			count = 0;
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] has_weapon_or_upgrade( keys2[q] ) )
				{
					count++;
				}
			}

			// Check the pack a punch machines to see if they are holding what we're looking for
			for ( k=0; k<pap_triggers.size; k++ )
			{
				if ( IsDefined(pap_triggers[k].current_weapon) && pap_triggers[k].current_weapon == keys2[q] )
				{
					count++;
				}
			}

			if( count >= level.limited_weapons[keys2[q]] )
			{
				filtered = array_remove( filtered, keys2[q] );
			}
		}
	}
	
	return filtered[RandomInt( filtered.size )];
}

treasure_chest_weapon_spawn( chest, player )
{
	assert(IsDefined(player));
	// spawn the model
	model = spawn( "script_model", self.origin ); 
	model.angles = self.angles +( 0, 90, 0 );
	chest.weaponmodel = model;
	floatHeight = 40;

	//move it up
	model moveto( model.origin +( 0, 0, floatHeight ), 3, 2, 0.9 ); 

	// rotation would go here

	// make with the mario kart
	modelname = undefined; 
	rand = undefined; 
	number_cycles = 40;
	for( i = 0; i < number_cycles; i++ )
	{

		if( i < 20 )
		{
			wait( 0.05 ); 
		}
		else if( i < 30 )
		{
			wait( 0.1 ); 
		}
		else if( i < 35 )
		{
			wait( 0.2 ); 
		}
		else if( i < 38 )
		{
			wait( 0.3 ); 
		}

		if( i+1 < number_cycles )
		{
			rand = treasure_chest_ChooseRandomWeapon( player );
		}
		else
		{
			rand = treasure_chest_ChooseWeightedRandomWeapon( player );
		}

		/#
		if( maps\_zombiemode_tesla::tesla_gun_exists() )	
		{
			if ( i == 39 && GetDvar( "scr_spawn_tesla" ) != "" )
			{
				SetDvar( "scr_spawn_tesla", "" );
				rand = "tesla_gun";
			}
		}
		#/

		modelname = GetWeaponModel( rand );
		model setmodel( modelname ); 


	}

	self.weapon_string = rand; // here's where the org get it's weapon type for the give function

	// random change of getting the joker that moves the box
	random = Randomint(100);

	if( !isdefined( level.chest_min_move_usage ) )
	{
		level.chest_min_move_usage = 4;
	}

	//increase the chance of joker appearing from 0-100 based on amount of the time chest has been opened.
	if(level.script != "nazi_zombie_prototype" && getdvar("magic_chest_movable") == "1")
	{

		if(level.chest_accessed < level.chest_min_move_usage)
		{		
			// PI_CHANGE_BEGIN - JMA - RandomInt(100) can return a number between 0-99.  If it's zero and chance_of_joker is zero
			//									we can possibly have a teddy bear one after another.
			chance_of_joker = -1;
			// PI_CHANGE_END
		}
		else
		{
			chance_of_joker = level.chest_accessed + 20;
			
			// make sure teddy bear appears on the 8th pull if it hasn't moved from the initial spot
			if( (!isDefined(level.magic_box_first_move) || level.magic_box_first_move == false ) && level.chest_accessed >= 8)
			{
				chance_of_joker = 100;
			}
			
			// pulls 4 thru 8, there is a 15% chance of getting the teddy bear
			// NOTE:  this happens in all cases
			if( level.chest_accessed >= 4 && level.chest_accessed < 8 )
			{
				if( random < 15 )
				{
					chance_of_joker = 100;
				}
				else
				{
					chance_of_joker = -1;
				}
			}
			
			// after the first magic box move the teddy bear percentages changes
			if( isDefined(level.magic_box_first_move) && level.magic_box_first_move == true )
			{
				// between pulls 8 thru 12, the teddy bear percent is 30%
				if( level.chest_accessed >= 8 && level.chest_accessed < 13 )
				{
					if( random < 30 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}
				
				// after 12th pull, the teddy bear percent is 50%
				if( level.chest_accessed >= 13 )
				{
					if( random < 50 )
					{
						chance_of_joker = 100;
					}
					else
					{
						chance_of_joker = -1;
					}
				}
			}
		}
// maps\_laststand::player_any_player_in_laststand() == true

		if (random <= chance_of_joker||level.onlyteddy==true)
		{
		if(!IsDefined(level.firesaleactive)||level.firesaleactive==false)
		{
			model SetModel("zombie_teddybear");
			model.script_noteworthy = "teddy";
		//	model rotateto(level.chests[level.chest_index].angles, 0.01);
			//wait(1);
			model.angles = self.angles;		
			wait 1;
			flag_set("player_got_teddy");
			}
		}
	}

	self notify( "randomization_done" );
if (flag("player_got_teddy"))
	{
		model thread timer_til_despawn(floatHeight,1);
		self thread chestmodeldeletetimer();
		level waittill( "deletemodel" );
		wait 0.5;
		if( (!chest.timedOut)&&(!flag("moving_chest_now")) )
		{
			model Delete();
		}
	if (flag("moving_chest_now"))
	{
	level.chest_accessed=0;
		level notify("weapon_fly_away_start");
		wait 2;
		model MoveZ(500, 4, 3);
		model waittill("movedone");
		model delete();
		self notify( "box_moving" );
		level notify("weapon_fly_away_end");
		}
	}
	else
	{

		//turn off power weapon, since player just got one
		if( rand == "tesla_gun" || rand == "ray_gun" )
		{
			// PI_CHANGE_BEGIN - JMA - reset the counters for tesla gun and ray gun pulls
			if( isDefined( level.script ) && (level.script == "nazi_zombie_sumpf" || level.script == "nazi_zombie_factory") )
			{
				if( rand == "ray_gun" )
				{
					level.box_moved = false;
					level.pulls_since_last_ray_gun = 0;
				}
				
				if( rand == "tesla_gun" )
				{
					level.pulls_since_last_tesla_gun = 0;
					level.player_seen_tesla_gun = true;
				}			
			}
			else
			{
				level.box_moved = false;
			}
			// PI_CHANGE_END			
		}

		model thread timer_til_despawn(floatHeight);
		self waittill( "weapon_grabbed" );

		if( !chest.timedOut )
		{
			model Delete();
		}


	}
}
chestmodeldeletetimer()
{
level endon("deletemodel");
self waittill( "weapon_grabbed" );
level notify( "deletemodel" );
}
timer_til_despawn(floatHeight,dontmove)
{


	// SRS 9/3/2008: if we timed out, move the weapon back into the box instead of deleting it
	putBackTime = 12;
	self.dontdelete=false;
	if(dontmove==0)
	{
	self MoveTo( self.origin - ( 0, 0, floatHeight ), putBackTime, ( putBackTime * 0.5 ) );
	wait( putBackTime/2 );
	self playsound( "packa_weap_ready" );
	wait(0.4);
	self playsound( "packa_weap_ready" );
	wait( putBackTime/2-0.4 );
	}
	else
	{
	wait( putBackTime );
	}
	if(!self.dontdelete)
	{
	level notify( "teddytimeout" );
	self MoveTo( self.origin - ( 0, 0, floatHeight ), 0.3, ( 0.2 ) );
	self waittill("movedone");
	if(isdefined(self))
	{	
	
		self Delete();
	}
	}
}

treasure_chest_glowfx()
{
	fxObj = spawn( "script_model", self.origin +( 0, 0, 0 ) ); 
	fxobj setmodel( "tag_origin" ); 
	fxobj.angles = self.angles +( 90, 0, 0 ); 

	playfxontag( level._effect["chest_light"], fxObj, "tag_origin"  ); 

	self waittill_any( "weapon_grabbed", "box_moving" ); 

	fxobj delete(); 
}

// self is the player string comes from the randomization function
treasure_chest_give_weapon( weapon_string )
{
	primaryWeapons = self GetWeaponsListPrimaries(); 
	current_weapon = undefined; 

	if( self HasWeapon( weapon_string ) )
	{
		self GiveMaxAmmo( weapon_string );
		self SwitchToWeapon( weapon_string );
		return;
	}

	// This should never be true for the first time.
	if( primaryWeapons.size >= 2 ) // he has two weapons
	{
		current_weapon = self getCurrentWeapon(); // get hiss current weapon

		if ( current_weapon == "mine_bouncing_betty" )
		{
			current_weapon = undefined;
		}

		if( isdefined( current_weapon ) )
		{
			if( !( weapon_string == "fraggrenade" || weapon_string == "stielhandgranate" || weapon_string == "molotov" || weapon_string == "zombie_cymbal_monkey" ) )
			{
				// PI_CHANGE_BEGIN
				// JMA - player dropped the tesla gun
				if( isDefined(level.script) && (level.script == "nazi_zombie_sumpf" || level.script == "nazi_zombie_factory") )
				{
					if( current_weapon == "tesla_gun" )
					{
						level.player_drops_tesla_gun = true;
					}
				}
				// PI_CHANGE_END
				
				self TakeWeapon( current_weapon ); 
		} 
	} 
	} 

	if( IsDefined( primaryWeapons ) && !isDefined( current_weapon ) )
	{
		for( i = 0; i < primaryWeapons.size; i++ )
		{
			if( primaryWeapons[i] == "zombie_colt" )
			{
				continue; 
			}

			if( weapon_string != "fraggrenade" && weapon_string != "stielhandgranate" && weapon_string != "molotov" && weapon_string != "zombie_cymbal_monkey" )
			{
				// PI_CHANGE_BEGIN
				// JMA - player dropped the tesla gun
				if( isDefined(level.script) && (level.script == "nazi_zombie_sumpf" || level.script == "nazi_zombie_factory") )
				{
					if( primaryWeapons[i] == "tesla_gun" )
					{
						level.player_drops_tesla_gun = true;
					}
				}
				// PI_CHANGE_END
			
				self TakeWeapon( primaryWeapons[i] ); 
			}
		}
	}

	self play_sound_on_ent( "purchase" ); 

	if( weapon_string == "molotov" || weapon_string == "molotov_zombie" )
	{
		// PI_CHANGE_BEGIN
		// JMA 051409 sanity check to see if we have the weapon before we remove it
		has_weapon = self HasWeapon( "zombie_cymbal_monkey" );
		if( isDefined(has_weapon) && has_weapon )
		{
			self TakeWeapon( "zombie_cymbal_monkey" );
		}
		// PI_CHANGE_END
	}
	if( weapon_string == "zombie_cymbal_monkey" )
	{
		// PI_CHANGE_BEGIN
		// JMA 051409 sanity check to see if we have the weapon before we remove it	
		has_weapon = self HasWeapon( "molotov" );
		if( isDefined(has_weapon) && has_weapon )
		{
			self TakeWeapon( "molotov" );
		}

		if( isDefined(level.zombie_weapons) && isDefined(level.zombie_weapons["molotov_zombie"]) )
		{
			has_weapon = self HasWeapon( "molotov_zombie" );
			if( isDefined(has_weapon) && has_weapon )
			{
				self TakeWeapon( "molotov_zombie" );
			}
		}
		// PI_CHANGE_END
		
		self maps\_zombiemode_cymbal_monkey::player_give_cymbal_monkey();
		play_weapon_vo(weapon_string);
		return;
	}

	self GiveWeapon( weapon_string, 0 );
	self GiveMaxAmmo( weapon_string );
	self SwitchToWeapon( weapon_string );

	play_weapon_vo(weapon_string);

	// self playsound (level.zombie_weapons[weapon_string].sound); 
}

weapon_cabinet_think()
{
	weapons = getentarray( "cabinet_weapon", "targetname" ); 

	doors = getentarray( self.target, "targetname" );
	for( i = 0; i < doors.size; i++ )
	{
		doors[i] NotSolid();
	}

	self.has_been_used_once = false; 

	self decide_hide_show_hint();

	while( 1 )
	{
		self waittill( "trigger", player );

		if( !player can_buy_weapon() )
		{
			wait( 0.1 );
			continue;
		}

		cost = 1500;
		if( self.has_been_used_once )
		{
			cost = get_weapon_cost( self.zombie_weapon_upgrade );
		}
		else
		{
			if( IsDefined( self.zombie_cost ) )
			{
				cost = self.zombie_cost;
			}
		}

		ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );

		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if( self.has_been_used_once )
		{
			player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade );
			/*
			player_has_weapon = false;
			weapons = player GetWeaponsList(); 
			if( IsDefined( weapons ) )
			{
				for( i = 0; i < weapons.size; i++ )
				{
					if( weapons[i] == self.zombie_weapon_upgrade )
					{
						player_has_weapon = true; 
					}
				}
			}
			*/

			if( !player_has_weapon )
			{
				if( player.score >= cost )
				{
					self play_sound_on_ent( "purchase" );
					player maps\_zombiemode_score::minus_to_player_score( cost ); 
					player weapon_give( self.zombie_weapon_upgrade ); 
				}
				else // not enough money
				{
					play_sound_on_ent( "no_purchase" );
					player thread maps\_zombiemode_perks::play_no_money_perk_dialog();
				}			
			}
			else if ( player.score >= ammo_cost )
			{
				ammo_given = player ammo_give( self.zombie_weapon_upgrade ); 
				if( ammo_given )
				{
					self play_sound_on_ent( "purchase" );
					player maps\_zombiemode_score::minus_to_player_score( ammo_cost ); // this give him ammo to early
				}
			}
			else // not enough money
			{
				play_sound_on_ent( "no_purchase" );
				player thread maps\_zombiemode_perks::play_no_money_perk_dialog();
			}
		}
		else if( player.score >= cost ) // First time the player opens the cabinet
		{
			self.has_been_used_once = true;

			self play_sound_on_ent( "purchase" ); 

			self SetHintString( &"ZOMBIE_WEAPONCOSTAMMO", cost, ammo_cost ); 
			//		self SetHintString( get_weapon_hint( self.zombie_weapon_upgrade ) );
			self setCursorHint( "HINT_NOICON" ); 
			player maps\_zombiemode_score::minus_to_player_score( self.zombie_cost ); 

			doors = getentarray( self.target, "targetname" ); 

			for( i = 0; i < doors.size; i++ )
			{
				if( doors[i].model == "dest_test_cabinet_ldoor_dmg0" )
				{
					doors[i] thread weapon_cabinet_door_open( "left" ); 
				}
				else if( doors[i].model == "dest_test_cabinet_rdoor_dmg0" )
				{
					doors[i] thread weapon_cabinet_door_open( "right" ); 
				}
			}

			player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade ); 
			/*
			player_has_weapon = false;
			weapons = player GetWeaponsList(); 
			if( IsDefined( weapons ) )
			{
				for( i = 0; i < weapons.size; i++ )
				{
					if( weapons[i] == self.zombie_weapon_upgrade )
					{
						player_has_weapon = true; 
					}
				}
			}
			*/

			if( !player_has_weapon )
			{
				player weapon_give( self.zombie_weapon_upgrade ); 
			}
			else
			{
				if( player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					player ammo_give( self.zombie_weapon_upgrade+"_upgraded" ); 
				}
				else
				{
					player ammo_give( self.zombie_weapon_upgrade ); 
				}
			}	
		}
		else // not enough money
		{
			play_sound_on_ent( "no_purchase" );
			player thread maps\_zombiemode_perks::play_no_money_perk_dialog();
		}		
	}
}

pay_turret_think( cost )
{
	if( !isDefined( self.target ) )
	{
		return;
	}
	turret = GetEnt( self.target, "targetname" );
	
	if( !isDefined( turret ) )
	{
		return;
	}
	
	turret makeTurretUnusable();
	
	while( true )
	{
		self waittill( "trigger", player );
		
		if( !is_player_valid( player ) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if( player in_revive_trigger()||(IsDefined(player.haslaserpower)&&player.haslaserpower==true) )
		{
			wait( 0.1 );
			continue;
		}

		if(isdefined(player.is_drinking))
		{
			wait(0.1);
			continue;
		}
		
		if( player.score >= cost )
		{
			player maps\_zombiemode_score::minus_to_player_score( cost );
			turret makeTurretUsable();
			turret UseBy( player );
			self disable_trigger();
			
			player.curr_pay_turret = turret;
			
			turret thread watch_for_laststand( player );
			turret thread watch_for_fake_death( player );
			if( isDefined( level.turret_timer ) )
			{
				turret thread watch_for_timeout( player, level.turret_timer );
			}
			
			while( isDefined( turret getTurretOwner() ) && turret getTurretOwner() == player )
			{
				wait( 0.05 );
			}
			
			turret notify( "stop watching" );
			
			player.curr_pay_turret = undefined;
			
			turret makeTurretUnusable();
			self enable_trigger();
		}
		else // not enough money
		{
			play_sound_on_ent( "no_purchase" );
			player thread maps\_zombiemode_perks::play_no_money_perk_dialog();
		}
	}
}

watch_for_laststand( player )
{
	self endon( "stop watching" );
	
	while( !player maps\_laststand::player_is_in_laststand() )
	{
		if( isDefined( level.intermission ) && level.intermission )
		{
			intermission = true;
		}
		wait( 0.05 );
	}
	
	if( isDefined( self getTurretOwner() ) && self getTurretOwner() == player )
	{
		self UseBy( player );
	}
}

watch_for_fake_death( player )
{
	self endon( "stop watching" );
	
	player waittill( "fake_death" );
	
	if( isDefined( self getTurretOwner() ) && self getTurretOwner() == player )
	{
		self UseBy( player );
	}
}

watch_for_timeout( player, time )
{
	self endon( "stop watching" );
	
	self thread cancel_timer_on_end( player );
	
	player thread maps\_zombiemode_timer::start_timer( time, "stop watching" );
	
	wait( time );
	
	if( isDefined( self getTurretOwner() ) && self getTurretOwner() == player )
	{
		self UseBy( player );
	}
}

cancel_timer_on_end( player )
{
	self waittill( "stop watching" );
	player notify( "stop watching" );
}

weapon_cabinet_door_open( left_or_right )
{
	if( left_or_right == "left" )
	{
		self rotateyaw( 120, 0.3, 0.2, 0.1 ); 	
	}
	else if( left_or_right == "right" )
	{
		self rotateyaw( -120, 0.3, 0.2, 0.1 ); 	
	}	
}

weapon_spawn_think()
{
	cost = get_weapon_cost( self.zombie_weapon_upgrade );
	ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
	is_grenade = (WeaponType( self.zombie_weapon_upgrade ) == "grenade");
	if(is_grenade)
	{
		ammo_cost = cost;
	}
	if(self.zombie_weapon_upgrade=="zombie_kar98k"||self.zombie_weapon_upgrade=="zombie_m1carbine")
	{
		self SetHintString("Sold Out!");
		return;
	}
	self thread decide_hide_show_hint();

	self.first_time_triggered = false; 
	for( ;; )
	{
		self waittill( "trigger", player ); 		
		// if not first time and they have the weapon give ammo

		if( !is_player_valid( player )||(IsDefined(player.haslaserpower)&&player.haslaserpower==true) )
		{
			player thread ignore_triggers( 0.5 );
			continue;
		}

		if( !player can_buy_weapon() )
		{
			wait( 0.1 );
			continue;
		}

		// Allow people to get ammo off the wall for upgraded weapons
		player_has_weapon = player has_weapon_or_upgrade( self.zombie_weapon_upgrade ); 
		/*
		player_has_weapon = false;
		weapons = player GetWeaponsList(); 
		if( IsDefined( weapons ) )
		{
			for( i = 0; i < weapons.size; i++ )
			{
				if( weapons[i] == self.zombie_weapon_upgrade )
				{
					player_has_weapon = true; 
				}
			}
		}		
		*/

		if( !player_has_weapon )
		{
			// else make the weapon show and give it
			if( player.score >= cost )
			{
				if( self.first_time_triggered == false )
				{
					model = getent( self.target, "targetname" ); 
					//					model show(); 
					model thread weapon_show( player ); 
					self.first_time_triggered = true; 

					if(!is_grenade)
					{
						self SetHintString( &"ZOMBIE_WEAPONCOSTAMMO", cost, ammo_cost ); 
					}
				}

				player maps\_zombiemode_score::minus_to_player_score( cost ); 

				bbPrint( "zombie_uses: playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type weapon",
						player.playername, player.score, level.round_number, cost, self.zombie_weapon_upgrade, self.origin );

				player weapon_give( self.zombie_weapon_upgrade ); 
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
				player thread maps\nazi_zombie_sumpf_blockers::play_no_money_purchase_dialog();
				
			}
		}
		else
		{
			// MM - need to check and see if the player has an upgraded weapon.  If so, the ammo cost is much higher
			if ( player has_upgrade( self.zombie_weapon_upgrade ) )
			{
				ammo_cost = 4500;
			}
			else
			{
				ammo_cost = get_ammo_cost( self.zombie_weapon_upgrade );
			}

			// if the player does have this then give him ammo.
			if( player.score >= ammo_cost )
			{
				if( self.first_time_triggered == false )
				{
					model = getent( self.target, "targetname" ); 
					//					model show(); 
					model thread weapon_show( player ); 
					self.first_time_triggered = true;
					if(!is_grenade)
					{ 
						self SetHintString( &"ZOMBIE_WEAPONCOSTAMMO", cost, get_ammo_cost( self.zombie_weapon_upgrade ) ); 
					}
				}

				if( player HasWeapon( self.zombie_weapon_upgrade ) && player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					ammo_given = player ammo_give( self.zombie_weapon_upgrade, true ); 
				}
				else if( player has_upgrade( self.zombie_weapon_upgrade ) )
				{
					ammo_given = player ammo_give( self.zombie_weapon_upgrade+"_upgraded" ); 
				}
				else
				{
					ammo_given = player ammo_give( self.zombie_weapon_upgrade ); 
				}
				
				if( ammo_given )
				{
						player maps\_zombiemode_score::minus_to_player_score( ammo_cost ); // this give him ammo to early

					bbPrint( "zombie_uses: playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type ammo",
						player.playername, player.score, level.round_number, ammo_cost, self.zombie_weapon_upgrade, self.origin );
				}
			}
			else
			{
				play_sound_on_ent( "no_purchase" );
			}
		}
	}
}

weapon_show( player )
{
	player_angles = VectorToAngles( player.origin - self.origin ); 

	player_yaw = player_angles[1]; 
	weapon_yaw = self.angles[1]; 

	yaw_diff = AngleClamp180( player_yaw - weapon_yaw ); 

	if( yaw_diff > 0 )
	{
		yaw = weapon_yaw - 90; 
	}
	else
	{
		yaw = weapon_yaw + 90; 
	}

	self.og_origin = self.origin; 
	self.origin = self.origin +( AnglesToForward( ( 0, yaw, 0 ) ) * 8 ); 

	wait( 0.05 ); 
	self Show(); 

	play_sound_at_pos( "weapon_show", self.origin, self );

	time = 1; 
	self MoveTo( self.og_origin, time ); 
}

weapon_give( weapon, is_upgrade )
{
	primaryWeapons = self GetWeaponsListPrimaries(); 
	current_weapon = undefined; 

	//if is not an upgraded perk purchase
	if( !IsDefined( is_upgrade ) )
	{
		is_upgrade = false;
	}

	// This should never be true for the first time.
	if( primaryWeapons.size >= 2 ) // he has two weapons
	{
		current_weapon = self getCurrentWeapon(); // get his current weapon

		if ( current_weapon == "mine_bouncing_betty"||current_weapon == level.hacker )
		{
			current_weapon = undefined;
		}

		if( isdefined( current_weapon ) )
		{
			if( !( weapon == "fraggrenade" || weapon == "stielhandgranate" || weapon == "molotov" || weapon == "zombie_cymbal_monkey" ) )
			{
				self TakeWeapon( current_weapon ); 
			}
		} 
	}

	if( weapon == "zombie_cymbal_monkey" )
	{
		// PI_CHANGE_BEGIN
		// JMA 051409 sanity check to see if we have the weapon before we remove it	
		has_weapon = self HasWeapon( "molotov" );
		if( isDefined(has_weapon) && has_weapon )
		{
			self TakeWeapon( "molotov" );
		}

		if( isDefined(level.zombie_weapons) && isDefined(level.zombie_weapons["molotov_zombie"]) )
		{		
			has_weapon = self HasWeapon( "molotov_zombie" );
			if( isDefined(has_weapon) && has_weapon )
			{
				self TakeWeapon( "molotov_zombie" );
			}
		}
		// PI_CHANGE_END
				
		self maps\_zombiemode_cymbal_monkey::player_give_cymbal_monkey();
		play_weapon_vo( weapon );
		return;
	}
	if( (weapon == "molotov" || weapon == "molotov_zombie") )
	{
			self TakeWeapon( "zombie_cymbal_monkey" );
	}

	self play_sound_on_ent( "purchase" );
	self GiveWeapon( weapon, 0 ); 
	self GiveMaxAmmo( weapon ); 
	self SwitchToWeapon( weapon );
	 
	play_weapon_vo(weapon);
}
play_weapon_vo(weapon)
{
	index = get_player_index(self);
	if(!IsDefined (level.zombie_weapons[weapon].sound))
	{
		return;
	}	
	
	if( level.zombie_weapons[weapon].sound == "vox_monkey" )
	{
		plr = "plr_" + index + "_";
		create_and_play_dialog( plr, "vox_monkey", .25, "resp_monk" );
		return;
	}
	//	iprintlnbold (index);
	if( level.zombie_weapons[weapon].sound != "" )
	{
		weap = level.zombie_weapons[weapon].sound;
//		iprintlnbold("Play_Weap_VO_" + weap);
		switch(weap)
		{
			case "vox_crappy":
				if (level.vox_crappy_available.size < 1 )
				{
					level.vox_crappy_available = level.vox_crappy;
				}
				sound_to_play = random(level.vox_crappy_available);
				level.vox_crappy_available = array_remove(level.vox_crappy_available,sound_to_play);
				break;

			case "vox_mg":
				if (level.vox_mg_available.size < 1 )
				{
					level.vox_mg_available = level.vox_mg;
				}
				sound_to_play = random(level.vox_mg_available);
				level.vox_mg_available = array_remove(level.vox_mg_available,sound_to_play);
				break;
			case "vox_shotgun":
				if (level.vox_shotgun_available.size < 1 )
				{
					level.vox_shotgun_available = level.vox_shotgun;
				}
				sound_to_play = random(level.vox_shotgun_available);
				level.vox_shotgun_available = array_remove(level.vox_shotgun_available,sound_to_play);
				break;
			case "vox_357":
				if (level.vox_357_available.size < 1 )
				{
					level.vox_357_available = level.vox_357;
				}
				sound_to_play = random(level.vox_357_available);
				level.vox_357_available = array_remove(level.vox_357_available,sound_to_play);
				break;
			case "vox_bar":
				if (level.vox_bar_available.size < 1 )
				{
					level.vox_bar_available = level.vox_bar;
				}
				sound_to_play = random(level.vox_bar_available);
				level.vox_bar_available = array_remove(level.vox_bar_available,sound_to_play);
				break;
			case "vox_flame":
				if (level.vox_flame_available.size < 1 )
				{
					level.vox_flame_available = level.vox_flame;
				}
				sound_to_play = random(level.vox_flame_available);
				level.vox_flame_available = array_remove(level.vox_flame_available,sound_to_play);
				break;
			case "vox_raygun":
				if (level.vox_raygun_available.size < 1 )
				{
					level.vox_raygun_available = level.vox_raygun;
				}
				sound_to_play = random(level.vox_raygun_available);
				level.vox_raygun_available = array_remove(level.vox_raygun_available,sound_to_play);
				break;
			case "vox_tesla":
				if (level.vox_tesla_available.size < 1 )
				{
					level.vox_tesla_available = level.vox_tesla;
				}
				sound_to_play = random(level.vox_tesla_available);
				level.vox_tesla_available = array_remove(level.vox_tesla_available,sound_to_play);
				break;
			case "vox_sticky":
				if (level.vox_sticky_available.size < 1 )
				{
					level.vox_sticky_available = level.vox_sticky;
				}
				sound_to_play = random(level.vox_sticky_available);
				level.vox_sticky_available = array_remove(level.vox_sticky_available,sound_to_play);
				break;
			case "vox_ppsh":
				if (level.vox_ppsh_available.size < 1 )
				{
					level.vox_ppsh_available = level.vox_ppsh;
				}
				sound_to_play = random(level.vox_ppsh_available);
				level.vox_ppsh_available = array_remove(level.vox_ppsh_available,sound_to_play);
				break;
			case "vox_mp40":
			if (level.vox_mp40_available.size < 1 )
				{
					level.vox_mp40_available = level.vox_mp40;
				}
				sound_to_play = random(level.vox_mp40_available);
				level.vox_mp40_available = array_remove(level.vox_mp40_available,sound_to_play);
				break;					
			
			default: 
				sound_var = randomintrange(0, level.zombie_weapons[weapon].variation_count);
				sound_to_play = level.zombie_weapons[weapon].sound + "_" + sound_var;
				
		}

		plr = "plr_" + index + "_";
		//self playsound ("plr_" + index + "_" + sound_to_play);
		//iprintlnbold (sound_to_play);
		
		//thread setup_response_line( self, index, "monk" );
		self maps\_zombiemode_spawner::do_player_playdialog(plr, sound_to_play, 0.05);
	}
}
do_player_weap_dialog(player_index, sound_to_play, waittime)
{
	if(!IsDefined (level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}
	if(level.player_is_speaking != 1)
	{
		level.player_is_speaking = 1;
		self playsound(player_index + sound_to_play, "sound_done" + sound_to_play);			
		self waittill("sound_done" + sound_to_play);
		wait(waittime);		
		level.player_is_speaking = 0;
	}
	
}
get_player_index(player)
{
	assert( IsPlayer( player ) );
	assert( IsDefined( player.entity_num ) );
/#
	// used for testing to switch player's VO in-game from devgui
	if( player.entity_num == 0 && GetDVar( "zombie_player_vo_overwrite" ) != "" )
	{
		new_vo_index = GetDVarInt( "zombie_player_vo_overwrite" );
		return new_vo_index;
	}
#/
	return player.entity_num;
}

ammo_give( weapon, also_has_upgrade )
{
	// We assume before calling this function we already checked to see if the player has this weapon...

	if( !isDefined( also_has_upgrade ) )
	{
		also_has_upgrade = false;
	}

	// Should we give ammo to the player
	give_ammo = false; 

	// Check to see if ammo belongs to a primary weapon
	if( weapon != "fraggrenade" && weapon != "stielhandgranate" && weapon != "molotov" )
	{
		if( isdefined( weapon ) )  
		{
			// get the max allowed ammo on the current weapon
			stockMax = WeaponMaxAmmo( weapon ); 
			if( also_has_upgrade ) 
			{
				stockMax += WeaponMaxAmmo( weapon+"_upgraded" );
			}

			// Get the current weapon clip count
			clipCount = self GetWeaponAmmoClip( weapon ); 

			currStock = self GetAmmoCount( weapon );

			// compare it with the ammo player actually has, if more or equal just dont give the ammo, else do
			if( ( currStock - clipcount ) >= stockMax )	
			{
				give_ammo = false; 
			}
			else
			{
				give_ammo = true; // give the ammo to the player
			}
		}
	}
	else
	{
		// Ammo belongs to secondary weapon
		if( self has_weapon_or_upgrade( weapon ) )
		{
			// Check if the player has less than max stock, if no give ammo
			if( self getammocount( weapon ) < WeaponMaxAmmo( weapon ) )
			{
				// give the ammo to the player
				give_ammo = true; 					
			}
		}		
	}	

	if( give_ammo )
	{
		self playsound( "cha_ching" ); 
		self GivemaxAmmo( weapon ); 
		if( also_has_upgrade )
		{
			self GiveMaxAmmo( weapon+"_upgraded" );
		}
		return true;
	}

	if( !give_ammo )
	{
		return false;
	}
}
add_weapon_to_sound_array(vo,num)
{
	if(!isDefined(vo))
	{
		return;
	}
	player = getplayers();
	for(i=0;i<player.size;i++)
	{
		index = maps\_zombiemode_weapons::get_player_index(player);
		player_index = "plr_" + index + "_";
		num = maps\_zombiemode_spawner::get_number_variants(player_index + vo);
	}
//	iprintlnbold(vo);

	switch(vo)
	{
		case "vox_crappy":
			if(!isDefined(level.vox_crappy))
			{
				level.vox_crappy = [];
				for(i=0;i<num;i++)
				{
					level.vox_crappy[level.vox_crappy.size] = "vox_crappy_" + i;						
				}				
			}
			level.vox_crappy_available = level.vox_crappy;
			break;

		case "vox_mg":
			if(!isDefined(level.vox_mg))
			{
				level.vox_mg = [];
				for(i=0;i<num;i++)
				{
					level.vox_mg[level.vox_mg.size] = "vox_mg_" + i;						
				}				
			}
			level.vox_mg_available = level.vox_mg;
			break;
		case "vox_shotgun":
			if(!isDefined(level.vox_shotgun))
			{
				level.vox_shotgun = [];
				for(i=0;i<num;i++)
				{
					level.vox_shotgun[level.vox_shotgun.size] = "vox_shotgun_" + i;						
				}				
			}
			level.vox_shotgun_available = level.vox_shotgun;
			break;
		case "vox_357":
			if(!isDefined(level.vox_357))
			{
				level.vox_357 = [];
				for(i=0;i<num;i++)
				{
					level.vox_357[level.vox_357.size] = "vox_357_" + i;						
				}				
			}
			level.vox_357_available = level.vox_357;
			break;
		case "vox_bar":
			if(!isDefined(level.vox_bar))
			{
				level.vox_bar = [];
				for(i=0;i<num;i++)
				{
					level.vox_bar[level.vox_bar.size] = "vox_bar_" + i;						
				}				
			}
			level.vox_bar_available = level.vox_bar;
			break;
		case "vox_flame":
			if(!isDefined(level.vox_flame))
			{
				level.vox_flame = [];
				for(i=0;i<num;i++)
				{
					level.vox_flame[level.vox_flame.size] = "vox_flame_" + i;						
				}				
			}
			level.vox_flame_available = level.vox_flame;
			break;

		case "vox_raygun":
			if(!isDefined(level.vox_raygun))
			{
				level.vox_raygun = [];
				for(i=0;i<num;i++)
				{
					level.vox_raygun[level.vox_raygun.size] = "vox_raygun_" + i;						
				}				
			}
			level.vox_raygun_available = level.vox_raygun;
			break;
		case "vox_tesla":
			if(!isDefined(level.vox_tesla))
			{
				level.vox_tesla = [];
				for(i=0;i<num;i++)
				{
					level.vox_tesla[level.vox_tesla.size] = "vox_tesla_" + i;						
				}				
			}
			level.vox_tesla_available = level.vox_tesla;
			break;
		case "vox_sticky":
			if(!isDefined(level.vox_sticky))
			{
				level.vox_sticky = [];
				for(i=0;i<num;i++)
				{
					level.vox_sticky[level.vox_sticky.size] = "vox_sticky_" + i;						
				}				
			}
			level.vox_sticky_available = level.vox_sticky;
			break;
		case "vox_ppsh":
			if(!isDefined(level.vox_ppsh))
			{
				level.vox_ppsh = [];
				for(i=0;i<num;i++)
				{
					level.vox_ppsh[level.vox_ppsh.size] = "vox_ppsh_" + i;						
				}				
			}
			level.vox_ppsh_available = level.vox_ppsh;
			break;		
		case "vox_mp40":
			if(!isDefined(level.vox_mp40))
			{
				level.vox_mp40 = [];
				for(i=0;i<num;i++)
				{
					level.vox_mp40[level.vox_mp40.size] = "vox_mp40_" + i;						
				}				
			}
			level.vox_mp40_available = level.vox_mp40;
			break;
		case "vox_monkey":
			if(!isDefined(level.vox_monkey))
			{
				level.vox_monkey = [];
				for(i=0;i<num;i++)
				{
					level.vox_monkey[level.vox_monkey.size] = "vox_monkey_" + i;						
				}				
			}
			level.vox_monkey_available = level.vox_monkey;
			break;	
	}

}

//-------------------------------------------------------------------------
//                         ALL THE CRAP FOR TEDDY
//-------------------------------------------------------------------------

random_teddy(grabber,lid,hacked)
{
self.dontdelete=true;
self disable_trigger(); 
if(!IsDefined(hacked))
{
	hacked=false;
}
if(IsDefined( level.teddymode)&&level.teddymode!=0)
{
myrandom = level.teddymode;
}
else
{
myrandom = Randomint(65);
}
if( maps\_laststand::player_any_player_in_laststand() == true)
{
self.dontdelete=false;
self enable_trigger(); 
teddy = GetEntArray( "teddy", "script_noteworthy" ); 
teddy[0].isteddy=true;
self WriteScreenText("Teddy revived everyone!");
maps\_laststand::revive_all_players(grabber,teddy[0]);
wait(1);
}
else if( level.box_moved_once != true  && myrandom >10&&!hacked)
{
self thread move_chest_start(grabber,lid);
}
else if(myrandom<7)
{
	powerup = spawn ("script_model", self.origin);
	powerup maps\_zombiemode_powerups::powerup_setup();
	powerup thread maps\_zombiemode_powerups::powerup_timeout();
	powerup thread maps\_zombiemode_powerups::powerup_wobble();
	powerup thread maps\_zombiemode_powerups::powerup_grab();
}
else if(myrandom<10)
{
lid play_sound_on_ent( "purchase" );
grabber maps\_zombiemode_score::add_to_player_score( 5000 );
}
else if (myrandom<11)
{
grabber treasure_chest_move_vo();
player_noammo_powerup( self, grabber );
}
else if (myrandom<12)
{
grabber treasure_chest_move_vo();
all_noammo_powerup( self );
}
else if (myrandom<14)
{
player_godmode_powerup( self, grabber );
}
else if (myrandom<16)
{
self WriteScreenText("Teddy is repairing all Windows for 30 sec...");
self RepairAllWindows();
}
else if (myrandom<19)
{
unlimited_ammo_powerup( self );
}
else if(myrandom<24)
{
self maps\_zombiemode_perks::give_random_perk( grabber );
}
//else if(myrandom<26)
//{
//teddy = GetEntArray( "teddy", "script_noteworthy" ); 
//teddy.isteddy=true;
//self thread Activate_All_Traps(teddy,grabber);
//}
else if(myrandom<27)
{
self WriteScreenText("Teddy gave you 3 free Teleporter Tickets!");
if(!IsDefined(grabber.freeziplineticket))
{
grabber.freeteleticket=0;
}
grabber.freeteleticket=grabber.freeteleticket+3;
}
else if(myrandom<28)
{
self WriteScreenText("Teddy gave you 3 free Trap Tickets!");
if(!IsDefined(grabber.freetrapticket))
{
grabber.freetrapticket=0;
}
grabber.freetrapticket=grabber.freetrapticket+3;
}
else if(myrandom<29)
{
self WriteScreenText("Teddy powered up your betties for 60 sec.");
self PowerupBetties();
}
else if(myrandom<31)
{
self TeddyExplode(grabber,lid);
}
else if(myrandom<33)
{
primaryWeapons = grabber GetWeaponsListPrimaries(); 
	
	if( primaryWeapons.size <3 )
	{
WriteScreenText("Teddy gave you another Weapon slot!");
weapon="walther";
grabber.hasthirdweapon=true;
grabber play_sound_on_ent( "purchase" );
	grabber GiveWeapon( weapon, 0 ); 
	grabber GiveMaxAmmo( weapon ); 
	grabber SwitchToWeapon( weapon ); 
	grabber play_weapon_vo("zombie_ppsh");
	}
	else
	{
	//WriteScreenText("Teddy gave you nothing...");
	thread play_sound_2d( "sam_nospawn" );
	}
	}
	else if(myrandom<35)
{
self WriteScreenText("Teddy powered up the Tesla Gun for 2 min!");
self PowerupTesla();
}
else if(myrandom<37)
{
self WriteScreenText("Teddy gave you the power to insta-repair 15 Windows!");
if(!IsDefined(grabber.freeinstawindows))
{
grabber.freeinstawindows=15;
}
else
{
grabber.freeinstawindows+=15;
}
}
else if(myrandom <42)
{
self thread ZombieHorde();
}
else if(myrandom <47)
{
self thread CallBoss();
}
else if(myrandom <50)
{
self.dontdelete=false;
self enable_trigger();
self thread WeaponGambling(grabber);
}
else
{
if(!hacked)
{
self thread move_chest_start(grabber,lid);
}
}
flag_clear("player_got_teddy");
self.dontdelete=false;
self enable_trigger(); 
}

move_chest_start(grabber,lid)
{
flag_set("moving_chest_now");
level.magic_box_first_move = true;
level.box_moved_once = true;
self disable_trigger(); 
level notify( "deletemodel" );
grabber thread treasure_chest_move_vo();
		self thread treasure_chest_move(lid);
			level.chest_accessed = 0;
		
			grabber maps\_zombiemode_score::add_to_player_score( 950 );

			//allow power weapon to be accessed.
			level.box_moved = true;
}

IgnorePower()
{
self thread WriteScreenText("Teddy has made you invisible for Zombies for 1 min!");
self.ignorepower = true;
wait(60);
self.ignorepower = false;
}

TeddyExplode(grabber,lid)
{

teddypos=lid.origin+ (0,0,16);
AddExplosion(grabber,teddypos);
wait(2);
AddExplosion(grabber,teddypos);
wait(Randomint(1));
AddExplosion(grabber,teddypos);
wait(Randomint(10)/10);
AddExplosion(grabber,teddypos);
wait(Randomint(10)/10);
AddExplosion(grabber,teddypos);
wait(1);
for(a=0;a<20;a++)
{

		AddExplosion(grabber,teddypos);
zombs = getaispeciesarray("axis");
	for(i=0;i<zombs.size;i++)
	{
		//PI ESM: added a z check so that it doesn't kill zombies up or down one floor
		if(zombs[i].origin[2] < lid.origin[2] + 320 && zombs[i].origin[2] > lid.origin[2] - 320 && DistanceSquared(zombs[i].origin, lid.origin) < 800 * 800)
		{
AddExplosion(grabber,zombs[i].origin);
}
}
wait(Randomint(10)/10);
}
}

AddExplosion(player,origin)
{
self playsound("betty_activated");
playfx(level._effect["betty_explode"], origin);
	earthquake(1, .4, origin, 512);
	
	//CHris_P - betties do no damage to the players
	zombs = getaispeciesarray("axis");
	for(i=0;i<zombs.size;i++)
	{
		//PI ESM: added a z check so that it doesn't kill zombies up or down one floor
		if(zombs[i].origin[2] < origin[2] + 80 && zombs[i].origin[2] > origin[2] - 80 && DistanceSquared(zombs[i].origin, origin) < 200 * 200)
		{
			zombs[i] thread maps\_zombiemode_spawner::zombie_damage( "MOD_ZOMBIE_BETTY", "none", zombs[i].origin, player );
		}
	}
}
// NEW STUFF

WeaponGambling(player)
{
self endon( "user_grabbed_weapon" );
self.isgambling=true;
self.currentweapon="zombie_colt";
teddy = GetEntArray( "teddy", "script_noteworthy" );
teddy[0].angles = self.angles +( 0, 90, 0 );
while(1)
{
wait(0.1);
if(self.isgambling==false)
{
return;
}
self.currentweapon = treasure_chest_ChooseRandomWeapon( player );
modelname = GetWeaponModel( self.currentweapon );
teddy[0] setmodel( modelname ); 
}
}



no_ammo_on_hud( drop_item, once )
{
	self endon ("disconnect");

	// set up the hudelem
	hudelem = maps\_hud_util::createFontString( "objective", 2 );
	hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] - (level.zombie_vars["zombie_timer_offset_interval"] * 2));
	hudelem.sort = 0.5;
	hudelem.alpha = 0;
	hudelem fadeovertime(0.5);
	hudelem.alpha = 1;
	if(once==1)
	{
	hudelem.label = "Teddy stole someones Ammo!";
	}
	else
	{
	hudelem.label = "All Ammo was Stolen by the Teddy!";
	}

	// set time remaining for insta kill
	hudelem thread no_ammo_move_hud();		

	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}

no_ammo_move_hud()
{

	players = get_players();
	//level thread play_devil_dialog("ma_vox");
	for (i = 0; i < players.size; i++)
	{
		players[i] playsound ("full_ammo");
		
	}
	wait 0.5;
	move_fade_time = 1.5;

	self FadeOverTime( move_fade_time ); 
	self MoveOverTime( move_fade_time );
	self.y = 270;
	self.alpha = 0;

	wait move_fade_time;

	self destroy();
}
all_noammo_powerup( drop_item )
{
	playsoundatposition("mx_splash_screen", (0,0,0));
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] Take_All_Ammo();
	}
	level thread no_ammo_on_hud( drop_item,0 );
	wait 20;
	Max_ammo_after_none( drop_item );
}
player_noammo_powerup( drop_item, player_won )
{
	playsoundatposition("mx_splash_screen", (0,0,0));
	//players = get_players();
	//i = player_won;
	player_won Take_All_Ammo();
	level thread no_ammo_on_hud( drop_item,1 );
	//wait 20;
	//Max_ammo_after_none( drop_item );
}
//TD
// self = player ammo is being removed from
Take_All_Ammo()
{
	self.weaponInventory = self GetWeaponsList();
	self.lastActiveWeapon = self GetCurrentWeapon();
	self.weaponAmmo = [];

	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];
		self.weaponAmmo[weapon]["clip"] = self GetWeaponAmmoClip( weapon );
		self.weaponAmmo[weapon]["stock"] = self GetWeaponAmmoStock( weapon );
	}
	self TakeAllWeapons();

	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];
		if ( weapon == "syrette"||weapon==level.hacker )
		{
			// this player got powerup while reviving another player
			continue;
		}
		self GiveWeapon( weapon );
		self SetWeaponAmmoClip( weapon, 0 );

		if ( WeaponType( weapon ) != "grenade" )
		{
			self SetWeaponAmmoStock( weapon, 0 );
		}
	}
}
player_godmode_powerup( drop_item, player_won )
{
	//players = get_players();
	//i = player_won;
	player_won EnableInvulnerability();
	self thread WriteScreenText("Teddy has made "+player_won.playername+" invulnerable for 2 min");
//level thread player_godmode_on_hud( drop_item );
	wait 120;
	player_won DisableInvulnerability(); 
}
player_godmode_on_hud( drop_item )
{
	self endon ("disconnect");
	
	// check to see if this is on or not
	if ( level.zombie_vars["zombie_powerup_godmode_on"] )
	{
		// reset the time and keep going
		level.zombie_vars["zombie_powerup_godmode_time"] = 120;
		return;
	}

	level.zombie_vars["zombie_powerup_godmode_on"] = true;

	// set up the hudelem
	hudelem = maps\_hud_util::createFontString( "objective", 2 );
	hud_offset = level.zombie_vars["zombie_timer_offset_interval"] * level.zombie_vars["zombie_timer_slot"];
	hudelem maps\_hud_util::setPoint( "TOP", undefined, 0,  hud_offset );
	hudelem.sort = 0.5;
	hudelem.alpha = 0;
	hudelem fadeovertime( 0.5 );
	hudelem.alpha = 1;
	hudelem.label = "Teddy made someone invunerable ";
	
	// set time remaining for point doubler
	hudelem thread time_remaining_on_godmode_powerup();		
	
	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}
// TD & Gambler's Ruin
time_remaining_on_godmode_powerup()
{
	self setvalue( level.zombie_vars["zombie_powerup_godmode_time"] );

	// Create a temporary script ent for the sound
	// We'll just use the points doubler sound instead of making a new one for now
	temp_entua = spawn("script_origin", (0,0,0));
	temp_entua playloopsound ("double_point_loop");

	// time it down!
	while ( level.zombie_vars["zombie_powerup_godmode_time"] >= 0)
	{
		wait 1;
		level.zombie_vars["zombie_powerup_godmode_time"] = level.zombie_vars["zombie_powerup_godmode_time"] - 1;
		self setvalue( level.zombie_vars["zombie_powerup_godmode_time"] );	
	}

	// turn off the timer
	level.zombie_vars["zombie_powerup_godmode_on"] = false;
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] playsound("points_loop_off"); //Again we use the existing point doubler sound for now
	}
	temp_entua stoploopsound(2);


	// remove the offset to make room for new powerups, reset timer for next time
	level.zombie_vars["zombie_powerup_godmode_time"] = 120;
	//level.zombie_timer_offset += level.zombie_timer_offset_interval;
	self destroy();
	temp_entua delete();  // cleanup the temporary script entity for the powerup sound
}
unlimited_ammo_powerup( drop_item )
{
	level notify ("powerup unlimited ammo");
	level endon ("powerup unlimited ammo");

	//level thread unlimited_ammo_on_hud( drop_item ); // Show the countdown
	self thread WriteScreenText("Teddy gave everyone unlimited ammo for 1 min");
	setsaveddvar ( "player_sustainAmmo",  1 );
	
	wait ( 60 );
	
	setsaveddvar ( "player_sustainAmmo", 0 );
}
unlimited_ammo_on_hud( drop_item )
{
	self endon ("disconnect");
	
	// check to see if this is on or not
	if ( level.zombie_vars["zombie_powerup_unlimited_ammo_on"] )
	{
		// reset the time and keep going
		level.zombie_vars["zombie_powerup_unlimited_ammo_time"] = 60;
		return;
	}

	level.zombie_vars["zombie_powerup_unlimited_ammo_on"] = true;

	// set up the hudelem
	hudelem = maps\_hud_util::createFontString( "objective", 2 );
	hud_offset = level.zombie_vars["zombie_timer_offset_interval"] * level.zombie_vars["zombie_timer_slot"];
	hudelem maps\_hud_util::setPoint( "TOP", undefined, 0,  hud_offset-50 );
	hudelem.sort = 0.5;
	hudelem.alpha = 0;
	hudelem fadeovertime( 0.5 );
	hudelem.alpha = 1;
	hudelem.label = "Teddy gives everyone Unlimited ammo";
	
	// set time remaining for point doubler
	hudelem thread time_remaining_on_unlimited_ammo_powerup();		
	
	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}

// TD & Gambler's Ruin
time_remaining_on_unlimited_ammo_powerup()
{
	self setvalue( level.zombie_vars["zombie_powerup_unlimited_ammo_time"] );

	// Create a temporary script ent for the sound
	// We'll just use the points doubler sound instead of making a new one for now
	temp_entua = spawn("script_origin", (0,0,0));
	temp_entua playloopsound ("double_point_loop");

	// time it down!
	while ( level.zombie_vars["zombie_powerup_unlimited_ammo_time"] >= 0)
	{
		wait 1;
		level.zombie_vars["zombie_powerup_unlimited_ammo_time"] = level.zombie_vars["zombie_powerup_unlimited_ammo_time"] - 1;
		self setvalue( level.zombie_vars["zombie_powerup_unlimited_ammo_time"] );	
	}

	// turn off the timer
	level.zombie_vars["zombie_powerup_unlimited_ammo_on"] = false;
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		players[i] playsound("points_loop_off"); //Again we use the existing point doubler sound for now
	}
	temp_entua stoploopsound(2);


	// remove the offset to make room for new powerups, reset timer for next time
	level.zombie_vars["zombie_powerup_unlimited_ammo_time"] = 60;
	//level.zombie_timer_offset += level.zombie_timer_offset_interval;
	self destroy();
	temp_entua delete();  // cleanup the temporary script entity for the powerup sound
}
Max_ammo_after_none( drop_item )
{

players = get_players();

	for (i = 0; i < players.size; i++)
	{
		primaryWeapons = players[i] GetWeaponsList(); 

		for( x = 0; x < primaryWeapons.size; x++ )
		{
			players[i] GiveMaxAmmo( primaryWeapons[x] );
		}
	}
	level thread ammo_back_on_hud( drop_item );
}
ammo_back_on_hud( drop_item )
{
	self endon ("disconnect");

	// set up the hudelem
	hudelem = maps\_hud_util::createFontString( "objective", 2 );
	hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] - (level.zombie_vars["zombie_timer_offset_interval"] * 2));
	hudelem.sort = 0.5;
	hudelem.alpha = 0;
	hudelem fadeovertime(0.5);
	hudelem.alpha = 1;
	hudelem.label = "Just Joking!";

	// set time remaining for insta kill
	hudelem thread ammo_back_move_hud();		

	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}

ammo_back_move_hud()
{

	players = get_players();
	//level thread play_devil_dialog("ma_vox");
	for (i = 0; i < players.size; i++)
	{
		players[i] playsound ("full_ammo");
		
	}
	wait 0.5;
	move_fade_time = 1.5;

	self FadeOverTime( move_fade_time ); 
	self MoveOverTime( move_fade_time );
	self.y = 270;
	self.alpha = 0;

	wait move_fade_time;

	self destroy();
}

/*Activate_All_Traps(teddy,grabber)
{
	self endon ("disconnect");

	WriteScreenText( "Teddy is going to activate all Traps in 5");
	pa_system = getent("speaker_by_log", "targetname");
	playsoundatposition("alarm", pa_system.origin);
	wait(1);
	WriteScreenText("4");
	wait(1);
	WriteScreenText("3");
	wait(1);
	WriteScreenText("2");
	wait(1);
	WriteScreenText("1");
	wait(1);
	WriteScreenText("NOW!");
	trap_trigs = getentarray("elec_trap_trig","targetname");
	for (i = 0; i < trap_trigs.size; i++)
	{
		trap_trigs[i] thread maps\nazi_zombie_sumpf_trap_perk_electric::UseElecTeddy(grabber);
	}
	penBuyTrigger = getentarray("pendulum_buy_trigger","targetname");
	
	for(i = 0; i < penBuyTrigger.size; i++)
	{
	penBuyTrigger[i] thread maps\nazi_zombie_sumpf_trap_pendulum::UseTeddy(grabber);
	}
}*/
WriteScreenText( text )
{
	self endon ("disconnect");

	// set up the hudelem
	hudelem = maps\_hud_util::createFontString( "objective", 2 );
	hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] - (level.zombie_vars["zombie_timer_offset_interval"] * 2));
	hudelem.sort = 0.5;
	hudelem.alpha = 0;
	hudelem fadeovertime(0.5);
	hudelem.alpha = 1;
	
	hudelem.label = text;
	

	// set time remaining for insta kill
	hudelem thread write_text_move_hud();		

	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}

write_text_move_hud()
{

	players = get_players();
	//level thread play_devil_dialog("ma_vox");
	for (i = 0; i < players.size; i++)
	{
		players[i] playsound ("full_ammo");
		
	}
	wait 0.5;
	move_fade_time = 1.5;

	self FadeOverTime( move_fade_time ); 
	self MoveOverTime( move_fade_time );
	self.y = 270;
	self.alpha = 0;

	wait move_fade_time;

	self destroy();
}
RepairAllWindows()
{
level.exterior_goals = getstructarray( "exterior_goal", "targetname" ); 

	for( i = 0; i < level.exterior_goals.size; i++ )
	{
		level.exterior_goals[i] thread maps\_zombiemode_blockers_new::RepairWindow();
	}
}

PowerupBetties()
{
level notify("betty_powered");
level endon("betty_powered");
level.superbetties=true;
wait(60);
level.superbetties=false;
}
PowerupTesla()
{
level notify("tesla_powered");
level endon("tesla_powered");
level.supertesla=true;
wait(120);
level.supertesla=false;
}
ZombieHorde()
{
self thread WriteScreenText("Teddy has called a Horde of Zombies!");
level.zombiehorde=true;
wait(10);
level.zombiehorde=false;
}
CallBoss()
{
self thread WriteScreenText("Teddy has called a Zombie-Boss!");
level.callboss=true;
}
firesale_chest_fly_off(lid)
{
if(!IsDefined(lid.isopen))
{
lid.isopen=false;
}
while(lid.isopen==true)
{
wait(0.1);
}
wait(1);
//	lid thread treasure_chest_lid_close(false);
	self disable_trigger();
	self setvisibletoall();

	fake_pieces = [];
	pieces = self get_chest_pieces();

	for(i=0;i<pieces.size;i++)
	{
		if(pieces[i].classname == "script_model")
		{
			pieces[i] disable_trigger();
			pieces[i] hide();
		}
	}

	anchor = spawn("script_origin",pieces[0].origin);
	soundpoint = spawn("script_origin", anchor.origin);


	

	playsoundatposition ("whoosh", soundpoint.origin );
	//playsoundatposition ("ann_vox_magicbox", soundpoint.origin );


	
	playfx(level._effect["poltergeist"], anchor.origin);
	
	//TUEY - Play the 'disappear' sound
	playsoundatposition ("box_poof", soundpoint.origin);

	//gzheng-Show the rubble
	//PI CHANGE - allow for more than one object of rubble per box
	rubble = getentarray(self.script_noteworthy + "_rubble", "script_noteworthy");
	
	if ( IsDefined( rubble ) )
	{
		for (i = 0; i < rubble.size; i++)
		{
			rubble[i] show();
		}
	}
	else
	{
		println( "^3Warning: No rubble found for magic box" );
	}

	wait(0.1);
	anchor delete();
	soundpoint delete();
	wait(2);
	self disable_trigger();
}