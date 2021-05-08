#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{

	PrecacheShader( "specialty_doublepoints_zombies" );
	PrecacheShader( "specialty_instakill_zombies" );


	
	PrecacheShader( "black" ); 
	// powerup Vars
	set_zombie_var( "zombie_insta_kill", 				0 );
	set_zombie_var( "zombie_point_scalar", 				1 );
	set_zombie_var( "zombie_drop_item", 				0 );
	set_zombie_var( "zombie_timer_offset", 				350 );	// hud offsets
	set_zombie_var( "zombie_timer_offset_interval", 	30 );
	set_zombie_var( "zombie_powerup_insta_kill_on", 	false );
	set_zombie_var( "zombie_powerup_point_doubler_on", 	false );
	set_zombie_var( "zombie_powerup_point_doubler_time", 30 );	// length of point doubler
	set_zombie_var( "zombie_powerup_insta_kill_time", 	30 );	// length of insta kill
	set_zombie_var( "zombie_powerup_drop_increment", 	1800 );	// lower this to make drop happen more often
	set_zombie_var( "zombie_powerup_drop_max_per_round", 5 );	// lower this to make drop happen more often
	PrecacheModel("grenade_bag");
	// powerups
	level._effect["powerup_on"] 				= loadfx( "misc/fx_zombie_powerup_on" );
	level._effect["powerup_grabbed"] 			= loadfx( "misc/fx_zombie_powerup_grab" );
	level._effect["powerup_grabbed_wave"] 		= loadfx( "misc/fx_zombie_powerup_wave" );

	init_powerups();

	thread watch_for_drop();
}

init_powerups()
{
	if( !IsDefined( level.zombie_powerup_array ) )
	{
		level.zombie_powerup_array = [];
	}
	if ( !IsDefined( level.zombie_special_drop_array ) )
	{
		level.zombie_special_drop_array = [];
	}

	// Random Drops
	add_zombie_powerup( "nuke", 		"zombie_bomb",		&"ZOMBIE_POWERUP_NUKE", 			"misc/fx_zombie_mini_nuke" );
//	add_zombie_powerup( "nuke", 		"zombie_bomb",		&"ZOMBIE_POWERUP_NUKE", 			"misc/fx_zombie_mini_nuke_hotness" );
	add_zombie_powerup( "insta_kill", 	"zombie_skull",		&"ZOMBIE_POWERUP_INSTA_KILL" );
	add_zombie_powerup( "double_points","zombie_x2_icon",	&"ZOMBIE_POWERUP_DOUBLE_POINTS" );
	add_zombie_powerup( "full_ammo",  	"zombie_ammocan",	&"ZOMBIE_POWERUP_MAX_AMMO");
	add_zombie_powerup( "carpenter",  	"zombie_carpenter",	&"ZOMBIE_POWERUP_MAX_AMMO");
	add_zombie_powerup( "fire_sale",  	"zombie_treasure_box_lid",	"Fire Sale!");
	add_zombie_powerup( "Star",  		"tag_origin",		"Star!");
	add_zombie_powerup( "ray_gun",  	"weapon_usa_ray_gun",				"Ray Gun!");
	add_zombie_powerup( "teddytrap",  	"zombie_teddybear",					"Teddytrap!");
	add_zombie_powerup( "grenade",  	"weapon_usa_mk2_grenade",			"Grenade Madness!");
	add_zombie_powerup( "perk",  		"zombie_3rd_perk_bottle_jugg",		"Perk!");
	add_zombie_powerup( "jackpot",  	"grenade_bag",			"Jackpot!");
	//	add_zombie_special_powerup( "monkey" );

	// additional special "drops"
	add_zombie_special_drop( "nothing" );
	add_zombie_special_drop( "dog" );

	// Randomize the order
	randomize_powerups();

	level.zombie_powerup_index = 0;
	randomize_powerups();

	level thread powerup_hud_overlay();
}  

powerup_hud_overlay()
{

	level.powerup_hud_array = [];
	level.powerup_hud_array[0] = true;
	level.powerup_hud_array[1] = true;

	level.powerup_hud = [];
	level.powerup_hud_cover = [];
	level endon ("disconnect");


	for(i = 0; i < 2; i++)
	{
		level.powerup_hud[i] = create_simple_hud();
		level.powerup_hud[i].foreground = true; 
		level.powerup_hud[i].sort = 2; 
		level.powerup_hud[i].hidewheninmenu = false; 
		level.powerup_hud[i].alignX = "center"; 
		level.powerup_hud[i].alignY = "bottom";
		level.powerup_hud[i].horzAlign = "center"; 
		level.powerup_hud[i].vertAlign = "bottom";
		level.powerup_hud[i].x = -32 + (i * 15); 
		level.powerup_hud[i].y = level.powerup_hud[i].y - 35; 
		level.powerup_hud[i].alpha = 0.8;
		//hud SetShader( shader_inst, 24, 24 );
	}

	shader_2x = "specialty_doublepoints_zombies";
	shader_insta = "specialty_instakill_zombies";
//	shader_white = "black";
	



	//for(i = 0; i < 2; i++)
	//{
	//	level.powerup_hud_cover[i] = create_simple_hud();
	//	level.powerup_hud_cover[i].foreground = true; 
	//	level.powerup_hud_cover[i].sort = 1; 
	//	level.powerup_hud_cover[i].hidewheninmenu = false; 
	//	level.powerup_hud_cover[i].alignX = "center"; 
	//	level.powerup_hud_cover[i].alignY = "bottom";
	//	level.powerup_hud_cover[i].horzAlign = "center"; 
	//	level.powerup_hud_cover[i].vertAlign = "bottom";
	//	level.powerup_hud_cover[i].x = -32 + (i * 34); 
	//	level.powerup_hud_cover[i].y = level.powerup_hud_cover[i].y - 30; 
	//	level.powerup_hud_cover[i].alpha = 1;
	//	//hud SetShader( shader_inst, 24, 24 );
	//}



	//increment = 0;
	

	while(true)
	{
		if(level.zombie_vars["zombie_powerup_insta_kill_time"] < 5)
		{
			wait(0.1);		
			level.powerup_hud[1].alpha = 0;
			wait(0.1);
			

		}
		else if(level.zombie_vars["zombie_powerup_insta_kill_time"] < 10)
		{
			wait(0.2);
			level.powerup_hud[1].alpha = 0;
			wait(0.18);
			
		}
		
		if(level.zombie_vars["zombie_powerup_point_doubler_time"] < 5)
		{
			wait(0.1);	
			level.powerup_hud[0].alpha = 0;
			wait(0.1);
			

		}
		else if(level.zombie_vars["zombie_powerup_point_doubler_time"] < 10)
		{
			wait(0.2);
			level.powerup_hud[0].alpha = 0;
			wait(0.18);
		}
		

		//if(level.zombie_vars["zombie_powerup_insta_kill_time"] != 0)
		//	iprintlnbold(level.zombie_vars["zombie_powerup_insta_kill_time"]);

		//if(level.zombie_vars["zombie_powerup_point_doubler_time"] != 0)
		//	iprintlnbold(level.zombie_vars["zombie_powerup_point_doubler_time"]);


		//wait(0.01);
		
		if(level.zombie_vars["zombie_powerup_point_doubler_on"] == true && level.zombie_vars["zombie_powerup_insta_kill_on"] == true)
		{

			level.powerup_hud[0].x = -24;
			level.powerup_hud[1].x = 24;
			level.powerup_hud[0].alpha = 1;
			level.powerup_hud[1].alpha = 1;
			level.powerup_hud[0] setshader(shader_2x, 32, 32);
			level.powerup_hud[1] setshader(shader_insta, 32, 32);
			/*level.powerup_hud_cover[0].x = -36;
			level.powerup_hud_cover[1].x = 36;
			level.powerup_hud_cover[0] setshader(shader_white, 32, i);
			level.powerup_hud_cover[1] setshader(shader_white, 32, j);
			level.powerup_hud_cover[0].alpha = 1;
			level.powerup_hud_cover[1].alpha = 1;*/

		}
		else if(level.zombie_vars["zombie_powerup_point_doubler_on"] == true && level.zombie_vars["zombie_powerup_insta_kill_on"] == false)
		{
			level.powerup_hud[0].x = 0; 
			//level.powerup_hud[0].y = level.powerup_hud[0].y - 70; 
			level.powerup_hud[0] setshader(shader_2x, 32, 32);
			level.powerup_hud[1].alpha = 0;
			level.powerup_hud[0].alpha = 1;

		}
		else if(level.zombie_vars["zombie_powerup_insta_kill_on"] == true && level.zombie_vars["zombie_powerup_point_doubler_on"] == false)
		{

			level.powerup_hud[1].x = 0; 
			//level.powerup_hud[1].y = level.powerup_hud[1].y - 70; 
			level.powerup_hud[1] setshader(shader_insta, 32, 32);
			level.powerup_hud[0].alpha = 0;
			level.powerup_hud[1].alpha = 1;
		}
		else
		{
			
			level.powerup_hud[1].alpha = 0;
			level.powerup_hud[0].alpha = 0;

		}

		wait(0.01);


	
		//increment += 1;

		//if(increment >= 20)
		//{
		//	level.powerup_hud[0].alpha = 0;
		//	level.powerup_hud[1].alpha = 0;
		////	level.powerup_hud_cover[0].alpha = 0;
		////	level.powerup_hud_cover[1].alpha = 0;
		//}
		//
		//if(increment == 30)
		//{

		//	level.powerup_hud_array[1] = false;
		//	level.powerup_hud_array[0] = false;

		//}
		//wait(0.5);

		




	/*	if(randomint(100) > 50)
			level.powerup_hud_array[0] = false;
		else 
			level.powerup_hud_array[0] = true;
	

		if(randomint(100) > 50)
			level.powerup_hud_array[1] = false;
		else
			level.powerup_hud_array[1] = true;*/

	}


	

	//for(i = 0; i < 2; i++)
	//{
	//	level.powerup_hud_cover[i] = create_simple_hud();
	//	level.powerup_hud_cover[i].foreground = true; 
	//	level.powerup_hud_cover[i].sort = 1; 
	//	level.powerup_hud_cover[i].hidewheninmenu = false; 
	//	level.powerup_hud_cover[i].alignX = "center"; 
	//	level.powerup_hud_cover[i].alignY = "bottom";
	//	level.powerup_hud_cover[i].horzAlign = "center"; 
	//	level.powerup_hud_cover[i].vertAlign = "bottom";
	//	level.powerup_hud_cover[i].x = -32 + (i * 34); 
	//	level.powerup_hud_cover[i].y = level.powerup_hud_cover[i].y - 79; 
	//	level.powerup_hud_cover[i].alpha = 0.5;
	//	//hud SetShader( shader_inst, 24, 24 );
	//}


	//while(true)
	//{
	//	/*	for(i = 0; i < 2; i++)
	//	{
	//	level.powerup_hud[i].y = level.powerup_hud[i].y - 5;

	//	}*/




	//	wait(1);
	//}

}

randomize_powerups()
{
	level.zombie_powerup_array = array_randomize( level.zombie_powerup_array );
}

get_next_powerup()
{
	if( level.zombie_powerup_index >= level.zombie_powerup_array.size )
	{
		level.zombie_powerup_index = 0;
		randomize_powerups();
	}

	powerup = level.zombie_powerup_array[level.zombie_powerup_index];

	/#
		if( isdefined( level.zombie_devgui_power ) && level.zombie_devgui_power == 1 )
			return powerup;

	#/

	//level.windows_destroyed = get_num_window_destroyed();

	while( powerup == "carpenter" && get_num_window_destroyed() < 5)
	{	
		
		
		if( level.zombie_powerup_index >= level.zombie_powerup_array.size )
		{
			level.zombie_powerup_index = 0;
			randomize_powerups();
		}
		
		
		powerup = level.zombie_powerup_array[level.zombie_powerup_index];
		level.zombie_powerup_index++;
			
		if( powerup != "carpenter" )
			return powerup;
		
		
		wait(0.05);
	}

	level.zombie_powerup_index++;

	return powerup;
}

get_num_window_destroyed()
{
	num = 0;
	for( i = 0; i < level.exterior_goals.size; i++ )
	{
		/*targets = getentarray(level.exterior_goals[i].target, "targetname");

		barrier_chunks = []; 
		for( j = 0; j < targets.size; j++ )
		{
			if( IsDefined( targets[j].script_noteworthy ) )
			{
				if( targets[j].script_noteworthy == "clip" )
				{ 
					continue; 
				}
			}

			barrier_chunks[barrier_chunks.size] = targets[j];
		}*/


		if( all_chunks_destroyed( level.exterior_goals[i].barrier_chunks ) )
		{
			num += 1;
		}

	}

	return num;
}

watch_for_drop()
{
	players = get_players();
	score_to_drop = ( players.size * level.zombie_vars["zombie_score_start"] ) + level.zombie_vars["zombie_powerup_drop_increment"];

	while (1)
	{
		players = get_players();

		curr_total_score = 0;

		for (i = 0; i < players.size; i++)
		{
			curr_total_score += players[i].score_total;
		}

		if (curr_total_score > score_to_drop )
		{
			level.zombie_vars["zombie_powerup_drop_increment"] *= 1.14;
			score_to_drop = curr_total_score + level.zombie_vars["zombie_powerup_drop_increment"];
			level.zombie_vars["zombie_drop_item"] = 1;
		}

		wait( 0.5 );
	}
}

add_zombie_powerup( powerup_name, model_name, hint, fx )
{
	if( IsDefined( level.zombie_include_powerups ) && !IsDefined( level.zombie_include_powerups[powerup_name] ) )
	{
		return;
	}

	PrecacheModel( model_name );
	PrecacheString( hint );

	struct = SpawnStruct();

	if( !IsDefined( level.zombie_powerups ) )
	{
		level.zombie_powerups = [];
	}

	struct.powerup_name = powerup_name;
	struct.model_name = model_name;
	struct.weapon_classname = "script_model";
	struct.hint = hint;

	if( IsDefined( fx ) )
	{
		struct.fx = LoadFx( fx );
	}

	level.zombie_powerups[powerup_name] = struct;
	level.zombie_powerup_array[level.zombie_powerup_array.size] = powerup_name;
	add_zombie_special_drop( powerup_name );
}


// special powerup list for the teleporter drop
add_zombie_special_drop( powerup_name )
{
	level.zombie_special_drop_array[ level.zombie_special_drop_array.size ] = powerup_name;
}

include_zombie_powerup( powerup_name )
{
	if( !IsDefined( level.zombie_include_powerups ) )
	{
		level.zombie_include_powerups = [];
	}

	level.zombie_include_powerups[powerup_name] = true;
}

powerup_round_start()
{
	level.powerup_drop_count = 0;
}

powerup_drop(drop_point)
{
	rand_drop = randomint(100);

	if( level.powerup_drop_count >= level.zombie_vars["zombie_powerup_drop_max_per_round"] )
	{
		println( "^3POWERUP DROP EXCEEDED THE MAX PER ROUND!" );
		return;
	}
	
	if( !isDefined(level.zombie_include_powerups) || level.zombie_include_powerups.size == 0 )
	{
		return;
	}

	// some guys randomly drop, but most of the time they check for the drop flag
	if (rand_drop > 2)
	{
		if (!level.zombie_vars["zombie_drop_item"])
		{
			return;
		}

		debug = "score";
	}
	else
	{
		debug = "random";
	}	

	// never drop unless in the playable area
	playable_area = getentarray("playable_area","targetname");

	powerup = maps\_zombiemode_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + (0,0,40));
	
	//chris_p - fixed bug where you could not have more than 1 playable area trigger for the whole map
	valid_drop = false;
	for (i = 0; i < playable_area.size; i++)
	{
		if (powerup istouching(playable_area[i]))
		{
			valid_drop = true;
		}
	}
	
	if(!valid_drop)
	{
		powerup delete();
		return;
	}

	powerup powerup_setup();
	level.powerup_drop_count++;

	print_powerup_drop( powerup.powerup_name, debug );

	powerup thread powerup_timeout();
	powerup thread powerup_wobble();
	powerup thread powerup_grab();

	level.zombie_vars["zombie_drop_item"] = 0;


	//powerup = powerup_setup(); 


	// if is !is touching trig
	// return

	// spawn the model, do a ground trace and place above
	// start the movement logic, spawn the fx
	// start the time out logic
	// start the grab logic
}


//
//	Special power up drop - done outside of the powerup system.
special_powerup_drop(drop_point)
{
// 	if( level.powerup_drop_count == level.zombie_vars["zombie_powerup_drop_max_per_round"] )
// 	{
// 		println( "^3POWERUP DROP EXCEEDED THE MAX PER ROUND!" );
// 		return;
// 	}

	if( !isDefined(level.zombie_include_powerups) || level.zombie_include_powerups.size == 0 )
	{
		return;
	}

	powerup = spawn ("script_model", drop_point + (0,0,40));

	// never drop unless in the playable area
	playable_area = getentarray("playable_area","targetname");
	//chris_p - fixed bug where you could not have more than 1 playable area trigger for the whole map
	valid_drop = false;
	for (i = 0; i < playable_area.size; i++)
	{
		if (powerup istouching(playable_area[i]))
		{
			valid_drop = true;
			break;
		}
	}

	if(!valid_drop)
	{
		powerup Delete();
		return;
	}

	powerup special_drop_setup();
}


//
//	Pick the next powerup in the list
powerup_setup()
{
	powerup = get_next_powerup();

	struct = level.zombie_powerups[powerup];
	self SetModel( struct.model_name );

	//TUEY Spawn Powerup
	playsoundatposition("spawn_powerup", self.origin);

	self.powerup_name 	= struct.powerup_name;
	self.hint 			= struct.hint;

	if( IsDefined( struct.fx ) )
	{
		self.fx = struct.fx;
	}

	self PlayLoopSound("spawn_powerup_loop");
}


//
//	Get the special teleporter drop
special_drop_setup()
{
	powerup = undefined;
	is_powerup = true;
	// Always give something at lower rounds or if a player is in last stand mode.
	if ( level.round_number <= 10 || maps\_laststand::player_num_in_laststand() )
	{
		powerup = get_next_powerup();
	}
	// Gets harder now
	else
	{
		powerup = level.zombie_special_drop_array[ RandomInt(level.zombie_special_drop_array.size) ];
		if ( level.round_number > 15 &&
			 ( RandomInt(100) < (level.round_number - 15)*5 ) )
		{
			powerup = "nothing";
		}
	}
	//MM test  Change this if you want the same thing to keep spawning
//	powerup = "dog";
	switch ( powerup )
	{
	// Don't need to do anything special
	case "nuke":
	case "insta_kill":
	case "double_points":
	case "carpenter":
		break;
	case "perk":
		if (! level.round_number >= 10 )
		{
			powerup = get_next_powerup();
		}
	// Limit max ammo drops because it's too powerful
	case "full_ammo":
		if ( level.round_number > 10 &&
			 ( RandomInt(100) < (level.round_number - 10)*5 ) )
		{
			// Randomly pick another one
			powerup = level.zombie_powerup_array[ RandomInt(level.zombie_powerup_array.size) ];
		}
		break;

	case "dog":
		if ( level.round_number >= 15 )
		{
			is_powerup = false;
			dog_spawners = GetEntArray( "special_dog_spawner", "targetname" );
			maps\_zombiemode_dogs::special_dog_spawn( dog_spawners, 1 );
			//iprintlnbold( "Samantha Sez: No Powerup For You!" );
			thread play_sound_2d( "sam_nospawn" );
		}
		else
		{
			powerup = get_next_powerup();
		}
		break;

	// Nothing drops!!
	default:	// "nothing"
		is_powerup = false;
		Playfx( level._effect["lightning_dog_spawn"], self.origin );
		playsoundatposition( "pre_spawn", self.origin );
		wait( 1.5 );
		playsoundatposition( "bolt", self.origin );

		Earthquake( 0.5, 0.75, self.origin, 1000);
		PlayRumbleOnPosition("explosion_generic", self.origin);
		playsoundatposition( "spawn", self.origin );

		wait( 1.0 );
		//iprintlnbold( "Samantha Sez: No Powerup For You!" );
		thread play_sound_2d( "sam_nospawn" );
		self Delete();
	}

	if ( is_powerup )
	{
		Playfx( level._effect["lightning_dog_spawn"], self.origin );
		playsoundatposition( "pre_spawn", self.origin );
		wait( 1.5 );
		playsoundatposition( "bolt", self.origin );

		Earthquake( 0.5, 0.75, self.origin, 1000);
		PlayRumbleOnPosition("explosion_generic", self.origin);
		playsoundatposition( "spawn", self.origin );

//		wait( 0.5 );

		struct = level.zombie_powerups[powerup];
		self SetModel( struct.model_name );

		//TUEY Spawn Powerup
		playsoundatposition("spawn_powerup", self.origin);

		self.powerup_name 	= struct.powerup_name;
		self.hint 			= struct.hint;

		if( IsDefined( struct.fx ) )
		{
			self.fx = struct.fx;
		}

		self PlayLoopSound("spawn_powerup_loop");

		self thread powerup_timeout();
		self thread powerup_wobble();
		self thread powerup_grab();
	}
}

powerup_grab()
{
	self endon ("powerup_timedout");
	self endon ("powerup_grabbed");

	while (isdefined(self))
	{
		players = get_players();

		for (i = 0; i < players.size; i++)
		{
			if (distance (players[i].origin, self.origin) < 64)
			{
				playfx (level._effect["powerup_grabbed"], self.origin);
				playfx (level._effect["powerup_grabbed_wave"], self.origin);	

				if( IsDefined( level.zombie_powerup_grab_func ) )
				{
					level thread [[level.zombie_powerup_grab_func]]();
				}
				else
				{
					switch (self.powerup_name)
					{
					case "nuke":
						level thread nuke_powerup( self );
						
						//chrisp - adding powerup VO sounds
						players[i] thread powerup_vo("nuke");
						zombies = getaiarray("axis");
						players[i].zombie_nuked = get_array_of_closest( self.origin, zombies );
						players[i] notify("nuke_triggered");
						
						break;
					case "full_ammo":
						level thread full_ammo_powerup( self );
						players[i] thread powerup_vo("full_ammo");
						break;
					case "fire_sale":
						level thread fire_sale_powerup( self );
						break;
					case "double_points":
						level thread double_points_powerup( self );
						players[i] thread powerup_vo("double_points");
						break;
					case "insta_kill":
						level thread insta_kill_powerup( self );
						players[i] thread powerup_vo("insta_kill");
						break;
					case "carpenter":
						level thread start_carpenter( self.origin );
						players[i] thread powerup_vo("carpenter");
						break;
					case "Star":
						players[i] thread star_power(self);
						break;
					case "ray_gun":
						players[i] thread ray_gun_power( self );
						players[i] thread powerup_vo("insta_kill");
						break;
					case "grenade":
						players[i] thread grenade_power( self );
						players[i] thread powerup_vo("insta_kill");
						break;
					case "teddytrap":
						level thread teddy_powerup( self );
						//players[i] thread powerup_vo("insta_kill");
						break;
					case "perk":
						thread maps\_zombiemode_perks::give_random_perk( players[i] );
						break;
					case "jackpot":
						players[i] thread reward_jackpot( self );
						break;
					default:
						println ("Unrecognized powerup.");
						break;
					}
				}

				wait( 0.1 );

				playsoundatposition("powerup_grabbed", self.origin);
				self stoploopsound();

				self delete();
				self notify ("powerup_grabbed");
			}
		}
		wait 0.1;
	}	
}

reward_jackpot(drop_item)
{
	cost = 2000;
	if( level.zombie_vars["zombie_powerup_point_doubler_on"] )
	{
		cost = 5000;
	}
	self maps\_zombiemode_score::add_to_player_score(cost);
}

start_carpenter( origin )
{

	level thread play_devil_dialog("carp_vox");
	window_boards = getstructarray( "exterior_goal", "targetname" ); 
	total = level.exterior_goals.size;
	
	//COLLIN
	carp_ent = spawn("script_origin", (0,0,0));
	carp_ent playloopsound( "carp_loop" );
	
	while(true)
	{
		windows = get_closest_window_repair(window_boards, origin);
		if( !IsDefined( windows ) )
		{
			carp_ent stoploopsound( 1 );
			carp_ent playsound( "carp_end", "sound_done" );
			carp_ent waittill( "sound_done" );
			break;
		}
		
		else
			window_boards = array_remove(window_boards, windows);


		while(1)
		{
			if( all_chunks_intact( windows.barrier_chunks ) )
			{
				break;
			}

			chunk = get_random_destroyed_chunk( windows.barrier_chunks ); 

			if( !IsDefined( chunk ) )
				break;

			windows thread maps\_zombiemode_blockers_new::replace_chunk( chunk, false, true );
			windows.clip enable_trigger(); 
			windows.clip DisconnectPaths();
			wait_network_frame();
			wait(0.05);
		}
 

		wait_network_frame();
		
	}


	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i].score += 200;
		players[i].score_total += 200;
		players[i] maps\_zombiemode_score::set_player_score_hud(); 
	}


	carp_ent delete();


}
get_closest_window_repair( windows, origin )
{
	current_window = undefined;
	shortest_distance = undefined;
	for( i = 0; i < windows.size; i++ )
	{
		if( all_chunks_intact(windows[i].barrier_chunks ) )
			continue;

		if( !IsDefined( current_window ) )	
		{
			current_window = windows[i];
			shortest_distance = DistanceSquared( current_window.origin, origin );
			
		}
		else
		{
			if( DistanceSquared(windows[i].origin, origin) < shortest_distance )
			{

				current_window = windows[i];
				shortest_distance =  DistanceSquared( windows[i].origin, origin );
			}

		}

	}

	return current_window;


}

powerup_vo(type)
{
	self endon("death");
	self endon("disconnect");
	
	index = maps\_zombiemode_weapons::get_player_index(self);
	sound = undefined;
	rand = randomintrange(0,3);
	vox_rand = randomintrange(1,100);  //RARE: This is to setup the Rare devil response lines
	percentage = 1;  //What percent chance the rare devil response line has to play
	
	if(!isdefined (level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}
	
	wait(randomfloatrange(1,2));
		
	switch(type)
	{
		case "nuke":
			if( vox_rand <= percentage )
			{
				//sound = "plr_" + index + "_vox_resp_dev_rare_" + rand;
				//iprintlnbold( "Whoopdedoo, rare Devil Response line" );
			}
			else
			{
				sound = "plr_" + index + "_vox_powerup_nuke_" + rand;
			}
			break;
		case "insta_kill":
			if( vox_rand <= percentage )
			{
				//sound = "plr_" + index + "_vox_resp_dev_rare_" + rand;
				//iprintlnbold( "Whoopdedoo, rare Devil Response line" );
			}
			else
			{
				sound = "plr_" + index + "_vox_powerup_insta_" + rand;
			}
			break;
		case "full_ammo":
			if( vox_rand <= percentage )
			{
				//sound = "plr_" + index + "_vox_resp_dev_rare_" + rand;
				//iprintlnbold( "Whoopdedoo, rare Devil Response line" );
			}
			else
			{
				sound = "plr_" + index + "_vox_powerup_ammo_" + rand;
			}
			break;
		case "double_points":
			if( vox_rand <= percentage )
			{
				//sound = "plr_" + index + "_vox_resp_dev_rare_" + rand;
				//iprintlnbold( "Whoopdedoo, rare Devil Response line" );
			}
			else
			{
				sound = "plr_" + index + "_vox_powerup_double_" + rand;
			}
			break; 		
		case "carpenter":
			if( vox_rand <= percentage )
			{
				//sound = "plr_" + index + "_vox_resp_dev_rare_" + rand;
				//iprintlnbold( "Whoopdedoo, rare Devil Response line" );
			}
			else
			{
				sound = "plr_" + index + "_vox_powerup_carp_" + rand;
			}
			break;
	}
	
	//This keeps multiple voice overs from playing on the same player (both killstreaks and headshots).
	if (level.player_is_speaking != 1 && isDefined(sound))
	{	
		level.player_is_speaking = 1;
		self playsound(sound, "sound_done");			
		self waittill("sound_done");
		level.player_is_speaking = 0;
	}	
	
	
}

powerup_wobble()
{
	self endon ("powerup_grabbed");
	self endon ("powerup_timedout");

	if (isdefined(self))
	{
		playfxontag (level._effect["powerup_on"], self, "tag_origin");
		if(self.powerup_name=="Star")
		{
		fx = PlayFxOnTag( level._effect["tesla_bolt"], self, "tag_origin" );
		}
	}

	while (isdefined(self))
	{
		waittime = randomfloatrange(2.5, 5);
		yaw = RandomInt( 360 );
		if( yaw > 300 )
		{
			yaw = 300;
		}
		else if( yaw < 60 )
		{
			yaw = 60;
		}
		yaw = self.angles[1] + yaw;
		self rotateto ((-60 + randomint(120), yaw, -45 + randomint(90)), waittime, waittime * 0.5, waittime * 0.5);
		wait randomfloat (waittime - 0.1);
	}
}

powerup_timeout()
{
	self endon ("powerup_grabbed");

	wait 15;

	for (i = 0; i < 40; i++)
	{
		// hide and show
		if (i % 2)
		{
			self hide();
		}
		else
		{
			self show();
		}

		if (i < 15)
		{
			wait 0.5;
		}
		else if (i < 25)
		{
			wait 0.25;
		}
		else
		{
			wait 0.1;
		}
	}

	self notify ("powerup_timedout");
	self delete();
}

// kill them all!
nuke_powerup( drop_item )
{
	zombies = getaispeciesarray("axis");

	PlayFx( drop_item.fx, drop_item.origin );
	//	players = get_players();
	//	array_thread (players, ::nuke_flash);
	level thread nuke_flash();

	

	zombies = get_array_of_closest( drop_item.origin, zombies );

	for (i = 0; i < zombies.size; i++)
	{
		wait (randomfloatrange(0.1, 0.7));
		if( !IsDefined( zombies[i] ) )
		{
			continue;
		}
		
		if( zombies[i].animname == "boss_zombie" )
		{
			continue;
		}

		if( is_magic_bullet_shield_enabled( zombies[i] ) )
		{
			continue;
		}

		if( i < 5 && !( zombies[i] enemy_is_dog() ) )
		{
			zombies[i] thread animscripts\death::flame_death_fx();

		}

		if( !( zombies[i] enemy_is_dog() ) )
		{
			zombies[i] maps\_zombiemode_spawner::zombie_head_gib();
		}

		zombies[i] dodamage( zombies[i].health + 666, zombies[i].origin );
		playsoundatposition( "nuked", zombies[i].origin );
	}

	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i].score += 400;
		players[i].score_total += 400;
		players[i] maps\_zombiemode_score::set_player_score_hud(); 
	}

}

nuke_flash()
{
	players = getplayers();	
	for(i=0; i<players.size; i ++)
	{
		players[i] play_sound_2d("nuke_flash");
	}
	level thread devil_dialog_delay();
	
	
	fadetowhite = newhudelem();

	fadetowhite.x = 0; 
	fadetowhite.y = 0; 
	fadetowhite.alpha = 0; 

	fadetowhite.horzAlign = "fullscreen"; 
	fadetowhite.vertAlign = "fullscreen"; 
	fadetowhite.foreground = true; 
	fadetowhite SetShader( "white", 640, 480 ); 

	// Fade into white
	fadetowhite FadeOverTime( 0.2 ); 
	fadetowhite.alpha = 0.8; 

	wait 0.5;
	fadetowhite FadeOverTime( 1.0 ); 
	fadetowhite.alpha = 0; 

	wait 1.1;
	fadetowhite destroy();
}
give_grenades()
{
self endon("stop give grenades");
while(1)
	{
		self GiveWeapon( "stielhandgranate" );	
		self SetWeaponAmmoClip( "stielhandgranate", 4 );
		wait(0.2);
	}
}

grenade_power(drop_item)
{
	self notify ("nade power");
	self endon ("nade power");
	self thread give_grenades();
	if(IsDefined(self.staractive)&&self.staractive==true)
	{
		self.staregg=true;
	}
	wait(30);
	self notify("stop give grenades");
}


starshockzombies()
{
self endon("stop star kill zombies");
while(1)
{
self thread maps\nazi_zombie_factory_teleporter::star_damage();
wait(0.1);
}
}

starfxplayer()
{
self endon("stop star kill zombies");
while(1)
{
PlayFxOnTag( level._effect["elec_md"], self, "tag_origin" ); 
setClientSysState("levelNotify", "t2d", self);

wait(1.7);
}
}
starsetmovespeed()
{
self endon("stop star kill zombies");
for(;;)
{
self setMoveSpeedScale( 2 ); 
level.fxOrg MoveTo( self.origin, 0.01 );
level.fxOrg waittill( "movedone" );
}
}
starrepairwindows()
{
self endon("stop star kill zombies");
for(;;)
{
window_boards = getstructarray( "exterior_goal", "targetname" ); 

	window_boards = get_array_of_closest( self.origin, window_boards, undefined, 5, 200 );

	for (i = 0; i < window_boards.size; i++)
	{
		wait (randomfloatrange(0.2, 0.3));
		if( !IsDefined( window_boards[i] ) )
		{
			continue;
		}
		windows = window_boards[i];
		//self thread maps\_zombiemode_tesla::tesla_play_arc_fx( windows );
		if(! all_chunks_intact( windows.barrier_chunks ) )
			{
		fxOrg = Spawn( "script_model", self.origin );
	fxOrg SetModel( "tag_origin" );

	fx = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
	playsoundatposition( "tesla_bounce", fxOrg.origin );
	
	fxOrg MoveTo( windows.origin, 0.1 );
	fxOrg waittill( "movedone" );
	fxOrg delete();
	}
		while(1)
		{
			if( all_chunks_intact( windows.barrier_chunks ) )
			{
				break;
			}

			chunk = get_random_destroyed_chunk( windows.barrier_chunks ); 

			if( !IsDefined( chunk ) )
				break;

			windows thread maps\_zombiemode_blockers_new::replace_chunk( chunk, false, true );
			windows.clip enable_trigger(); 
			windows.clip DisconnectPaths();
			wait_network_frame();
			wait(0.05);
		}
	}
	wait(0.3);
}

}
star_power( drop_item )
{
	self notify ("star power");
	self endon ("star power");
	self play_sound_on_ent( "weap_type92_act" );
	//self maps\nazi_zombie_factory_teleporter::stareffect();
	//self maps\nazi_zombie_factory_teleporter::Star_effect();
	self thread maps\nazi_zombie_factory_teleporter::teleport_2d_audio();
	self SetTransported( 7 );
	self thread starshockzombies();
	self thread starfxplayer();
	self EnableInvulnerability();
	self thread starrepairwindows();
	self.staractive=true;
	level.fxOrg delete();
	level.fxOrg = Spawn( "script_model", self.origin );
	level.fxOrg SetModel( "tag_origin" );
	fx = PlayFxOnTag( level._effect["tesla_bolt"], level.fxOrg, "tag_origin" );
	fx = PlayFxOnTag( level._effect["tesla_bolt"], level.fxOrg, "tag_origin" );
	fx = PlayFxOnTag( level._effect["tesla_bolt"], level.fxOrg, "tag_origin" );
	self thread starsetmovespeed();
	wait(7);
	if(IsDefined(self.staregg)&&self.staregg==true)
	{
	self.staregg=false;
	wait(20);
	}
	//self play_sound_on_ent( "Star" );
	//wait(7);
		self notify("stop star kill zombies");
	self SetTransported( 0 );
	//wait(0.1);
	// end fps fx
	self.staractive=false;
	self notify( "fx_done" );
	self DisableInvulnerability();
	self setMoveSpeedScale( 1 ); 
	self thread maps\nazi_zombie_factory_teleporter::teleporter_vo( "vox_tele_sick" );
	level.fxOrg delete();
}

ray_gun_power( drop_item )
{
	self notify ("ray power");
	self endon ("ray power");
	if(!(IsDefined(self.haslaserpower)&&self.haslaserpower==true))
	{
	self raygun_take_player_weapons();
	}
	self.haslaserpower=true;
	self raygun_give_pistol();
	self thread ray_gun_give_ammo();
	wait(30);
	raygun_giveback_player_weapons();
	self notify("stopraygunammo");
	self.haslaserpower=false;
}
ray_gun_give_ammo()
{
self endon("stopraygunammo");
while(1)
{
self SetWeaponAmmoClip( "ray_gun", WeaponClipSize( "ray_gun" ) );
wait(0.1);
}
}

// self = a player
raygun_take_player_weapons()
{
	self.laserweaponInventory = self GetWeaponsList();
	self.lastActiveWeapon = self GetCurrentWeapon();
	self.laststandpistol = undefined;
	
	//ASSERTEX( self.lastActiveWeapon != "none", "Last active weapon is 'none,' an unexpected result." );

	self.weaponAmmo = [];

	for( i = 0; i < self.laserweaponInventory.size; i++ )
	{
		weapon = self.laserweaponInventory[i];
		switch( weapon )
		{
		// this player was killed while reviving another player
		case "syrette": 
		// player was killed drinking perks-a-cola
		case "zombie_perk_bottle_doubletap": 
		case "zombie_perk_bottle_revive":
		case "zombie_perk_bottle_jugg":
		case "zombie_perk_bottle_sleight":
		case "zombie_bowie_flourish":
		case "zombie_knuckle_crack":
			self.lastActiveWeapon = "none";
			continue;
		}

		self.weaponAmmo[weapon]["clip"] = self GetWeaponAmmoClip( weapon );
		self.weaponAmmo[weapon]["stock"] = self GetWeaponAmmoStock( weapon );
	}

	self TakeAllWeapons();

}

raygun_give_pistol()
{
	//assert( IsDefined( self.laststandpistol ) );
	//assert( self.laststandpistol != "none" );
	//assert( WeaponClass( self.laststandpistol ) == "pistol" );

	if( GetDvar( "zombiemode" ) == "1" || IsSubStr( level.script, "nazi_zombie_" ) ) // CODER_MOD (Austin 5/4/08): zombiemode loadout setup
	{
		self GiveWeapon( "ray_gun" );
		ammoclip = WeaponClipSize( "ray_gun" );
		
		if (self.laststandpistol == "ray_gun")
		{
			
			self SetWeaponAmmoClip( "ray_gun", ammoclip );
			self SetWeaponAmmoStock( "ray_gun", ammoclip*5 );
			
		}
		
		
		self SwitchToWeapon( "ray_gun" );
	}
	else
	{
		self GiveWeapon( "ray_gun" );
		self GiveMaxAmmo( "ray_gun" );
		self SwitchToWeapon( "ray_gun" );
	}
	

}



// self = a player
raygun_giveback_player_weapons()
{
	ASSERTEX( IsDefined( self.laserweaponInventory ), "player.laserweaponInventory is not defined - did you run laststand_take_player_weapons() first?" );

	self TakeAllWeapons();

	for( i = 0; i < self.laserweaponInventory.size; i++ )
	{
		weapon = self.laserweaponInventory[i];

		switch( weapon )
		{
		// this player was killed while reviving another player
		case "syrette": 
		// player was killed drinking perks-a-cola
		case "zombie_perk_bottle_doubletap": 
		case "zombie_perk_bottle_revive":
		case "zombie_perk_bottle_jugg":
		case "zombie_perk_bottle_sleight":
		case "zombie_bowie_flourish":
		case "zombie_knuckle_crack":
			continue;
		}

		self GiveWeapon( weapon );
		self SetWeaponAmmoClip( weapon, self.weaponAmmo[weapon]["clip"] );

		if ( WeaponType( weapon ) != "grenade" )
			self SetWeaponAmmoStock( weapon, self.weaponAmmo[weapon]["stock"] );
	}

	// if we can't figure out what the last active weapon was, try to switch a primary weapon
	//CHRIS_P: - don't try to give the player back the mortar_round weapon ( this is if the player killed himself with a mortar round)
	if( self.lastActiveWeapon != "none" && self.lastActiveWeapon != "mortar_round" && self.lastActiveWeapon != "mine_bouncing_betty" )
	{
		self SwitchToWeapon( self.lastActiveWeapon );
	}
	else
	{
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
	}
}


// double the points
double_points_powerup( drop_item )
{
	level notify ("powerup points scaled");
	level endon ("powerup points scaled");

	//	players = get_players();	
	//	array_thread(level,::point_doubler_on_hud, drop_item);
	level thread point_doubler_on_hud( drop_item );

	level.zombie_vars["zombie_point_scalar"] = level.zombie_vars["zombie_point_scalar"]*2;
	wait 30;

	level.zombie_vars["zombie_point_scalar"] = 1;
}

teddy_powerup( drop_item )
{
teddy = spawn( "script_model", drop_item.origin );
teddy SetModel("zombie_teddybear");
teddy.isateddy=true;
teddy MoveZ(60, 4, 3);
fx = PlayFxOnTag( level._effect["tesla_bolt"], teddy, "tag_origin" );
playsoundatposition( "tesla_bounce", teddy.origin );
teddy waittill("movedone");
teddy thread Kill_zombies_Teddy();
teddy.tag_origin playsound("elec_start");
	teddy.tag_origin playloopsound("elec_loop");
	teddy thread maps\nazi_zombie_factory::play_electrical_sound();
wait(30);
teddy notify ("teddy stop killing");
teddy.tag_origin stoploopsound();
effecttag = spawn( "script_model", teddy.origin );
level notify ("arc_done");	
teddy delete();
effecttag SetModel( "tag_origin" );
PlayFxOnTag( level._effect["dog_gib"], effecttag, "tag_origin" );
wait(2);
effecttag delete();
}

Kill_zombies_Teddy()
{
self endon("teddy stop killing");
while(1)
{
zombies = getaispeciesarray("axis");

	zombies = get_array_of_closest( self.origin, zombies, undefined, 20, 250 );

	for (i = 0; i < zombies.size; i++)
	{
		wait (randomfloatrange(0.2, 0.3));
		if( !IsDefined( zombies[i] ) )
		{
			continue;
		}

		if( is_magic_bullet_shield_enabled( zombies[i] ) )
		{
			continue;
		}
		fxOrg = Spawn( "script_model", self.origin );
	fxOrg SetModel( "tag_origin" );

	fx = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
	fx = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
	fx = PlayFxOnTag( level._effect["tesla_bolt"], fxOrg, "tag_origin" );
	playsoundatposition( "tesla_bounce", fxOrg.origin );
	
	fxOrg MoveTo( zombies[i].origin, 0.1 );
	fxOrg waittill( "movedone" );
	fxOrg delete();
		zombies[i] thread maps\nazi_zombie_factory::zombie_elec_death(0);
	}
		wait(0.1);
	}
}

fire_sale_powerup( drop_item )
{
level notify ("fire sale started");
level endon ("fire sale started");
if(!IsDefined(level.firesaleactive)||level.firesaleactive==false)
{
level.firesalerealchest=level.chest_index;


	self maps\_zombiemode_weapons::WriteScreenText("Fire Sale!");
	for( i = 0; i < level.chests.size; i++ )
	{
	if(i!=level.firesalerealchest)
	{
	level.chests[i] thread maps\_zombiemode_weapons::show_magic_box(false);
	thread maps\_zombiemode_weapons::unhide_magic_box( i );
	}
	//level.chests[i] set_hint_string( level.chests[i], "default_treasure_chest_" + 10 );
	//level.chests[i] SetHintString ("Press & hold F to buy Random Weapon [Cost: 10]");
	}
	
	//maps\_zombiemode_weapons::set_treasure_chest_cost( "10" );
	}
	level.firesaleactive=true;
	wait(30);
	level.firesaleactive=false;
	//maps\_zombiemode_weapons::set_treasure_chest_cost( "950" );
	for( i = 0; i < level.chests.size; i++ )
	{
	if(i!=level.firesalerealchest)
	{
	level.chests[i] thread maps\_zombiemode_weapons::firesale_chest_fly_off(level.chests[i] maps\_zombiemode_weapons::get_chest_pieces()[1]);
	self thread BlockChest();
	}
	//level.chests[i] set_hint_string( level.chests[i], "default_treasure_chest_" + 950 );
	//level.chests[i] SetHintString ("Press & hold F to buy Random Weapon [Cost: 950]");
	level.chest_accessed=0;
	}
	
}
BlockChest()
{
self.isblocked=true;
wait(4);
self.isblocked=false;
}
full_ammo_powerup( drop_item )
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
	//	array_thread (players, ::full_ammo_on_hud, drop_item);
	level thread full_ammo_on_hud( drop_item );
}

insta_kill_powerup( drop_item )
{
	level notify( "powerup instakill" );
	level endon( "powerup instakill" );

		
	//	array_thread (players, ::insta_kill_on_hud, drop_item);
	level thread insta_kill_on_hud( drop_item );

	level.zombie_vars["zombie_insta_kill"] = 1;
	wait( 30 );
	level.zombie_vars["zombie_insta_kill"] = 0;
	players = get_players();
	for(i = 0; i < players.size; i++)
	{
		players[i] notify("insta_kill_over");

	}

}

check_for_instakill( player )
{
	if( IsDefined( player ) && IsAlive( player ) && level.zombie_vars["zombie_insta_kill"])
	{
		if( is_magic_bullet_shield_enabled( self ) )
		{
			return;
		}

		if( self.animname == "boss_zombie" )
		{
			return;
		}

		if(player.use_weapon_type == "MOD_MELEE")
		{
			player.last_kill_method = "MOD_MELEE";
		}
		else
		{
			player.last_kill_method = "MOD_UNKNOWN";

		}

		if( flag( "dog_round" ) )
		{
			self DoDamage( self.health + 666, self.origin, player );
			player notify("zombie_killed");
		}
		else
		{
			self maps\_zombiemode_spawner::zombie_head_gib();
			self DoDamage( self.health + 666, self.origin, player );
			player notify("zombie_killed");
			
		}
	}
}

insta_kill_on_hud( drop_item )
{
	self endon ("disconnect");

	// check to see if this is on or not
	if ( level.zombie_vars["zombie_powerup_insta_kill_on"] )
	{
		// reset the time and keep going
		level.zombie_vars["zombie_powerup_insta_kill_time"] = 30;
		return;
	}

	level.zombie_vars["zombie_powerup_insta_kill_on"] = true;

	// set up the hudelem
	//hudelem = maps\_hud_util::createFontString( "objective", 2 );
	//hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] + level.zombie_vars["zombie_timer_offset_interval"]);
	//hudelem.sort = 0.5;
	//hudelem.alpha = 0;
	//hudelem fadeovertime(0.5);
	//hudelem.alpha = 1;
	//hudelem.label = drop_item.hint;

	// set time remaining for insta kill
	level thread time_remaning_on_insta_kill_powerup();		

	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}

time_remaning_on_insta_kill_powerup()
{
	//self setvalue( level.zombie_vars["zombie_powerup_insta_kill_time"] );
	level thread play_devil_dialog("insta_vox");
	temp_enta = spawn("script_origin", (0,0,0));
	temp_enta playloopsound("insta_kill_loop");	

	/*
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
	players[i] playloopsound ("insta_kill_loop");
	}
	*/


	// time it down!
	while ( level.zombie_vars["zombie_powerup_insta_kill_time"] >= 0)
	{
		wait 0.1;
		level.zombie_vars["zombie_powerup_insta_kill_time"] = level.zombie_vars["zombie_powerup_insta_kill_time"] - 0.1;
	//	self setvalue( level.zombie_vars["zombie_powerup_insta_kill_time"] );	
	}

	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		//players[i] stoploopsound (2);

		players[i] playsound("insta_kill");

	}

	temp_enta stoploopsound(2);
	// turn off the timer
	level.zombie_vars["zombie_powerup_insta_kill_on"] = false;

	// remove the offset to make room for new powerups, reset timer for next time
	level.zombie_vars["zombie_powerup_insta_kill_time"] = 30;
	//level.zombie_timer_offset += level.zombie_timer_offset_interval;
	//self destroy();
	temp_enta delete();
}

point_doubler_on_hud( drop_item )
{
	self endon ("disconnect");

	// check to see if this is on or not
	if ( level.zombie_vars["zombie_powerup_point_doubler_on"] )
	{
		// reset the time and keep going
		level.zombie_vars["zombie_powerup_point_doubler_time"] = 30;
		return;
	}

	level.zombie_vars["zombie_powerup_point_doubler_on"] = true;
	//level.powerup_hud_array[0] = true;
	// set up the hudelem
	//hudelem = maps\_hud_util::createFontString( "objective", 2 );
	//hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] );
	//hudelem.sort = 0.5;
	//hudelem.alpha = 0;
	//hudelem fadeovertime( 0.5 );
	//hudelem.alpha = 1;
	//hudelem.label = drop_item.hint;

	// set time remaining for point doubler
	level thread time_remaining_on_point_doubler_powerup();		

	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}
play_devil_dialog(sound_to_play)
{
	if(!IsDefined(level.devil_is_speaking))
	{
		level.devil_is_speaking = 0;
	}
	if(level.devil_is_speaking == 0)
	{
		level.devil_is_speaking = 1;
		play_sound_2D( sound_to_play );
		wait 2.0;
		level.devil_is_speaking =0;
	}
	
}
time_remaining_on_point_doubler_powerup()
{
	//self setvalue( level.zombie_vars["zombie_powerup_point_doubler_time"] );
	
	temp_ent = spawn("script_origin", (0,0,0));
	temp_ent playloopsound ("double_point_loop");
	
	level thread play_devil_dialog("dp_vox");
	
	
	// time it down!
	while ( level.zombie_vars["zombie_powerup_point_doubler_time"] >= 0)
	{
		wait 0.1;
		level.zombie_vars["zombie_powerup_point_doubler_time"] = level.zombie_vars["zombie_powerup_point_doubler_time"] - 0.1;
		//self setvalue( level.zombie_vars["zombie_powerup_point_doubler_time"] );	
	}

	// turn off the timer
	level.zombie_vars["zombie_powerup_point_doubler_on"] = false;
	players = get_players();
	for (i = 0; i < players.size; i++)
	{
		//players[i] stoploopsound("double_point_loop", 2);
		players[i] playsound("points_loop_off");
	}
	temp_ent stoploopsound(2);


	// remove the offset to make room for new powerups, reset timer for next time
	level.zombie_vars["zombie_powerup_point_doubler_time"] = 30;
	//level.zombie_timer_offset += level.zombie_timer_offset_interval;
	//self destroy();
	temp_ent delete();
}
devil_dialog_delay()
{
	wait(1.8);
	level thread play_devil_dialog("nuke_vox");
	
}
full_ammo_on_hud( drop_item )
{
	self endon ("disconnect");

	// set up the hudelem
	hudelem = maps\_hud_util::createFontString( "objective", 2 );
	hudelem maps\_hud_util::setPoint( "TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] - (level.zombie_vars["zombie_timer_offset_interval"] * 2));
	hudelem.sort = 0.5;
	hudelem.alpha = 0;
	hudelem fadeovertime(0.5);
	hudelem.alpha = 1;
	hudelem.label = drop_item.hint;

	// set time remaining for insta kill
	hudelem thread full_ammo_move_hud();		

	// offset in case we get another powerup
	//level.zombie_timer_offset -= level.zombie_timer_offset_interval;
}

full_ammo_move_hud()
{

	players = get_players();
	level thread play_devil_dialog("ma_vox");
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

//
// DEBUG
//

print_powerup_drop( powerup, type )
{
	/#
		if( !IsDefined( level.powerup_drop_time ) )
		{
			level.powerup_drop_time = 0;
			level.powerup_random_count = 0;
			level.powerup_score_count = 0;
		}

		time = ( GetTime() - level.powerup_drop_time ) * 0.001;
		level.powerup_drop_time = GetTime();

		if( type == "random" )
		{
			level.powerup_random_count++;
		}
		else
		{
			level.powerup_score_count++;
		}

		println( "========== POWER UP DROPPED ==========" );
		println( "DROPPED: " + powerup );
		println( "HOW IT DROPPED: " + type );
		println( "--------------------" );
		println( "Drop Time: " + time );
		println( "Random Powerup Count: " + level.powerup_random_count );
		println( "Random Powerup Count: " + level.powerup_score_count );
		println( "======================================" );
#/
}
