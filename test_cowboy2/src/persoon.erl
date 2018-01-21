%%%-------------------------------------------------------------------
%%% @author Simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. nov 2017 11:35
%%%-------------------------------------------------------------------
-module(persoon).
-author("Simon").


%% API
-include("records.hrl").
-export([start/0, init/0,loop/4]).

start()->
  PID = spawn(?MODULE, init, []),
  PID.


init()->
  Agenda = ets:new(agenda,[ordered_set]),
  loop("thuis", false,"unbound",Agenda).
  
loop(Locatie, Rijbewijs, Naam,Agenda) ->
  receive
    {updateData, PID} ->
      PIDP = self(),
      PID!{updateDataP, Naam, PIDP, Locatie, Rijbewijs},
      loop(Locatie, Rijbewijs,  Naam,Agenda);
    {clearAgenda, PID}-> 
    	PID!{log, "Clear agenda", Naam}, 
    	ets:delete_all_objects(Agenda), 
    	loop(Locatie, Rijbewijs, Naam,Agenda);
    {getLocatie} -> 
    	erlang:display(Locatie),  
    	loop(Locatie, Rijbewijs,Naam,Agenda);
    {getRijbewijs} ->
    	erlang:display(Rijbewijs), 
    	loop(Locatie, Rijbewijs, Naam,Agenda);
    {verplaats, PIDVervoer, NieuweLocatie, PID} ->
    	PIDVervoer!{setLocatie, NieuweLocatie, PID}, 
    	self()!{setLocatie, NieuweLocatie, PID}, 
    	loop(Locatie, Rijbewijs, Naam,Agenda);
    {sms} -> 
    	io:format("vertrek nu! ~p \n",[self()]),
    	loop(Locatie,Rijbewijs , Naam,Agenda);
    {sms,Message} -> 
    	erlang:display(Message),
    	loop(Locatie,Rijbewijs,Naam,Agenda);
    {getNaam} -> 
    	io:format("naam is ~p", Naam),
    	loop(Locatie, Rijbewijs,Naam,Agenda);
    {setNaam,NieuweNaam, PID} -> 
    	self()!{updateData, PID}, 
    	PID!{log,"setNaam",NieuweNaam}, 
    	loop(Locatie, Rijbewijs, NieuweNaam, Agenda);

    {maakafspraak,NieuweLocatie,Van ,Vervoer,PassAuto, PID} ->
    	PID!{log, "maak afspraak", {NieuweLocatie,Van ,Vervoer,PassAuto}}, 
    	ets:insert(Agenda,{Van,NieuweLocatie,Vervoer,PassAuto}),
    	loop(Locatie , Rijbewijs, Naam,Agenda);

    {maakafspraak,NieuweLocatie,EindLocatie,Van,Tot,Vervoer,Passagier,Bestuurder, PID} ->
      	ReisDuur = (getDuur(NieuweLocatie,ets:lookup(locaties,EindLocatie))/1000),
      	Bestuurder!{maakafspraak,NieuweLocatie,Van-ReisDuur,Vervoer,"", PID},
      	Passagier!{maakafspraak,NieuweLocatie,Van-ReisDuur,"passagier",Vervoer,PID},
      	if((2*ReisDuur)>= Tot-Van) ->
      		io:format("op ~p blijven want terugrit is langer \n",[NieuweLocatie]),
      		Bestuurder!{maakafspraak,EindLocatie,Tot+0.1,Vervoer,"", PID},
        	Passagier!{maakafspraak,EindLocatie,Tot+0.1,"passagier",Vervoer, PID},loop(Locatie , Rijbewijs,Naam,Agenda);
        true ->
          	Bestuurder!{maakafspraak,EindLocatie,(Van+0.1),Vervoer,"", PID},
          	Bestuurder!{maakafspraak,NieuweLocatie,Tot-ReisDuur,Vervoer,"", PID},
          %%nog werken met 6 min (=+0.1) hier om de op te lossen dat de locatie van de persoon nog niet gewijzigd is door de ReisTijd van de send_afters
		  Bestuurder!{maakafspraak,EindLocatie,Tot+0.1,Vervoer,"", PID},
		  Passagier!{maakafspraak,EindLocatie,Tot+0.1,"passagier",Vervoer, PID},
		  loop(Locatie , Rijbewijs,Naam,Agenda)
      	end;
    {setLocatie, NieuweLocatie, PID} ->
    	PIDP = self(),
    	self()!{updateData, PID}, 
    	PID!{log,"setLocatie",[NieuweLocatie,PIDP]}, 
    	loop(NieuweLocatie, Rijbewijs,  Naam,Agenda);
    {setRijbewijs, NieuwRijbewijs, PID} ->
    	self()!{updateData, PID},
    	PID!{log,"setRijbewijs",NieuwRijbewijs}, 
    	loop(Locatie, NieuwRijbewijs,  Naam,Agenda);
    {getInfo, PID} -> 
    	PID!Naam, 
    	loop(Locatie, Rijbewijs,  Naam,Agenda);
    {getAfspraak,Tijd,PID} ->
    	Lijst = ets:lookup(Agenda,(Tijd)),
      	if(Lijst == []) -> 
      		loop(Locatie,Rijbewijs,Naam,Agenda);
        true -> 
        	Type = getTypeVervoer(ets:lookup(objecten,getVervoer(Lijst))),
          	case Type of
            		fiets ->
            			PIDPers=self(),
            			Vervoer = getVervoer(Lijst),
            			PID!{log,"getAfspraak met Fiets",[Vervoer, Naam]},
            			Vervoer!{getVN,Tijd,PID,PIDPers},
            			loop(Locatie,Rijbewijs,Naam,Agenda);
            		passagier ->
            			PIDPers=self(),
            			Loc2 =getLocatie(Lijst),
              			if(Loc2 == Locatie) ->
              				PID!{log,"AlOpBestemming",[Loc2, self()]},
                			loop(Locatie,Rijbewijs,Naam,Agenda);
				true ->
					ReisDuur = getDuur(Loc2,ets:lookup(locaties,Locatie)),
					Verv = getVervoerPass(Lijst), 
					Verv!{addPassagier,PIDPers,PID},
                  			PID!{log,"getAfspraak passagier",[self(),Verv]},
                  			erlang:send_after(ReisDuur,Verv,{verwijderPassagier,PIDPers,PID}),
                  			erlang:send_after(ReisDuur,self(),{setLocatie,Loc2,PID}),
                  			loop(Locatie,Rijbewijs,Naam,Agenda)
              			end;
            		auto -> 
            			if(Rijbewijs == false) ->
            				erlang:display("geen rijbewijs kan niet met de auto vertrekken!"),
            				PID!{log,"geen Rijbewijs",[self(),Type]}, 
            				loop(Locatie,Rijbewijs,Naam,Agenda);
                    		true ->
                    			PIDPers=self(),
                    			Vervoer=getVervoer(Lijst),
                    			PID!{log,"getAfspraak met Auto",[Vervoer,self()]},PIDPers=self(),Vervoer!{getVN,Tijd,PID,PIDPers},
                      			loop(Locatie,Rijbewijs,Naam,Agenda)
                  	end
          	end
      	end;

    {getAfspraak,Tijd,PID,VN} -> 
    	Lijst = ets:lookup(Agenda,(Tijd)),
      	if(Lijst == []) -> 
      		loop(Locatie,Rijbewijs,Naam,Agenda);
        true ->  
        	PIDP = self(),
        	PID!{getReisDuur,getTijdVan(Lijst),getLocatie(Lijst),Locatie,VN,getVervoer(Lijst),PIDP},
        	loop(Locatie,Rijbewijs,Naam,Agenda)
      	end;
  	%{delete,Tijd}->ets:delete(Agenda,Tijd),loop(Locatie,Rijbewijs,Naam,Agenda);
    {getLoc,LocatieTest,Loc2} ->
    	erlang:display(getDuur(Loc2,ets:lookup(locaties,LocatieTest)));
    {getVervoer,Tijd} ->
    	Lijst = ets:lookup(Agenda,(Tijd)),
    	erlang:display(getTypeVervoer(ets:lookup(objecten,getVervoer(Lijst)))),
    	loop(Locatie,Rijbewijs,Naam,Agenda)
  end.


getTijdVan([{Van , _ , _,_}]) ->
	Van.
getLocatie([{_,Locatie,_,_}]) -> 
	Locatie.
getVervoer([{_,_,Vervoer,_}]) -> 
	Vervoer.
getVervoerPass([{_,_,_,Pass}]) ->
	Pass.
getTypeVervoer([{_,Type,_,_,_}]) ->
	Type.


%Mag geen lege haken returnen!!
getDuur(_,[]) -> 
	0;
getDuur(Loc2,[{_,Locatie2,Duur}]) -> 
	if(Locatie2 == Loc2) -> Duur;
	true -> 
        	io:format("persoon (103): Duur niet gevonden!~n",[]),
		0
	end;
getDuur(Loc2 , [{_,Locatie2 , Duur}|XS]) -> 
	if(Locatie2 == Loc2) -> Duur;
		true -> getDuur(Loc2,XS)
	end.

%%os:timestamp() voor tijd te krijgen
%%time.now-diff(t1,t2);

%{getLocatie , Auto , ReisLocatie , PIDVN ,PID} -> ets:insert(log,{"getLocatie voor ga naar" , self() , Auto , ReisLocatie , PIDVN})
%, PID!{gaNaar3 , self() , ReisLocatie,PIDVN , Auto,Locatie} , loop(Locatie,Rijbewijs,Naam,Agenda)
%{getAfspraak , Tijd,PID}->Lijst = ets:lookup(Agenda,(Tijd)),
%if(Lijst == []) -> loop(Locatie,Rijbewijs,Naam,Agenda);
%true -> Type = getTypeVervoer(ets:lookup(objecten,getVervoer(Lijst))), if(Type == fiets)->PIDPers=self(), Vervoer = getVervoer(Lijst),PID!{log,"getAfspraak met Fiets",[Vervoer, Naam]},Vervoer!{getVN,Tijd,PID,PIDPers},loop(Locatie,Rijbewijs,Naam,Agenda);
%true-> if(Rijbewijs == false)->erlang:display("geen rijbewijs kan niet met de auto vertrekken!"),PID!{log,"geen Rijbewijs",[self(),Type]}, loop(Locatie,Rijbewijs,Naam,Agenda);
%true ->PIDPers=self(),Vervoer = getVervoer(Lijst),PID!{log,"getAfspraak met Auto",[Vervoer,self()]},PIDPers=self(),Vervoer!{getVN,Tijd,PID,PIDPers},loop(Locatie,Rijbewijs,Naam,Agenda)
%end                                                                             end
%end;
