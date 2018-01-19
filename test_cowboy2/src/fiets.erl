%%%-------------------------------------------------------------------
%%% @author Simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. dec 2017 14:32
%%%-------------------------------------------------------------------
-module(fiets).
-author("Simon").

%% API
%% API
-include("records.hrl").
-export([start/0, init/0,loop/5, zonder/2]).


start()->
  PID = spawn(?MODULE, init, []),
  PID.


init()->
  VN=vanNaar:start(),
  loop("thuis","geen bestuurder","default",false,VN).



loop(Locatie, Bestuurder, Naam,Rijd,VN)->
  receive
    {updateData, PID} ->
      PID!{updateDataF, Naam, self(), Locatie,VN},
      loop(Locatie, Bestuurder, Naam,Rijd,VN);
    {getLocatie} -> erlang:display(Locatie),loop(Locatie, Bestuurder, Naam,Rijd,VN);
    {getBestuurder}-> erlang:display(Bestuurder),loop(Locatie, Bestuurder, Naam,Rijd,VN);
    {setBestuurder, NieuweBestuurder, PID}-> self()!{updateData, PID}, PID!{log,{"setBestuurder",NieuweBestuurder}}, loop(Locatie, NieuweBestuurder, Naam,Rijd,VN);
    {setLocatie, NieuweLocatie, PID}->self()!{updateData, PID}, PID!{log,"setLocatie" , NieuweLocatie},loop(NieuweLocatie, Bestuurder,Naam,Rijd,VN);
    {setNaam, NieuweNaam, PID} -> self()!{updateData, PID},PID!{log,"setNaam" , NieuweNaam}, loop(Locatie, Bestuurder, NieuweNaam,Rijd,VN);
    {setRijd , NieuweR, PID} -> PID!{log,"setRijd",[NieuweR,self()]},
      if(NieuweR == false)->self()!{verwijderBestuurder,PID},loop(Locatie,Bestuurder,Naam,NieuweR,VN);
        true ->  loop(Locatie,Bestuurder,Naam,NieuweR,VN)
      end;
    {checkFiets, PIDPers, NieuweLocatie, PID}-> PIDPers!{verplaatsFiets, self(), NieuweLocatie, PID},loop(Locatie, Bestuurder, Naam,Rijd,VN);

    {smsSchool} -> erlang:display({"vertrek nu naar school" , Bestuurder}) ,loop(Locatie, Bestuurder ,Naam,Rijd,VN);
    {smsGearriveerd} -> io:format("fiets is gearriveerd op ~p met ~p" , [Locatie,Bestuurder]) , loop(Locatie, Bestuurder, Naam,Rijd,VN);
    {verwijderBestuurder,PID}-> self()!{updateData , PID}, PID!{log,{"verwijderBestuurder"}}, loop(Locatie , [] ,  Naam,Rijd,VN);
    {getVN , Tijd , PID,PIDP} -> PIDP!{getAfspraak,Tijd,PID,VN},loop(Locatie,Bestuurder,Naam,Rijd,VN)

  end.

zonder(_,[]) -> [];
zonder(X,[Y|YS]) when X==Y -> zonder(X,YS);
zonder(X,[Y|YS])-> [Y|zonder(X,YS)].

