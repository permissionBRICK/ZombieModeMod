// For the cymbal monkey weapon
#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
	level._effect["monkey_glow"] 	= loadfx( "maps/zombie/fx_zombie_monkey_light" );
}

player_give_cymbal_monkey()
{
	self giveweapon( "zombie_cymbal_monkey" );
	self thread player_handle_cymbal_monkey();
}

#using_animtree( "zombie_cymbal_monkey" );
player_handle_cymbal_monkey()
{
	if(!IsDefined(self.monkeyupgraded))
	{
		self.monkeyupgraded=false;
	}
	self notify( "starting_monkey_watch" );
	self endon( "disconnect" );
	self endon( "starting_monkey_watch" );
	
	// Min distance to attract positions
	attract_dist_diff = level.monkey_attract_dist_diff;
	if( !isDefined( attract_dist_diff ) )
	{
		attract_dist_diff = 45;
	}
		
	num_attractors = level.num_monkey_attractors;
	if( !isDefined( num_attractors ) )
	{
		num_attractors = 96;
	}
	
	max_attract_dist = level.monkey_attract_dist;
	if( !isDefined( max_attract_dist ) )
	{
		max_attract_dist = 1536;
	}
	
	while( true )
	{
		grenade = get_thrown_monkey();
		if( IsDefined( grenade ) )
		{
			if( self maps\_laststand::player_is_in_laststand() )
			{
				grenade delete();
				continue;
			}
			grenade hide();
			model = spawn( "script_model", grenade.origin );
			model SetModel( "weapon_zombie_monkey_bomb" );
			model UseAnimTree( #animtree );
			model linkTo( grenade );
			model.angles = grenade.angles;
			grenade thread monitor_zombie_groans();
			velocitySq = 10000*10000;
			oldPos = grenade.origin;
			grenade create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000 );
			grenade.attract_to_origin = true;
			stopthis=false;
			while( velocitySq != 0 )
			{
				wait( 0.05 );
				velocitySq = distanceSquared( grenade.origin, oldPos );
				oldPos = grenade.origin;
				vending_upgrade_trigger = GetEntArray("zombie_vending_upgrade", "targetname");
				if(grenade IsTouching(vending_upgrade_trigger[0])&&self.score >= 5000&&self.monkeyupgraded!=true)
				{
					bowie_trigger = GetEntArray( "bowie_upgrade", "targetname" )[0];
					vending_upgrade_trigger[0] thread maps\_zombiemode_perks::play_vendor_stings("mx_packa_sting");
					playfx (level._effect["powerup_grabbed"], grenade.origin);
					playfx (level._effect["powerup_grabbed_wave"], grenade.origin);
					self maps\_zombiemode_score::minus_to_player_score( 5000 ); 
					sound = "bottle_dispense3d";
					playsoundatposition(sound, vending_upgrade_trigger[0].origin);
					vending_upgrade_trigger[0] play_sound_on_ent( "purchase" );
					vending_upgrade_trigger[0] playsound( "packa_weap_upgrade" );
					self.monkeyupgraded=true;
					stopthis=true;
					model hide();
					continue;
				}
			}
			if(stopthis)
			{
				model delete();
				grenade delete();
				continue;
			}
			if( isDefined( grenade ) )
			{
				self achievement_notify( "DLC3_ZOMBIE_USE_MONKEY" );
				model SetAnim( %o_monkey_bomb );
				model thread monkey_cleanup( grenade );
				
				model unlink();
				model.origin = grenade.origin;
				model.angles = grenade.angles;
				
				grenade resetmissiledetonationtime();
				PlayFxOnTag( level._effect["monkey_glow"], model, "origin_animate_jnt" );
				
				valid_poi = check_point_in_active_zone( grenade.origin );
			
				if( !valid_poi ) 
				{	
					valid_poi = check_point_in_playable_area( grenade.origin );
				}
				
				if(valid_poi)
				{
					grenade thread create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
					grenade thread wait_for_attractor_positions_complete();
				}
				else
				{
					self.script_noteworthy = undefined;
				}
				
				grenade thread do_monkey_sound( model, self );
			}
		}
		wait( 0.05 );
	}
}

wait_for_attractor_positions_complete()
{
	self waittill( "attractor_positions_generated" );
	
	self.attract_to_origin = false;
}

monkey_cleanup( parent )
{
	while( true )
	{
		if( !isDefined( parent ) )
		{
			if( isDefined( self ) )
			{
				self delete();
				return;
			}
		}
		wait( 0.05 );
	}
}

do_monkey_sound( model, player )
{
	monk_scream_vox = false;
	
	if( (isdefined(level.monk_scream_trig)) && self IsTouching( level.monk_scream_trig))
	{
		self playsound( "monkey_scream_vox" );
		monk_scream_vox = true;
	}
	else if( level.eggs == 0 )
	{
		monk_scream_vox = false;
		self playsound( "monkey_song" );
	}
	
	wait( 6.4 );
	if(player.monkeyupgraded==true)
	{
		self resetmissiledetonationtime();
		monk_scream_vox = false;
		
		if( (isdefined(level.monk_scream_trig)) && self IsTouching( level.monk_scream_trig))
		{
			self playsound( "monkey_scream_vox" );
			monk_scream_vox = true;
		}
		else if( level.eggs == 0 )
		{
			monk_scream_vox = false;
			self playsound( "monkey_song" );
		}
		
		wait( 6.4 );
	}
	if( isDefined( model ) )
	{
		model ClearAnim( %o_monkey_bomb, 0.2 );
	}
	
	for( i = 0; i < self.sound_attractors.size; i++ )
	{
		if( isDefined( self.sound_attractors[i] ) )
		{
			self.sound_attractors[i] notify( "monkey_blown_up" );
		}
	}
	
	if( !monk_scream_vox )
	{
		self playsound( "monkey_explo_vox" );
	}
	else if( monk_scream_vox )
	{
		thread play_sam_furnace(player);
	}
}

play_sam_furnace(player)
{
	wait(2);
	play_sound_2d( "sam_furnace_1" );
	wait(2.5);
	play_sound_2d( "sam_furnace_2" );
	wait(3);
	player thread maps\nazi_zombie_factory_teleporter::teleport_aftereffects();
	player thread maps\nazi_zombie_factory_teleporter::teleport_aftereffects();
	player thread maps\nazi_zombie_factory_teleporter::teleport_aftereffects();
	near_zombies = getaiarray("axis");
		for (i = 0; i < near_zombies.size; i++)
		{
		near_zombies[i].favoriteenemy=player;
		}
}

get_thrown_monkey()
{
	self endon( "disconnect" );
	self endon( "starting_monkey_watch" );
	
	while( true ) 
	{
		self waittill( "grenade_fire", grenade, weapName );
		if( weapName == "zombie_cymbal_monkey" )
		{
			return grenade;
		}
		
		wait( 0.05 );
	}
}

monitor_zombie_groans()
{
	self.sound_attractors = [];
	self endon( "monkey_blown_up" );
            
	while( true ) 
	{
		if( !isDefined( self ) )
		{
			return;
		}
		
		if( !isDefined( self.attractor_array ) )
		{
			wait( 0.05 );
			continue;
		}
		
		for( i = 0; i < self.attractor_array.size; i++ )
		{
			if( array_check_for_dupes( self.sound_attractors, self.attractor_array[i] ) )
			{
				if( distanceSquared( self.origin, self.attractor_array[i].origin ) < 500 * 500 )
				{
					self.sound_attractors = array_add( self.sound_attractors, self.attractor_array[i] );
					self.attractor_array[i] thread play_zombie_groans();
				}
			}
		}
		wait( 0.05 );
	}
} 

play_zombie_groans()
{
	self endon( "death" );
	self endon( "monkey_blown_up" );
  //self thread cleanup_zombie_monkey_sounds();
            
	while(1)
	{
		if( isdefined ( self ) )
		{
			self playsound( "zombie_groan_monkey" );
			wait randomfloatrange( 2, 3 );
		}
		else
		{
			return;
		}
	}
}

/*
cleanup_zombie_monkey_sounds()
{
            self waittill_either( "death", "monkey_blown_up" );
            
            // stop playing sounds on this entity
}
*/