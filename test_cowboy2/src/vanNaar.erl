%%%-------------------------------------------------------------------
%%% @author laure
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. dec 2017 15:43
%%%-------------------------------------------------------------------
-module(vanNaar).
-author("laure").

%% API

-export([start/0,init/0,loop/7]).

start()->
  Pid = spawn(?MODULE, init , []),
  Pid.


%% send after wel doen , maar kijken met een if'ke in de receive van de bestemmeling kijken of dit nog in de agenda staat
%%zoniet dan wordt dit agendapunt verworpen!
init()->
  loop(0,0,0,0,0,false,0).
  
loop(Bestuurder , Vervoer , Duur, Locatie,Toplevel,Ongeluk ,NieuweDuurdoorOngeluk) ->
  receive
    {gaNaarErgens} -> 
    	Bestuurder!{sms},
      	erlang:send_after(Duur , self(), {gearriveerd}),
      	Vervoer!{setRijd, true,Toplevel},
      	Vervoer!{setBestuurder,Bestuurder,Toplevel}, 
      	loop(Bestuurder, Vervoer, Duur, Locatie, Toplevel, Ongeluk, NieuweDuurdoorOngeluk);

    {gearriveerd} -> 
    	if(Ongeluk == false) -> 
    		io:format("gearriveerd met : ~p op ~p \n",[Bestuurder,Locatie]), 
    		Toplevel!{log,"gearriveerd", [Bestuurder,Vervoer]},
      		Bestuurder!{verplaats, Vervoer, Locatie, Toplevel},
      		Vervoer!{setRijd , false,Toplevel},
      		loop(Bestuurder,Vervoer,Duur,Locatie,Toplevel,Ongeluk,NieuweDuurdoorOngeluk);
     	true -> 
     		erlang:display("ongeluk"),
     		erlang:send_after(NieuweDuurdoorOngeluk,self(),{setOngeluk , false}), 
     		erlang:send_after(NieuweDuurdoorOngeluk,self(),{gearriveerd}),
                loop(Bestuurder,Vervoer,Duur,Locatie,Toplevel,Ongeluk,NieuweDuurdoorOngeluk)
      	end;
    {setBestuurder, PIDBestuurder} -> 
    	loop(PIDBestuurder, Vervoer, Duur, Locatie, Toplevel, Ongeluk, NieuweDuurdoorOngeluk);
    {setVervoer, PIDVervoer} ->  
    	loop(Bestuurder,PIDVervoer,Duur,Locatie,Toplevel,Ongeluk,NieuweDuurdoorOngeluk);
    {setDuur, DuurNieuw} -> 
    	 SetV = if(DuurNieuw==[]) -> 0; 
    	 	true -> DuurNieuw
    		end,
    	 loop(Bestuurder,Vervoer,SetV,Locatie,Toplevel,Ongeluk,NieuweDuurdoorOngeluk);
    {setLocatie, LocatieNieuw} -> 
    	loop(Bestuurder,Vervoer,Duur,LocatieNieuw,Toplevel,Ongeluk,NieuweDuurdoorOngeluk);
    {setToplevel, PIDTl} -> 
    	loop(Bestuurder,Vervoer,Duur,Locatie,PIDTl,Ongeluk,NieuweDuurdoorOngeluk);
    {setOngeluk , NieuwOng} ->
    	Toplevel!{log,"setOngeluk",[Ongeluk,NieuweDuurdoorOngeluk,Vervoer]}, 
    	loop(Bestuurder,Vervoer,Duur,Locatie,Toplevel,NieuwOng,NieuweDuurdoorOngeluk);
    {setNieuweDuurOng,DuurOng} -> 
    	SetV = if(DuurOng==[]) -> 0; 
    		true -> DuurOng
    		end,
    	loop(Bestuurder,Vervoer,Duur,Locatie,Toplevel,Ongeluk,SetV);
    {gearriveerdPass} ->
    	io:format("gearriveerd met ~p met vervoer : ~p op ~p \n",[Bestuurder,Vervoer,Locatie]),
    	Toplevel!{log,"gearriveerdPassagier",[Vervoer,Bestuurder]},
    	loop(Bestuurder , Vervoer, Duur,Locatie,Toplevel,Ongeluk,NieuweDuurdoorOngeluk)
  end.

