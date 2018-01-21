

%%%-------------------------------------------------------------------
%%% @author Simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. okt 2017 14:48
%%%-------------------------------------------------------------------
-module(auto).
-author("Simon").

%% API
-include("records.hrl").
-export([start/0, init/0,loop/6]).


start()->
  PID = spawn(?MODULE, init, []),
  PID.


init()->
  VN = vanNaar:start(),
  loop("thuis","geen bestuurder",[],"default",false,VN).

loop(Locatie, Bestuurder, Passagiers, Naam,Rijd,VN)->
  receive
    {updateData, PID} ->
      PID!{updateDataA, Naam, self(), Locatie,VN},
      loop(Locatie, Bestuurder, Passagiers, Naam,Rijd,VN);
    {getLocatie} -> 
    	erlang:display(Locatie),
    	loop(Locatie, Bestuurder, Passagiers, Naam,Rijd,VN);
    {getBestuurder} -> 
    	erlang:display(Bestuurder),
    	loop(Locatie, Bestuurder, Passagiers, Naam,Rijd,VN);
    {getPassagiers} -> 
    	erlang:display(Passagiers), 
    	loop(Locatie, Bestuurder, Passagiers, Naam,Rijd,VN);
    {setBestuurder, NieuweBestuurder, PID} -> 
    	self()!{updateData, PID}, 
    	PID!{log,{"setBestuurder",NieuweBestuurder}}, 
    	loop(Locatie, NieuweBestuurder, Passagiers,Naam,Rijd,VN);
    {setLocatie, NieuweLocatie, PID} ->
    	self()!{updateData, PID}, 
    	PID!{log,"setLocatieAuto" , [NieuweLocatie,self()]},
    	loop(NieuweLocatie, Bestuurder, Passagiers,Naam,Rijd,VN);
    {setNaam, NieuweNaam, PID} -> 
    	self()!{updateData, PID},
    	PID!{log,"setNaam" , NieuweNaam}, 
    	loop(Locatie, Bestuurder, Passagiers, NieuweNaam,Rijd,VN);
    {addPassagier, NieuwePassagier, PID}-> 
    	self()!{updateData, PID},
    	PID!{log,"addPassagier", NieuwePassagier},
    	loop(Locatie, Bestuurder, [NieuwePassagier|Passagiers],Naam,Rijd,VN);
    {setRijd , NieuweR, PID} -> 
    	PID!{log,"setRijd",[NieuweR,self()]},
      	if(NieuweR == false) ->
      		self()!{verwijderBestuurder,PID},
      		loop(Locatie,Bestuurder,Passagiers,Naam,NieuweR,VN);
        true ->  
        	loop(Locatie,Bestuurder,Passagiers,Naam,NieuweR,VN)
      	end;

  %{setAgenda , Tijdstip , NieuweLocatie , Duur,NieuweBestuurder} -> erlang:display("auto") ,loop(Locatie,Bestuurder,Passagiers,[#afspraakauto{locatie = NieuweLocatie,van = Tijdstip , tot= Tijdstip+Duur , bestuurder = Bestuurder}|Agenda] );
    {smsSchool} -> 
    	erlang:display({"vertrek nu naar school" , Bestuurder}),
    	loop(Locatie, Bestuurder, Passagiers, Naam,Rijd,VN);
    {smsGearriveerd} -> 
    	io:format("auto is gearriveerd op ~p met ~p",[Locatie,Bestuurder]),
    	loop(Locatie, Bestuurder,Passagiers, Naam,Rijd,VN);
    {verwijderPassagier , OudePassagier, PID} ->
    	self()!{updateData, PID},
    	VN!{gearriveerdPass},
    	PID!{log,"verwijderPassagier", OudePassagier},
    	loop(Locatie , Bestuurder , zonder(OudePassagier,Passagiers),Naam,Rijd,VN);
    {verwijderBestuurder,PID} ->
    	self()!{updateData,PID},
    	PID!{log,"verwijderBestuurder",Bestuurder},
    	loop(Locatie,[],Passagiers,Naam,Rijd,VN);
    {getVN , Tijd , PID,PIDP} ->
    	PIDP!{getAfspraak,Tijd,PID,VN},
    	loop(Locatie,Bestuurder,Passagiers,Naam,Rijd,VN)
  end.

zonder(_,[]) -> [];
zonder(X,[Y|YS]) when X==Y -> zonder(X,YS);
zonder(X,[Y|YS])-> [Y|zonder(X,YS)].
