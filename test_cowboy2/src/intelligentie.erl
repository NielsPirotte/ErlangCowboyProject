%%%-------------------------------------------------------------------
%%% @author Simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. dec 2017 10:45
%%%-------------------------------------------------------------------
-module(intelligentie).
-author("Simon").


%% API
-export([start/0, loop/6, init/0, zonder/2]).
-include("records.hrl").



start()->
  Pid= spawn(?MODULE, init , []),
  Pid.


init()->
  AfsprakenTabel = ets:new(afspraken, [duplicate_bag]),
  Matches =ets:new(matches, [duplicate_bag]),
  Matches2 = ets:new(matches2, [duplicate_bag]),
  loop([], [], [], AfsprakenTabel,Matches, Matches2).

loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2)->
  receive
    {addAuto, PID} -> 
    	loop([PID|Autos], Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {addFiets, PID} ->
    	loop(Autos, [PID|Fietsen], Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {addChauffeur, PID}->
    	loop(Autos, Fietsen, [PID|Chauffeurs], AfsprakenTabel, Matches, Matches2);
    {setAutos, Wagens} ->
    	loop(Wagens, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {setFietsen, Velos} ->
    	loop(Autos, Velos, Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {setChauffeurs, Bestuurders}->
    	loop(Autos, Fietsen, Bestuurders, AfsprakenTabel, Matches, Matches2);
    {maakAfspraak, Van, Tot, Locatie1,Locatie2,Passagiers, Persoon, PID} ->
    	PID!{log, "add afspraak", {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}},
    	ets:insert(AfsprakenTabel, {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}), 
    	loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {setResources, PID} -> 
    	PID!{sendResources,self()}, loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {setResources, Wagens, Velos, Chauffeurs} -> 
    	loop(Wagens, Velos, Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {clearMatches} ->
    	ets:delete_all_objects(Matches),
    	ets:delete_all_objects(Matches2),
    	loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {nieuweAfspraak, Van, Tot, Locatie1, Locatie2, Passagiers, Persoon, PID } ->
      ReisDuur = getDuur(Locatie2,ets:lookup(locaties,Locatie1))/1000,
      if(Passagiers == false) -> 
      	[{_,_,_,_,Rijbewijs}] = ets:lookup(objecten, Persoon),
        if(Rijbewijs == true) ->
          Voertuig = checkResources(Autos, Fietsen, Matches, Van-ReisDuur, Tot+ReisDuur, Persoon ),
          if(Voertuig == "Geen voertuigen vrij") -> 
          	io:format("afspraak kan niet worden gemaakt voor : ~p want er zijn geen voertuigen vrij \n",[Persoon]),  
          	loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
          true -> 
          	Persoon!{maakafspraak, Locatie1, Van-ReisDuur, Voertuig, Persoon, PID }, 
          	Persoon!{maakafspraak, Locatie2, Tot, Voertuig, Persoon, PID},
          	ets:insert(Matches, {Voertuig, Van-ReisDuur, Tot+ReisDuur, Persoon}),
          	ets:insert(Matches2, {Persoon, Van-ReisDuur, Tot+ReisDuur, Voertuig}),
              	loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2)
          end;
        true-> 
        	Voertuig = checkResources([], Fietsen, Matches, Van-ReisDuur, Tot+ReisDuur, Persoon ),
            	if(Voertuig == "Geen voertuigen vrij") -> 
            		io:format("afspraak kan niet worden gemaakt voor : ~p want er zijn geen voertuigen vrij \n",[Persoon]), 
            		loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
              	true -> 
              		Persoon!{maakafspraak, Locatie1, Van-ReisDuur, Voertuig, Persoon, PID  }, 
              		Persoon!{maakafspraak, Locatie2, Tot, Voertuig, Persoon, PID },
              		ets:insert(Matches, {Voertuig, Van-ReisDuur, Tot+ReisDuur, Persoon}),
              		ets:insert(Matches2, {Persoon, Van-ReisDuur, Tot+ReisDuur, Voertuig}),
                	loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2)
            	end
        end;
        true->   
        	ets:delete_object(AfsprakenTabel,{Van, Tot, Locatie1, Locatie2, Passagiers, Persoon} ), 
        	Voertuig = checkResources(Autos, Fietsen, Matches, Van-ReisDuur, Tot+ReisDuur, Persoon ),
          	Chauffeur = checkChauffeurs(Chauffeurs, Matches2, Van-ReisDuur, Tot+ReisDuur, Persoon),
          	if(Voertuig == "Geen voertuigen vrij") -> 
          		io:format("afspraak kan niet worden gemaakt voor : ~p want er zijn geen voertuigen vrij \n",[Persoon]),  
          		loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
            	true ->
            		if(Chauffeur == "Geen chauffeurs vrij") -> 
            			io:format("afspraak kan niet worden gemaakt voor : ~p want er zijn geen chauffeurs vrij \n",[Persoon]),  
            			loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
                     	true ->
                       		ets:insert(Matches, {Voertuig, Van-ReisDuur, Tot+ReisDuur, Chauffeur}), 
                       		ets:insert(Matches2, {Chauffeur, Van-ReisDuur, Tot+ReisDuur, Voertuig}),
                       		Persoon!{maakafspraak, Locatie1, Locatie2, Van, Tot, Voertuig , Persoon, Chauffeur, PID},
                       		loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2)
                   end
          end
      end;
    {generateFixedAgenda,Dag, PID} ->  
    	self()!{insertVoertuig1, (Dag-1)*24,Dag, PID}, 
    	loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
    {insertVoertuig1, Time,Dag, PID}->
      if(Time < Dag*24) ->
        Afspraken = ets:lookup(AfsprakenTabel, Time),
        if(Afspraken == [])-> 
        	self()!{insertVoertuig1, Time+1,Dag, PID }, 
        	loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
        true ->
        	[Af|_] = Afspraken, 
        	{Van, Tot, Locatie1, Locatie2, Passagiers, Persoon} = Af, 
        	ReisDuur = (getDuur(Locatie1,ets:lookup(locaties,Locatie2))/1000),
            	if(Passagiers == false) -> 
            		[{_,_,_,_,Rijbewijs}] = ets:lookup(objecten, Persoon),
                	if(Rijbewijs == true) ->
                		Voertuig = checkResources(Autos, Fietsen, Matches, Van-ReisDuur, Tot+ReisDuur, Persoon),
                		if(Voertuig == "Geen voertuigen vrij") -> 
                			io:format("afspraak kan niet worden gemaakt voor : ~p want er zijn geen voertuigen vrij \n",[Persoon]),  
                			ets:delete_object(AfsprakenTabel, {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}), 
                			self()!{insertVoertuig1, Time,Dag, PID }, 
                			loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
                  		true -> 
                  			Persoon!{maakafspraak, Locatie1, Van-ReisDuur, Voertuig, Persoon, PID}, 
                  			Persoon!{maakafspraak, Locatie2, Tot, Voertuig, Persoon, PID },  
                  			ets:insert(Matches, {Voertuig, Van-ReisDuur, Tot+ReisDuur, Persoon}),
                  			ets:insert(Matches2, {Persoon, Van-ReisDuur, Tot+ReisDuur, Voertuig}), 
                  			ets:delete_object(AfsprakenTabel, {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}),
                    			self()!{insertVoertuig1,Time,Dag, PID },
                    			loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2)
                		end;
                	true ->
                  		ReisDuur = (getDuur(Locatie1,ets:lookup(locaties,Locatie2))/1000),
                  		Voertuig = checkResources([], Fietsen, Matches, Van-ReisDuur, Tot+ReisDuur, Persoon ),
                  		if(Voertuig == "Geen voertuigen vrij") -> 
                  			io:format("afspraak kan niet worden gemaakt voor : ~p want er zijn geen voertuigen vrij \n",[Persoon]),  
                  			ets:delete_object(AfsprakenTabel, {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}), 
                  			self()!{insertVoertuig1, Time,Dag, PID }, 
                  			loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
             			true -> 
             				Persoon!{maakafspraak, Locatie1, Van-ReisDuur, Voertuig, Persoon , PID }, 
				     	Persoon!{maakafspraak, Locatie2, Tot, Voertuig, Persoon, PID },
				     	ets:insert(Matches, {Voertuig, Van-ReisDuur, Tot+ReisDuur, Persoon}),
				     	ets:insert(Matches2, {Persoon, Van-ReisDuur, Tot+ReisDuur, Voertuig}), 
				     	ets:delete_object(AfsprakenTabel, {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}),
					self()!{insertVoertuig1,Time,Dag, PID },
					loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2)
             			end
			end;

      		true -> 
		      	Voertuig = checkResources(Autos, Fietsen,Matches, Van-ReisDuur, Tot+ReisDuur, Persoon),
		      	Chauffeur = checkChauffeurs(Chauffeurs,Matches2, Van-ReisDuur, Tot+ReisDuur, Persoon),
			if(Voertuig == "Geen voertuigen vrij") -> 
				io:format("afspraak kan niet worden gemaakt voor : ~p want er zijn geen voertuigen vrij \n",[Persoon]),  
				ets:delete_object(AfsprakenTabel, {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}), 
				self()!{insertVoertuig1, Time,Dag, PID }, 
				loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
			true ->
				if(Chauffeur == "Geen chauffeurs vrij") -> 
					io:format("afspraak kan niet worden gemaakt voor : ~p want er zijn geen chauffeurs vrij \n",[Persoon]),  				ets:delete_object(AfsprakenTabel, {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}), 
					self()!{insertVoertuig1, Time,Dag, PID }, 
					loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2);
				true ->
					ets:delete_object(AfsprakenTabel, {Van, Tot, Locatie1, Locatie2, Passagiers, Persoon}), 
					ets:insert(Matches, {Voertuig, Van-ReisDuur, Tot+ReisDuur, Chauffeur}), 
					ets:insert(Matches2, {Chauffeur, Van-ReisDuur, Tot+ReisDuur, Voertuig}),
				        Persoon!{maakafspraak, Locatie1, Locatie2, Van, Tot, Voertuig , Persoon, Chauffeur, PID}, 
				        self()!{insertVoertuig1, Time,Dag, PID }, 
				        loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2)
				end
			end
		end
	end;
      true -> 
      	loop(Autos, Fietsen, Chauffeurs, AfsprakenTabel, Matches, Matches2)
      end
end.

zonder(_,[]) -> 
	[];
zonder(X,[Y|YS]) when X==Y -> 
	zonder(X,YS);
zonder(X,[Y|YS])-> 
	[Y|zonder(X,YS)].

checkResources([], [],  _Tabel, _Van, _Tot, _Persoon) -> 
	"Geen voertuigen vrij";
checkResources([], [F|Fietsen], Tabel,  Van, Tot, Persoon) -> 
	Afspraken = ets:lookup( Tabel , F),
  	Check = checkVrij(Afspraken, Van, Tot, Persoon),
  	if(Check==false) -> 
  		checkResources([], Fietsen,  Tabel, Van, Tot, Persoon);
    		true -> F
  	end;
checkResources([A|Autos], [F|Fietsen],  Tabel, Van, Tot, Persoon) -> 
	Afspraken = ets:lookup( Tabel , A),
	Check = checkVrij(Afspraken, Van, Tot, Persoon),
  	if(Check==false) -> 
  		checkResources(Autos, [F|Fietsen], Tabel, Van, Tot, Persoon);
    	true -> 
    		A
  	end.

checkVrij([], _Van, _Tot, _Persoon) -> 
	true;
checkVrij([A], Van, Tot, Persoon) -> 
	{_Voertuig, Van2, Tot2, Persoon2} = A,
  	if(Persoon == Persoon2) -> true;
    	true -> 
    		if(Van > Tot2) ->
    			true;
             	true -> 
             		if(Tot < Van2) ->
             			true;
                      	true -> false
                    	end
           	end
  	end;
  	
checkVrij([A|Afspraken], Van, Tot, Persoon) -> 
	{_Voertuig, Van2, Tot2, Persoon2} = A,
  	if(Persoon == Persoon2) -> 
  		checkVrij(Afspraken, Van, Tot, Persoon);
    	true -> 
    		if(Van > Tot2) ->
    			checkVrij(Afspraken, Van, Tot, Persoon);
             	true-> 
             		if(Tot < Van2) -> 
             			checkVrij(Afspraken, Van, Tot, Persoon);
                      	true -> 
                      		false
                    	end
           	end
  	end.

checkChauffeurs([],  _Tabel, _Van, _Tot, _Persoon) ->  
	"Geen chauffeurs vrij";
checkChauffeurs([C|Chauffeurs], Tabel, Van, Tot, Persoon) ->  
	Afspraken = ets:lookup( Tabel, C),
 	Check = checkVrij(Afspraken, Van, Tot, Persoon),
  	if(Check==false) -> 
  		checkChauffeurs(Chauffeurs,  Tabel, Van, Tot, Persoon);
    	true -> C
  	end.

getDuur(_,[])-> 
	[];
getDuur(Loc2,[{_,Locatie2,Duur}]) -> 
	if(Locatie2 == Loc2) -> 
		Duur;
	true -> 
		[]
        end;
getDuur(Loc2 , [{_,Locatie2 , Duur}|XS]) -> 
	if(Locatie2 == Loc2) -> 
		Duur;
        true -> getDuur(Loc2,XS)
        end.
