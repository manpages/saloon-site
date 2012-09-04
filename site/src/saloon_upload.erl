-module(saloon_upload).

-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/2]).

-include_lib("eunit/include/eunit.hrl").
-include_lib("saloon/include/file.hrl").

init({_Any, http}, Req, []) ->
	saloon_init:prepare(Req),
	{State, _} = cowboy_http_req:path_info(Req),
	{ok, Req, State}.

handle(Req, _State) ->
	Result = case cowboy_http_req:method(Req) of
		{'GET', _} -> saloon_upload_view:html([{}]);
		{'POST', _} -> saloon_http:receive_file(Req, #upload_state{})
	end,
	saloon_http:return(Result, Req).

terminate(_R, _S) ->
	ok.
