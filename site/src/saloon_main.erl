-module(saloon_main).

-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/2]).

-include_lib("eunit/include/eunit.hrl").

init({_Any, http}, Req, []) ->
	saloon_init:prepare(Req),
	{State, _} = cowboy_http_req:path_info(Req),
	{ok, Req, State}.

handle(Req, _State) ->
	%% Inline example:
	% Profile = myproject_user_model:profile(saloon_ctx:user()),
	% Rendered = myproject_main_view:get(State),
	%%/Inline example

	saloon_http:return(<<"<h1>It works!</h1>">>, Req).

terminate(_R, _S) ->
	ok.
