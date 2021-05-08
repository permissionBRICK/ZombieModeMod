#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility; 

init( achievement, var1, var2, var3, var4, var5, var6 )
{

	if( !isdefined( achievement ) )
	{
		return;
	}
	players = get_players();

	switch( achievement )
	{
	case "achievement_shiny":
		array_thread( players, ::achievement_give_on_notify, "DLC3_ZOMBIE_PAP_ONCE", "So shiny!",1000 );
		break; 
	case "achievement_monkey_see":
		array_thread( players, ::achievement_monkey_see, "DLC3_ZOMBIE_USE_MONKEY", "Achievement_throw_monkeys", 10,"Monkey-Hell!",2000 );
		break; 
	case "achievement_all_perks":
		array_thread( players, ::achievement_give_on_notify, "DLC3_ZOMBIE_ALL_PERKS", "Perk-o-holic!",2000 );
		array_thread( players, ::achievement_give_on_notify, "DLC3_ZOMBIE_ALL_PERKS_TWICE", "Perk-o-holic X-TREME!",5000 );
		break; 
	case "achievement_good_player":
		array_thread( players, ::achievement_give_on_counter, "DLC3_ZOMBIE_GAVE_WEAPON", "Achievement_good_player", 5, "Generous!",2000 );
		break; 
	case "achievement_frequent_flyer":
		array_thread( players, ::achievement_give_on_counter, "DLC3_ZOMBIE_FIVE_TELEPORTS", "Achievement_frequent_flier", 8, "Frequent traveler!",2500 );
		break; 
	case "achievement_this_is_a_knife":
		array_thread( players, ::achievement_give_on_counter, "DLC3_ZOMBIE_BOWIE_KILLS", "Achievement_this_is_a_knife", 40 , "This is a knife!",4000);
		break; 

	case "achievement_martian_weapon":
		array_thread( players, ::Achievement_martian_weapons);
		array_thread( players, ::Achievement_martian_weapons_upgraded);
		break; 

	case "achievement_double_whammy":
		array_thread( players, ::achievement_give_on_counter, "DLC3_ZOMBIE_TWO_UPGRADED", "Achievement_five_upgrades", 5, "Pack-o-holic!",5000);
		break; 

	case "achievement_perkaholic":
		array_thread( players, ::Achievement_Perkholic_Anon);
		break; 

	case "achievement_secret_weapon":
		level thread achievement_give_on_notify( "DLC3_ZOMBIE_ANTI_GRAVITY","Hide and Seek!",100 );
		break; 
	case "achievement_found_eggs":
		level thread achievement_give_on_notify( "DLC3_ZOMBIE_FOUND_EGGS","Game Over!",1000 );
		break; 
	case "achievement_power_on":
		level thread achievement_give_on_notify( "DLC3_ZOMBIE_POWER_ON","The Power to survive!",500 );
		break; 
	case "achievement_no_more_door":
		level thread achievement_give_on_counter( "DLC3_ZOMBIE_ALL_DOORS", "Achievement_Doors_in Giant", 9,"Open Doors Day!",4000 );
		break; 

	case "achievement_back_to_future":
		level thread achievement_give_on_notify( "DLC3_ZOMBIE_FAST_LINK","1337!",5000 );
		break; 

	default:
		iprintln( achievement + " not found! " );
		break; 
	}

}
achievement_reward(reward)
{
wait(1);
self play_sound_on_ent( "purchase" );
wait(1);
self play_sound_on_ent( "purchase" );
maps\_zombiemode_score::add_to_player_score(reward);
wait(0.5);
self play_sound_on_ent( "purchase" );
wait(0.8);
self play_sound_on_ent( "purchase" );
}

achievement_give_on_notify( notify_name, debug_text,reward )
{
	if ( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	self waittill( notify_name );

	self playsound("perks_power_on");
		if ( !IsDefined( debug_text ) )
		{
			debug_text = notify_name;
		}
		if( Isplayer ( self ) )
		{
			self iprintln( "Achievement: '" + debug_text + "' unlocked." );
			self thread achievement_reward(reward);
		}
		else
		{
		players = get_players();
			iprintln( "Achievement: '" + debug_text + "' unlocked." );
			array_thread( players, ::achievement_reward, reward );
			}
		
	

	if ( IsPlayer( self ) )
	{
		self giveachievement_wrapper( notify_name ); 
	}
	else
	{
		giveachievement_wrapper( notify_name, true ); 
	}
}

achievement_give_on_counter( notify_name, counter_name, counter_num, debug_text, reward )
{

	if ( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	counter = 0;
	set_zombie_var( counter_name, counter_num );

	while( 1 )
	{
		self waittill( notify_name );
		counter += 1;
		if( counter >= level.zombie_vars[counter_name] )
		{
			self playsound("perks_power_on");
				if ( !IsDefined( debug_text ) )
				{
					debug_text = notify_name;
				}

				if( Isplayer ( self ) )
				{
					self iprintln( "Achievement: '" + debug_text + "' unlocked." );
					self thread achievement_reward(reward);
				}
				else
					{
		players = get_players();
			iprintln( "Achievement: '" + debug_text + "' unlocked." );
			array_thread( players, ::achievement_reward, reward );
			}
			
	
			if( isPlayer( self ) )
			{
				self giveachievement_wrapper( notify_name );
				return;
			}
			else
			{
				giveachievement_wrapper( notify_name, true );
				return;
			}
		}
	}
}
Achievement_martian_weapons()
{

	self endon( "disconnect" );

	while( 1 )
	{
		self waittill( "weapon_change" );
		martian_weapon_owned  = 0;

		if( self.sessionstate == "spectator" )
		{
			wait( 0.05 );
			continue;
		}

		if( self maps\_zombiemode_weapons::has_weapon_or_upgrade( "tesla_gun" ) )
		{
			martian_weapon_owned += 1;
		}

		if( self maps\_zombiemode_weapons::has_weapon_or_upgrade( "ray_gun" ) )
		{
			martian_weapon_owned += 1;
		}
		
		if( self HasWeapon( "zombie_cymbal_monkey" ) )
		{
			martian_weapon_owned += 1;
		}
		
		if( martian_weapon_owned >= 3 )
		{
			
				self iprintln( "Achievement: 'Alien!' unlocked." );
			self thread achievement_reward(2000);
			self giveachievement_wrapper( "DLC3_ZOMBIE_RAY_TESLA" ); 
			return;
		}
	}
}

Achievement_martian_weapons_upgraded()
{

	self endon( "disconnect" );

	while( 1 )
	{
		self waittill( "weapon_change" );
		martian_weapon_owned  = 0;

		if( self.sessionstate == "spectator" )
		{
			wait( 0.05 );
			continue;
		}

		if( self maps\_zombiemode_weapons::has_weapon_or_upgrade( "tesla_gun_upgraded" ) )
		{
			martian_weapon_owned += 1;
		}

		if( self maps\_zombiemode_weapons::has_weapon_or_upgrade( "ray_gun_upgraded" ) )
		{
			martian_weapon_owned += 1;
		}
		
		if( self HasWeapon( "zombie_cymbal_monkey" )&&IsDefined(self.monkeyupgraded)&&self.monkeyupgraded==true )
		{
			martian_weapon_owned += 1;
		}
		
		if( martian_weapon_owned >= 3 )
		{
			
				self iprintln( "Achievement: 'Alien! eXtreme' unlocked." );
			self thread achievement_reward(5000);
			self giveachievement_wrapper( "DLC3_ZOMBIE_RAY_TESLA" ); 
			return;
		}
	}
}

Achievement_Perkholic_Anon()
{
	self endon( "disconnect" );
	self endon( "perk_used" );
	set_zombie_var( "Achievement_Perkholic_Anon", 20 );
	
	while( 1 )
	{
		level waittill( "between_round_over" );

		if( level.round_number == level.zombie_vars["Achievement_Perkholic_Anon"])
		{
			
				self iprintln( "Achievement: 'dry Perkoholic' unlocked." );
			self thread achievement_reward(5000);
			self giveachievement_wrapper( "DLC3_ZOMBIE_NO_PERKS" );
			break;
		}


	}

}

achievement_monkey_see( notify_name, counter_name, counter_num, debug_text, reward )
{

	if ( IsPlayer( self ) )
	{
		self endon( "disconnect" );
	}

	counter = 0;
	set_zombie_var( counter_name, counter_num );

	while( 1 )
	{
		self waittill( notify_name );
		counter += 1;
		if( counter >= level.zombie_vars[counter_name] )
		{
			
				if ( !IsDefined( debug_text ) )
				{
					debug_text = notify_name;
				}

				if( Isplayer ( self ) )
				{
					self iprintln( "Achievement: 'Monkey-Hell' unlocked." );
					self thread achievement_reward(reward);
				}
				return;
		
		}
	}
}