#include maps\_utility;
#include maps\_hud_util;

init()
{
	PrecacheItem( "syrette" );
	PrecacheItem( "colt_dirty_harry" );
	precachestring( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
	precachestring( &"GAME_PLAYER_NEEDS_TO_BE_REVIVED" );
	precachestring( &"GAME_PLAYER_IS_REVIVING_YOU" );	
	precachestring( &"GAME_REVIVING" );

	if( !IsDefined( level.laststandpistol ) )
	{
		level.laststandpistol = "colt";
		PrecacheItem( level.laststandpistol );
	}

	//CODER_MOD: TOMMYK 07/13/2008 - Revive text
	if( !arcadeMode() )
	{
		level thread revive_hud_think();
	}

	level.primaryProgressBarX = 0;
	level.primaryProgressBarY = 110;
	level.primaryProgressBarHeight = 4;
	level.primaryProgressBarWidth = 120;

	if ( IsSplitScreen() )
	{
		level.primaryProgressBarY = 280;
	}

	if( GetDvar( "revive_trigger_radius" ) == "" )
	{
		SetDvar( "revive_trigger_radius", "40" ); 
	}
}


player_is_in_laststand()
{
if(IsDefined(self.ignorepower)&&self.ignorepower==true)
{
return( true);
}
	return ( IsDefined( self.revivetrigger ) );
}


player_num_in_laststand()
{
	num = 0;
	players = get_players();

	for ( i = 0; i < players.size; i++ )
	{	
		if ( players[i] player_is_in_laststand() )
			num++;
	}

	return num;
}


player_all_players_in_laststand()
{
	return ( player_num_in_laststand() == get_players().size );
}


player_any_player_in_laststand()
{
	return ( player_num_in_laststand() > 0 );
}


PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if( sMeansOfDeath == "MOD_CRUSH" )		// if getting run over by a tank then kill the guy even if in laststand
	{
		if( self player_is_in_laststand() )
		{
			self mission_failed_during_laststand( self );
		}
		return;
	}

	if( self player_is_in_laststand() )
	{
		return;
	}

	//CODER_MOD: TOMMYK 06/26/2008 - For coop scoreboards
	self.downs++;
	//stat tracking
	self.stats["downs"] = self.downs;
	dvarName = "player" + self GetEntityNumber() + "downs";
	setdvar( dvarName, self.downs );
	
	//PI CHANGE: player shouldn't be able to jump while in last stand mode (only was a problem in water) - specifically disallow this
	if (IsDefined(level.script) && level.script == "nazi_zombie_sumpf")
		self AllowJump(false);
	//END PI CHANGE

	if( IsDefined( level.playerlaststand_func ) )
	{
		[[level.playerlaststand_func]]();
	}
	
	//CODER_MOD: Jay (6/18/2008): callback to challenge system
	maps\_challenges_coop::doMissionCallback( "playerDied", self ); 
		
	if ( !laststand_allowed( sWeapon, sMeansOfDeath, sHitLoc ) )
	{
		self mission_failed_during_laststand( self );
		return;
	}

	// check for all players being in last stand
	if ( player_all_players_in_laststand() )
	{
		self mission_failed_during_laststand( self );
		return;
	}

	// vision set
	self VisionSetLastStand( "laststand", 1 );

	self.health = 1;

	self thread maps\_arcademode::arcadeMode_player_laststand();

	// revive trigger
	self revive_trigger_spawn();

	// laststand weapons
	self laststand_take_player_weapons();
	self laststand_give_pistol();
	self thread laststand_give_grenade();

	// AI
	self.ignoreme = true;
	if(IsDefined(self.hassavedmonkey)&&self.hassavedmonkey==true)
	{
	self thread dropsavedmonkey();
	}
	
	// bleed out timer
	// CHANGE: If the guy has quickrevive, give him 150% bleedout time
	if(self hasperk("specialty_quickrevive")!=true&&self.canselfrevive)
	{
	self thread laststand_bleedout( GetDvarFloat( "player_lastStandBleedoutTime" )*2 );
	
	}
	else
	{
	self thread laststand_bleedout( GetDvarFloat( "player_lastStandBleedoutTime" ) );
	}
	
	self notify( "player_downed" );
}


#using_animtree( "zombie_cymbal_monkey" );
dropsavedmonkey()
{
self.hassavedmonkey=false;
//bowie_triggers = GetEntArray( "bowie_upgrade", "targetname" );
//	for( i = 0; i < bowie_triggers.size; i++ )
//	{
		model = spawn( "script_model",self.origin);
		model SetModel( "weapon_zombie_monkey_bomb" );
		model UseAnimTree( #animtree );
		model thread maps\_zombiemode_cymbal_monkey::monitor_zombie_groans();
		model  maps\_zombiemode_utility::create_zombie_point_of_interest( 1536, 96, 10000 );
		model SetAnim( %o_monkey_bomb );
		self maps\_zombiemode_utility::achievement_notify( "DLC3_ZOMBIE_USE_MONKEY" );
		PlayFxOnTag( level._effect["monkey_glow"], model, "origin_animate_jnt" );
		model thread  maps\_zombiemode_utility::create_zombie_point_of_interest_attractor_positions( 4, 45 );
		model thread maps\_zombiemode_cymbal_monkey::wait_for_attractor_positions_complete();
		model maps\_zombiemode_cymbal_monkey::do_monkey_sound( model, self );
	model SetModel( "tag_origin" );
	PlayFxOnTag( level._effect["dog_gib"], model, "tag_origin" );
	model playsound( "zombie_dog_death" );
	model thread deletetimer();
	self maps\nazi_zombie_factory_teleporter::teleport_nuke(100,500);
//	return;
//	}
	
}
deletetimer()
{
wait( 5 );
	self delete();
}

laststand_allowed( sWeapon, sMeansOfDeath, sHitLoc )
{
	//MOD TK, loads of stuff will now send u into laststand
	if (   sMeansOfDeath != "MOD_PISTOL_BULLET" 
		&& sMeansOfDeath != "MOD_RIFLE_BULLET"
		&& sMeansOfDeath != "MOD_HEAD_SHOT"		
		&& sMeansOfDeath != "MOD_MELEE"
		&& sMeansOfDeath != "MOD_BAYONET" 				
		&& sMeansOfDeath != "MOD_GRENADE"
		&& sMeansOfDeath != "MOD_GRENADE_SPLASH"
		&& sMeansOfDeath != "MOD_PROJECTILE"
		&& sMeansOfDeath != "MOD_PROJECTILE_SPLASH"
		&& sMeansOfDeath != "MOD_EXPLOSIVE"
		&& sMeansOfDeath != "MOD_BURNED")
	{
		return false;	
	}

	if( level.laststandpistol == "none" )
	{
		return false;
	}
	
	return true;
}


// self = a player
laststand_take_player_weapons()
{
	self.weaponInventory = self GetWeaponsList();
	self.lastActiveWeapon = self GetCurrentWeapon();
	self.laststandpistol = undefined;
	
	//ASSERTEX( self.lastActiveWeapon != "none", "Last active weapon is 'none,' an unexpected result." );

	self.weaponAmmo = [];

	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];

		if ( WeaponClass( weapon ) == "pistol" && !IsDefined( self.laststandpistol ) ) 
		{
			self.laststandpistol = weapon;
		}
		
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

	if ( !IsDefined( self.laststandpistol ) )
	{
		self.laststandpistol = level.laststandpistol;
	}

	if ( maps\_collectibles::has_collectible( "collectible_dirtyharry" ) )
	{
		self.laststandpistol = "colt_dirty_harry";
	}
}


// self = a player
laststand_giveback_player_weapons()
{
	ASSERTEX( IsDefined( self.weaponInventory ), "player.weaponInventory is not defined - did you run laststand_take_player_weapons() first?" );

	self TakeAllWeapons();

	for( i = 0; i < self.weaponInventory.size; i++ )
	{
		weapon = self.weaponInventory[i];

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

laststand_clean_up_on_disconnect( playerBeingRevived, reviverGun )
{
	reviveTrigger = playerBeingRevived.revivetrigger;

	playerBeingRevived waittill("disconnect");	
	
	if( isdefined( reviveTrigger ) )
	{
		reviveTrigger delete();
	}
	
	if( isdefined( self.reviveProgressBar ) )
	{
		self.reviveProgressBar destroyElem();
	}
	
	if( isdefined( self.reviveTextHud ) )
	{
		self.reviveTextHud destroy();
	}
	
	self revive_give_back_weapons( reviverGun );
}

laststand_give_pistol()
{
	assert( IsDefined( self.laststandpistol ) );
	assert( self.laststandpistol != "none" );
	//assert( WeaponClass( self.laststandpistol ) == "pistol" );

	if( GetDvar( "zombiemode" ) == "1" || IsSubStr( level.script, "nazi_zombie_" ) ) // CODER_MOD (Austin 5/4/08): zombiemode loadout setup
	{
	if(self hasperk("specialty_quickrevive"))
	{
	self.laststandpistol="ray_gun";
	}
		self GiveWeapon( self.laststandpistol );
		ammoclip = WeaponClipSize( self.laststandpistol );
		
		if (self.laststandpistol == "ray_gun")
		{
			if(self hasperk("specialty_quickrevive"))
			{
			self SetWeaponAmmoClip( self.laststandpistol, ammoclip );
			self SetWeaponAmmoStock( self.laststandpistol, ammoclip );
			}
			else
			{
			self SetWeaponAmmoClip( self.laststandpistol, ammoclip );
			self SetWeaponAmmoStock( self.laststandpistol, 0 );
			}
		}
		else
		{
		if(self hasperk("specialty_quickrevive"))
			{
			self SetWeaponAmmoStock( self.laststandpistol, ammoclip * 4 );
			}
			else
			{
			self SetWeaponAmmoStock( self.laststandpistol, ammoclip * 2 );
			}
		}
		
		self SwitchToWeapon( self.laststandpistol );
	}
	else
	{
		self GiveWeapon( self.laststandpistol );
		self GiveMaxAmmo( self.laststandpistol );
		self SwitchToWeapon( self.laststandpistol );
	}
	

}


laststand_give_grenade()
{
	self endon ("player_revived");
	self endon ("disconnect");
	
	while( self isThrowingGrenade() )
	{
		wait( 0.05 );
	}
	// needed to throw back grenades while in last stand
	if( level.campaign == "russian" )
	{
		grenade_choice = "stick_grenade";
	}
	// MM (7/8/9) - give the player german grenades because that's the only kind we're using
	else if( GetDvar( "zombiemode" ) == "1" || IsSubStr( level.script, "nazi_zombie_" ) )
	{
		grenade_choice = "stielhandgranate";
	}
	else
	{
		grenade_choice = "fraggrenade";
	}
	self GiveWeapon( grenade_choice );
	self SetWeaponAmmoClip( grenade_choice, 0 );
	self SwitchToOffhand( grenade_choice );
}


laststand_bleedout( delay )
{
	self endon ("player_revived");
	self endon ("disconnect");

	//self PlayLoopSound("heart_beat",delay);	// happens on client now DSL

	// Notify client that we're in last stand.
	
	setClientSysState("lsm", "1", self);

	self.bleedout_time = delay;

	while ( self.bleedout_time > Int( delay * 0.5 ) )
	{
		self.bleedout_time -= 1;
		wait( 1 );
	}

	self VisionSetLastStand( "death", delay * 0.5 );

	while ( self.bleedout_time > 0 )
	{
		self.bleedout_time -= 1;
		wait( 1 );
	}
	
	//CODER_MOD: TOMMYK 07/13/2008
	while( self.revivetrigger.beingRevived == 1 )
	{
		wait( 0.1 );
	}
	if(self.canselfrevive==true)
	{
	self revive_success( self );
	self.canselfrevive=false;
	wait(0.1);
	}
	setClientSysState("lsm", "0", self);	// Notify client last stand ended.
	
	if (isdefined(level.is_zombie_level ) && level.is_zombie_level)
	{
		self [[level.player_becomes_zombie]]();
	}
	else
	{
		self.ignoreme = false;
		self mission_failed_during_laststand( self );		
	}
}


// spawns the trigger used for the player to get revived
revive_trigger_spawn()
{
	radius = GetDvarInt( "revive_trigger_radius" );

	self.revivetrigger = spawn( "trigger_radius", self.origin, 0, radius, radius );
	self.revivetrigger setHintString( "" ); // only show the hint string if the triggerer is facing me
	self.revivetrigger setCursorHint( "HINT_NOICON" );

	self.revivetrigger EnableLinkTo();
	self.revivetrigger LinkTo( self );  

	//CODER_MOD: TOMMYK 07/13/2008 - Revive text
	self.revivetrigger.beingRevived = 0;
	self.revivetrigger.createtime = gettime();
		
	if ( maps\_collectibles::has_collectible( "collectible_morphine" ) )
	{
		self maps\_collectibles_game::morphine_think();
	}
	else
	{
		self thread revive_trigger_think();
	}

	//self.revivetrigger thread revive_debug();
}

revive_debug()
{
	for ( ;; )
	{
		self waittill( "trigger", player );

		if ( !player player_is_in_laststand() )
			iprintln( "revive triggered!" );

		wait( 0.05 );
	}
}

// logic for the revive trigger
revive_trigger_think()
{
	self endon ( "disconnect" );
	self endon ( "zombified" );
	
	while ( 1 )
	{
		wait ( 0.1 );

		//assert( DistanceSquared( self.origin, self.revivetrigger.origin ) <= 25 );
		//drawcylinder( self.revivetrigger.origin, 32, 32 );

		players = get_players();
			
		self.revivetrigger setHintString( "" );
		
		for ( i = 0; i < players.size; i++ )
		{
			//PI CHANGES - revive should work in deep water for nazi_zombie_sumpf
			is_sumpf = 0;
			d = 0;
			if (IsDefined(level.script) && level.script == "nazi_zombie_sumpf")
			{
					is_sumpf = 1;
					d = self depthinwater();
			}
				
			if ( players[i] can_revive( self ) || 
				(is_sumpf == 1 && d > 20))
			//END PI CHANGES
			{
				// TODO: This will turn on the trigger hint for every player within
				// the radius once one of them faces the revivee, even if the others
				// are facing away. Either we have to display the hints manually here
				// (making sure to prioritize against any other hints from nearby objects),
				// or we need a new combined radius+lookat trigger type.						
				self.revivetrigger setHintString( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
				break;			
			}
		}
		
		for ( i = 0; i < players.size; i++ )
		{
			reviver = players[i];
			
			if ( !reviver is_reviving( self ) )
				continue;
			
			// give the syrette
			gun = reviver GetCurrentWeapon();
			assert( IsDefined( gun ) );
			//assert( gun != "none" );
			if ( gun == "syrette" )
				continue;

			reviver GiveWeapon( "syrette" );
			reviver SwitchToWeapon( "syrette" );
			reviver DisableWeaponCycling();
			reviver DisableOffhandWeapons();
			reviver SetWeaponAmmoStock( "syrette", 1 );

			//CODER_MOD: TOMMY K
			revive_success = reviver revive_do_revive( self, gun );
			
			reviver revive_give_back_weapons( gun );
			
			//PI CHANGE: player couldn't jump - allow this again now that they are revived
			if (IsDefined(level.script) && level.script == "nazi_zombie_sumpf")
				self AllowJump(true);
			//END PI CHANGE

			if ( revive_success )
			{
				self thread revive_success( reviver );
				return;
			}
		}
	}
}

revive_give_back_weapons( gun )
{
	// take the syrette
	self TakeWeapon( "syrette" );
	self EnableWeaponCycling();
	self EnableOffhandWeapons();
	
	if ( gun != "none" && gun != "mine_bouncing_betty" )
	{
		self SwitchToWeapon( gun );
	}
	else 
	{
		// try to switch to first primary weapon
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
	}
	if(IsDefined(self.ishacker)&&self.has_hacker==1)
	{
		self giveweapon(level.hacker);
		self setactionslot(4,"weapon",level.hacker);
		self setweaponammostock(level.hacker,10);
		self GiveMaxAmmo(level.hacker);
	}
}


can_revive( revivee )
{
if(!IsDefined(revivee.isteddy))
{
	if ( !isAlive( self ) )
		return false;

	if ( self player_is_in_laststand() )
		return false;
		
	if( !isDefined( revivee.revivetrigger ) )
		return false;
	
	if ( !self IsTouching( revivee.revivetrigger ) )
		return false;
		
	//PI CHANGE: can revive in deep water in sumpf
	if (IsDefined(level.script) && level.script == "nazi_zombie_sumpf" && (revivee depthinwater() > 10))
		return true;
	//END PI CHANGE
}
	if ( !self is_facing( revivee ) )
		return false;
		
	if( !SightTracePassed( self.origin + ( 0, 0, 50 ), revivee.origin + ( 0, 0, 30 ), false, undefined ) )				
		return false;
	
	//chrisp - fix issue where guys can sometimes revive thru a wall	
	if(!bullettracepassed(self.origin + (0,0,50), revivee.origin + ( 0, 0, 30 ), false, undefined) )
	{
		return false;
	}
	
	// SRS 9/2/2008: in zombie mode, disallow revive if potential reviver is a zombie
	if( IsDefined( level.is_zombie_level ) && level.is_zombie_level )
	{
		if( IsDefined( self.is_zombie ) && self.is_zombie )
		{
			return false;
		}
	}

	//if the level is nazi_zombie_asylum and playeris drinking, disable the trigger
	if(level.script == "nazi_zombie_asylum" && isdefined(self.is_drinking))
		return false;

	if(level.script == "nazi_zombie_sumpf" && isdefined(self.is_drinking))
		return false;

	return true;
}

is_reviving( revivee )
{	
	return ( can_revive( revivee ) && self UseButtonPressed() );
}

is_facing( facee )
{
	orientation = self getPlayerAngles();
	forwardVec = anglesToForward( orientation );
	forwardVec2D = ( forwardVec[0], forwardVec[1], 0 );
	unitForwardVec2D = VectorNormalize( forwardVec2D );
	toFaceeVec = facee.origin - self.origin;
	toFaceeVec2D = ( toFaceeVec[0], toFaceeVec[1], 0 );
	unitToFaceeVec2D = VectorNormalize( toFaceeVec2D );
	
	dotProduct = VectorDot( unitForwardVec2D, unitToFaceeVec2D );
	return ( dotProduct > 0.9 ); // reviver is facing within a ~52-degree cone of the player
}

// self = reviver
revive_do_revive( playerBeingRevived, reviverGun )
{
	assert( self is_reviving( playerBeingRevived ) );
	// reviveTime used to be set from a Dvar, but this can no longer be tunable:
	// it has to match the length of the third-person revive animations for
	// co-op gameplay to run smoothly.
	reviveTime = 3;

	if ( self HasPerk( "specialty_quickrevive" ) )
	{
		reviveTime = reviveTime / 2;
	}

	timer = 0;
	revived = false;
	
	//CODER_MOD: TOMMYK 07/13/2008
	if(!IsDefined(playerBeingRevived.isteddy))
	{
	playerBeingRevived.revivetrigger.beingRevived = 1;
	playerBeingRevived.revive_hud setText( &"GAME_PLAYER_IS_REVIVING_YOU", self );
	playerBeingRevived revive_hud_show_n_fade( 3.0 );
	
	playerBeingRevived.revivetrigger setHintString( "" );
	
	playerBeingRevived startrevive( self );
}
else
{
players = get_players();
for ( i = 0; i < players.size; i++ )
{
if(players[i] player_is_in_laststand())
{
players[i].revivetrigger.beingRevived = 1;
	players[i].revive_hud setText( &"GAME_PLAYER_IS_REVIVING_YOU", self );
	players[i] revive_hud_show_n_fade( 3.0 );
	
	players[i].revivetrigger setHintString( "" );
	
	players[i] startrevive( self );
	}
}
}
	if( !isdefined(self.reviveProgressBar) )
		self.reviveProgressBar = self createPrimaryProgressBar();

	if( !isdefined(self.reviveTextHud) )
		self.reviveTextHud = newclientHudElem( self );	
	
	self thread laststand_clean_up_on_disconnect( playerBeingRevived, reviverGun );
	
	self.reviveProgressBar updateBar( 0.01, 1 / reviveTime );

	self.reviveTextHud.alignX = "center";
	self.reviveTextHud.alignY = "middle";
	self.reviveTextHud.horzAlign = "center";
	self.reviveTextHud.vertAlign = "bottom";
	self.reviveTextHud.y = -148;
	if ( IsSplitScreen() )
		self.reviveTextHud.y = -107;
	self.reviveTextHud.foreground = true;
	self.reviveTextHud.font = "default";
	self.reviveTextHud.fontScale = 1.8;
	self.reviveTextHud.alpha = 1;
	self.reviveTextHud.color = ( 1.0, 1.0, 1.0 );
	self.reviveTextHud setText( &"GAME_REVIVING" );
	
	//chrisp - zombiemode addition for reviving vo
	// cut , but leave the script just in case 
	//self thread say_reviving_vo();
	if(!IsDefined(playerBeingRevived.isteddy))
	{
	while( self is_reviving( playerBeingRevived ) )
	{
		wait( 0.05 );					
		timer += 0.05;			

		if ( self player_is_in_laststand() )
			break;

		if( timer >= reviveTime)
		{
			revived = true;	
			break;
		}
	}
	}
	else
	{
	while(1==1)
	{
	wait( 0.05 );					
		timer += 0.05;			

		if ( self player_is_in_laststand() )
			break;

		if( timer >= reviveTime)
		{
			revived = true;	
			break;
		}
	}
	}
	if( isdefined( self.reviveProgressBar ) )
	{
		self.reviveProgressBar destroyElem();
	}
	
	if( isdefined( self.reviveTextHud ) )
	{
		self.reviveTextHud destroy();
	}		
	if(!IsDefined(playerBeingRevived.isteddy))
	{
	if ( !revived )
	{
		playerBeingRevived stoprevive( self );
	}

	//CODER_MOD: TOMMYK 07/13/2008
	playerBeingRevived.revivetrigger setHintString( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
	playerBeingRevived.revivetrigger.beingRevived = 0;
	}
	else
	{	
	players = get_players();
for ( i = 0; i < players.size; i++ )
{
if(players[i] player_is_in_laststand())
{
	if ( !revived )
	{
		players[i] stoprevive( self );
	}

	//CODER_MOD: TOMMYK 07/13/2008
	players[i].revivetrigger setHintString( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
	players[i].revivetrigger.beingRevived = 0;
	}
	}
	}
	return revived;
}


say_reviving_vo()
{
	if( GetDvar( "zombiemode" ) == "1" || IsSubStr( level.script, "nazi_zombie_" ) ) // CODER_MOD (Austin 5/4/08): zombiemode loadout setup
	{	
	
		players = get_players();
		for(i=0; i<players.size; i++)
		{
			if (players[i] == self)
			{
				self playsound("plr_" + i + "_vox_reviving" + "_" + randomintrange(0, 2));

			}												
		}
	}
}

say_revived_vo()
{
	if( GetDvar( "zombiemode" ) == "1" || IsSubStr( level.script, "nazi_zombie_" ) ) // CODER_MOD (Austin 5/4/08): zombiemode loadout setup
	{	
		players = get_players();
		for(i=0; i<players.size; i++)
		{
			if (players[i] == self)
			{
				self playsound("plr_" + i + "_vox_revived" + "_" + randomintrange(0, 2));
			}		
		}	
	}
}


revive_success( reviver )
{
	self notify ( "player_revived", reviver );	
	self reviveplayer();
	if(self hasperk("specialty_armorvest"))
		{
			self.maxhealth = level.zombie_vars["zombie_perk_juggernaut_health"];
			self.health = level.zombie_vars["zombie_perk_juggernaut_health"];
			}
	//CODER_MOD: TOMMYK 06/26/2008 - For coop scoreboards
	reviver.revives++;
	//stat tracking
	reviver.stats["revives"] = reviver.revives;
	
	// CODER MOD: TOMMY K - 07/30/08
	reviver thread maps\_arcademode::arcadeMode_player_revive();
					
	//CODER_MOD: Jay (6/17/2008): callback to revive challenge
	if( isdefined( level.missionCallbacks ) )
	{
		maps\_challenges_coop::doMissionCallback( "playerRevived", reviver ); 
	}	
	
	setClientSysState("lsm", "0", self);	// Notify client last stand ended.
	
	self.revivetrigger delete();
	self.revivetrigger = undefined;

	self laststand_giveback_player_weapons();
	
	self.ignoreme = false;
	
	self thread say_revived_vo();
	
}


revive_force_revive( reviver )
{
	assert( IsDefined( self ) );
	assert( IsPlayer( self ) );
	assert( self player_is_in_laststand() );

	self thread revive_success( reviver );
}

// the text that tells players that others are in need of a revive
revive_hud_create()
{	
	self.revive_hud = newclientHudElem( self );
	self.revive_hud.alignX = "center";
	self.revive_hud.alignY = "middle";
	self.revive_hud.horzAlign = "center";
	self.revive_hud.vertAlign = "bottom";
	self.revive_hud.y = -50;
	self.revive_hud.foreground = true;
	self.revive_hud.font = "default";
	self.revive_hud.fontScale = 1.5;
	self.revive_hud.alpha = 0;
	self.revive_hud.color = ( 1.0, 1.0, 1.0 );
	self.revive_hud setText( "" );

	if( GetDvar( "zombiemode" ) == "1" )
	{
		self.revive_hud.y = -80;
	}
}

//CODER_MOD: TOMMYK 07/13/2008
revive_hud_think()
{
	self endon ( "disconnect" );
	
	while ( 1 )
	{
		wait( 0.1 );

		if ( !player_any_player_in_laststand() )
		{
			continue;
		}
		
		players = get_players();
		playerToRevive = undefined;
			
		for( i = 0; i < players.size; i++ )
		{
			if( !players[i] player_is_in_laststand() || !isDefined( players[i].revivetrigger.createtime ) )
				continue;
			
			if( !isDefined(playerToRevive) || playerToRevive.revivetrigger.createtime > players[i].revivetrigger.createtime )
			{
				playerToRevive = players[i];
			}
		}
			
		if( isDefined( playerToRevive ) )
		{
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] player_is_in_laststand() )
					continue;
							
				players[i] thread fadeReviveMessageOver( playerToRevive, 3.0 );
			}
			
			playerToRevive.revivetrigger.createtime = undefined;
			wait( 3.5 );
		}		
	}
}

//CODER_MOD: TOMMYK 07/13/2008
fadeReviveMessageOver( playerToRevive, time )
{
	revive_hud_show();
	self.revive_hud setText( &"GAME_PLAYER_NEEDS_TO_BE_REVIVED", playerToRevive );
	self.revive_hud fadeOverTime( time );
	self.revive_hud.alpha = 0;
}

revive_hud_hide()
{
	assert( IsDefined( self ) );
	assert( IsDefined( self.revive_hud ) );

	self.revive_hud.alpha = 0;
}

revive_hud_show()
{
	assert( IsDefined( self ) );
	assert( IsDefined( self.revive_hud ) );

	self.revive_hud.alpha = 1;
}

//CODER_MOD: TOMMYK 07/13/2008
revive_hud_show_n_fade(time)
{
	revive_hud_show();

	self.revive_hud fadeOverTime( time );
	self.revive_hud.alpha = 0;
}

drawcylinder(pos, rad, height)
{
	currad = rad;
	curheight = height;

	for (r = 0; r < 20; r++)
	{
		theta = r / 20 * 360;
		theta2 = (r + 1) / 20 * 360;

		line(pos + (cos(theta) * currad, sin(theta) * currad, 0), pos + (cos(theta2) * currad, sin(theta2) * currad, 0));
		line(pos + (cos(theta) * currad, sin(theta) * currad, curheight), pos + (cos(theta2) * currad, sin(theta2) * currad, curheight));
		line(pos + (cos(theta) * currad, sin(theta) * currad, 0), pos + (cos(theta) * currad, sin(theta) * currad, curheight));
	}
}

mission_failed_during_laststand( dead_player )
{
	if( IsDefined( level.no_laststandmissionfail ) && level.no_laststandmissionfail ) 
	{
		return;
	}

	players = get_players(); 
	for( i = 0; i < players.size; i++ )
	{
		if( isDefined( players[i] ) )
		{
			players[i] thread maps\_quotes::displayMissionFailed(); 
			if( players[i] == self )
			{
				players[i] thread maps\_quotes::displayPlayerDead(); 
				println( "Player #"+i+" is dead" ); 
			}
			else
			{
				players[i] thread maps\_quotes::displayTeammateDead( dead_player ); 
				println( "Player #"+i+" is alive" ); 
			}
		}
	}
	missionfailed();
}

//NEW TEDDY STUFF
revive_all_players(reviver,teddy)
{
/*
teddy.isteddy = true;
if(!reviver is_facing( teddy ) )
{
return;
}
gun = reviver GetCurrentWeapon();
			assert( IsDefined( gun ) );
			//assert( gun != "none" );
			if ( gun == "syrette" )
				return;

			reviver GiveWeapon( "syrette" );
			reviver SwitchToWeapon( "syrette" );
			reviver SetWeaponAmmoStock( "syrette", 1 );
players = get_players();
			//CODER_MOD: TOMMY K
			revive_success = reviver revive_do_revive( teddy, gun );
			reviver revive_give_back_weapons( gun );
		for ( i = 0; i < players.size; i++ )
		{
			if(players[i] player_is_in_laststand())
			{
			players[i].revivetrigger setHintString( "" );
			//PI CHANGE: player couldn't jump - allow this again now that they are revived
			if (IsDefined(level.script) && level.script == "nazi_zombie_sumpf")
				players[i] AllowJump(true);
			//END PI CHANGE

			if ( revive_success )
			{
				players[i] thread revive_success( reviver );
				return;
			}
			}
		}
		*/
		players = get_players();
		for ( i = 0; i < players.size; i++ )
		{
			if(players[i] player_is_in_laststand())
			{
			players[i].revivetrigger setHintString( "" );
			players[i] revive_force_revive( reviver );
			}
			
		}
}