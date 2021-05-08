#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;


/*------------------------------------
BOUNCING BETTY STUFFS - 
a rough prototype for now, needs a bit more polish

and Hacking Kit
------------------------------------*/
init()
{
	trigs = getentarray("betty_purchase","targetname");
	for(i=0; i<trigs.size; i++)
	{
		model = getent( trigs[i].target, "targetname" ); 
		model hide(); 
	}
	level.hackerinuse=false;
	array_thread(trigs,::buy_bouncing_betties);
	level thread give_betties_after_rounds();
	level.hacker="zombie_m1carbine";
}

buy_bouncing_betties()
{
	//self sethintstring( &"ZOMBIE_BETTY_PURCHASE" );	
	self setCursorHint( "HINT_NOICON" );
	self.zombie_cost = 2000;
	self sethintstring( "Press F to buy Hacking Kit [Cost: 2000]" );	
	level thread set_betty_visible();
	self.betties_triggered = false;

	while(1)
	{
		self waittill("trigger",who);
		if( who in_revive_trigger() )
		{
			continue;
		}

		if( is_player_valid( who ) )
		{

			if( who.score >= self.zombie_cost )
			{				
				if((!isDefined(who.has_betties))||who.has_betties==0||level.hackerinuse==false)
				{
					play_sound_at_pos( "purchase", self.origin );

					//set the score
					who maps\_zombiemode_score::minus_to_player_score( self.zombie_cost ); 
					who thread show_betty_hint("betty_purchased");
					if(level.hackerinuse==true)
					{
						who thread bouncing_betty_setup(self);
						who.has_betties = 1;
					}
					else
					{
						who thread hacker_kit_setup(self);
						who.has_hacker = 1;
					}
					// JMA - display the bouncing betties
					if( self.betties_triggered == false )
					{						
						model = getent( self.target, "targetname" ); 					
						model thread maps\_zombiemode_weapons::weapon_show( who ); 
						self.betties_triggered = true;
					}
					
					/*trigs = getentarray("betty_purchase","targetname");
					for(i = 0; i < trigs.size; i++)
					{
						trigs[i] SetInvisibleToPlayer(who);
					}*/
				}
				else
				{
					//who thread show_betty_hint("already_purchased");

				}
			}
		}
	}
}

set_betty_visible()
{
	players = getplayers();	
	trigs = getentarray("betty_purchase","targetname");

	while(1)
	{
		for(j = 0; j < players.size; j++)
		{
			if( !isdefined(players[j].has_betties))
			{						
				for(i = 0; i < trigs.size; i++)
				{
					trigs[i] SetInvisibleToPlayer(players[j], false);
				}
			}
		}

		wait(1);
		players = getplayers();	
	}
}

bouncing_betty_watch()
{
	self endon("death");
	self endon("bettys_removed");
	while(1)
	{
		self waittill("grenade_fire",betty,weapname);
		if(weapname == "mine_bouncing_betty")
		{
			betty.owner = self;
			betty thread betty_think();
			self thread betty_death_think();
		}
	}
}

betty_death_think()
{
	self waittill("death");

	if(isDefined(self.trigger))
	{
		self.trigger delete();
	}

	self delete();

}

bouncing_betty_setup(salespot)
{	
	if(IsDefined(self.has_hacker)&&self.has_hacker==1)
	{
		self hacker_kit_remove(salespot);
	}
	self thread bouncing_betty_watch();

	self giveweapon("mine_bouncing_betty");
	self setactionslot(4,"weapon","mine_bouncing_betty");
	self setweaponammostock("mine_bouncing_betty",5);
}

bouncing_betty_remove()
{	
	self notify("bettys_removed");
	self.has_betties = undefined;
	self TakeWeapon("mine_bouncing_betty");
}

hacker_kit_setup(salespot)
{	
	if(IsDefined(self.has_betties)&&self.has_betties==1)
	{
		self bouncing_betty_remove();
	}
	self thread hacker_watch(salespot);
	self giveweapon(level.hacker);
	self setactionslot(4,"weapon",level.hacker);
	self setweaponammostock(level.hacker,10);
	self GiveMaxAmmo(level.hacker);
	level.hackerinuse=true;
	salespot.zombie_cost = 1000;
	salespot sethintstring( &"ZOMBIE_BETTY_PURCHASE" );
}
hacker_watch(salespot)
{
	self endon("disconnect");
	self endon("hacker_removed");
	self waittill("death");
	self thread hacker_kit_remove(salespot);
}
hacker_kit_remove(salespot)
{	
	self notify("hacker_removed");
	level.hackerinuse=false;
	self TakeWeapon(level.hacker);
	salespot.zombie_cost = 2000;
	self.has_hacker = undefined;
	salespot sethintstring( "Press F to buy Hacking Kit [Cost: 2000]" );
}

betty_think()
{
	wait(2);
	trigger = spawn("trigger_radius",self.origin,9,80,64);
	for(;;)
	{
	trigger waittill( "trigger" );
	trigger = trigger;
	self playsound("betty_activated");
	wait(.1);	
	fake_model = spawn("script_model",self.origin);
	fake_model setmodel(self.model);
	if((!IsDefined(level.superbetties))&&(!level.superbetties==true))
	{
	self hide();
	}
	tag_origin = spawn("script_model",self.origin);
	tag_origin setmodel("tag_origin");
	tag_origin linkto(fake_model);
	playfxontag(level._effect["betty_trail"], tag_origin,"tag_origin");
	fake_model moveto (fake_model.origin + (0,0,32),.2);
	fake_model waittill("movedone");
	playfx(level._effect["betty_explode"], fake_model.origin);
	earthquake(1, .4, fake_model.origin, 512);

	//CHris_P - betties do no damage to the players
	zombs = getaispeciesarray("axis");
	for(i=0;i<zombs.size;i++)
	{
		//PI ESM: added a z check so that it doesn't kill zombies up or down one floor
		if(zombs[i].origin[2] < fake_model.origin[2] + 80 && zombs[i].origin[2] > fake_model.origin[2] - 80 && DistanceSquared(zombs[i].origin, fake_model.origin) < 200 * 200)
		{
			if(IsDefined(zombs[i].isboss)&&zombs[i].isboss==true)
			{
				zombs[i] DoDamage(5000 +self.health/5, zombs[i].origin, self.owner );
			}
			else
			{
				zombs[i] thread maps\_zombiemode_spawner::zombie_damage( "MOD_ZOMBIE_BETTY", "none", zombs[i].origin, self.owner );
			}
		}
	}
	
	//radiusdamage(self.origin,128,1000,75,self.owner);
if((!IsDefined(level.superbetties))||(!level.superbetties==true))
{
	trigger delete();
	fake_model delete();
	tag_origin delete();
	if( isdefined( self ) )
	{
		self delete();
	}
	return;
	}
	else
	{
	fake_model delete();
	tag_origin delete();
	wait(0.1);
	}
	}
}

betty_smoke_trail()
{
	self.tag_origin = spawn("script_model",self.origin);
	self.tag_origin setmodel("tag_origin");
	playfxontag(level._effect["betty_trail"],self.tag_origin,"tag_origin");
	self.tag_origin moveto(self.tag_origin.origin + (0,0,100),.15);
}

give_betties_after_rounds()
{
	while(1)
	{
		level waittill( "between_round_over" );
		{
			players = get_players();
			for(i=0;i<players.size;i++)
			{
				if(isDefined(players[i].has_betties))
				{
					players[i]  giveweapon("mine_bouncing_betty");
					players[i]  setactionslot(4,"weapon","mine_bouncing_betty");
					players[i]  setweaponammoclip("mine_bouncing_betty",2);
				}
			}
		}
	}
}

//betty hint stuff
init_hint_hudelem(x, y, alignX, alignY, fontscale, alpha)
{
	self.x = x;
	self.y = y;
	self.alignX = alignX;
	self.alignY = alignY;
	self.fontScale = fontScale;
	self.alpha = alpha;
	self.sort = 20;
	//self.font = "objective";
}

setup_client_hintelem()
{
	self endon("death");
	self endon("disconnect");

	if(!isDefined(self.hintelem))
	{
		self.hintelem = newclienthudelem(self);
	}
	self.hintelem init_hint_hudelem(320, 220, "center", "bottom", 1.6, 1.0);
}


show_betty_hint(string)
{
	self endon("death");
	self endon("disconnect");

	if(string == "betty_purchased")
		text = &"ZOMBIE_BETTY_HOWTO";
	else
		text = &"ZOMBIE_BETTY_ALREADY_PURCHASED";

	self setup_client_hintelem();
	self.hintelem setText(text);
	wait(3.5);
	self.hintelem settext("");
}
