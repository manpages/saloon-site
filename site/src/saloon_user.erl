-module(saloon_user).

-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/2]).

-include_lib("../../deps/saloon/include/user.hrl").
-include_lib("eunit/include/eunit.hrl").

init({_Any, http}, Req, [Type]) ->
	saloon_init:prepare(Req),
	io:format("Initializing saloon_user with ~p~n", [Type]),
	{ok, Req, Type}.

handle(Req, "register") ->
	{ok, Rep} = case cowboy_http_req:method(Req) of
		{'GET', _} ->
			cowboy_http_req:reply(
				200, [], fril_register_view:get([]), Req
			);
		{'POST', _} ->
			case validate_registration(Req) of
				{ok, {Profile, EncPassword}} -> 
					cowboy_http_req:reply(
						302, 
						[
							{<<"Location">>, <<"/">>},	
							cowboy_cookies:cookie(
								<<"auth">>, 
								saloon_util:to_binary(saloon_auth:add_user(Profile, {md5, EncPassword})),
								[]
							)
						], <<"Redirecting...">>,
						Req
					);
				{error, Er} -> 
					ErrorProplist = [[{text, ErrorText}] || ErrorText <- Er],
					?debugFmt("ErrorProplist: ~p~n", [ErrorProplist]),
					cowboy_http_req:reply(
						200, [], fril_register_view:get([{errors, ErrorProplist}]), Req
					)
			end
	end,
	{ok, Rep, ok};

handle(Req, "logout") -> 
	{ok, Rep} =
		cowboy_http_req:reply(
				302, 
				[
					{<<"Location">>, <<"/">>},	
					cowboy_cookies:cookie(
						<<"auth">>, 
						<<"">>,
						[]
					)
				], <<"Redirecting...">>,
				Req
			),
	{ok, Rep, ok};

handle(Req, "login") ->
	fril_main_view:get([]),
	Result = case saloon_auth:login(saloon_util:pk(<<"email">>, Req), saloon_util:md5(saloon_util:pk(<<"password">>, Req))) of
		false -> 
			Rendered = fril_main_view:get([{errors, [<<"wrong password">>]}]),
			cowboy_http_req:reply(200, [], Rendered, Req);
		Cookie -> 
			{ok, Z} =
				cowboy_http_req:reply(
					302, 
					[
						{<<"Location">>, <<"/">>},	
						cowboy_cookies:cookie(
							<<"auth">>, 
							saloon_util:to_binary(Cookie),
							[]
						)
					], <<"Redirecting...">>,
					Req
				),
			Z
	end,
	{ok, Result, ok}.



terminate(_R, _S) ->
	ok.


%%
%% Private funcitons.
%%

validate_registration(Req) ->
	%% validation
	BodyQs = element(1, cowboy_http_req:body_qs(Req)),
	Unfilled = [X || {X, Y} <- BodyQs, Y == <<"">>],
	Mismatch = case saloon_util:pk(<<"password">>, Req) == saloon_util:pk(<<"confirm">>, Req) of
		false -> [<<"passwords dont match">>];
		_ -> []
	end,
	Unconfirmed = case saloon_util:pk(<<"agree">>, Req) of
		undefined -> [<<"obey eula">>];
		_ -> []
	end,
	NameTaken = case fission_syn:get({user, saloon_util:pk(<<"email">>, Req), id}) of
		false -> [];
		_     -> [<<"email taken">>]
	end,
	EmailInvalid = [], %% TODO: FIXME - now isn't checked!

	%% building role list
	Role1 = case saloon_util:pk(<<"is_freelancer">>, Req) of 
		undefined -> [];
		_         -> [freelancer]
	end,
	Role2 = case saloon_util:pk(<<"is_employer">>, Req) of
		undefined -> [];
		_         -> [employer]
	end,
	case Unfilled ++ Mismatch ++ Unconfirmed ++ NameTaken ++ EmailInvalid of 
		[] -> {ok, {
					#profile{
						firstname=saloon_util:pk(<<"first_name">>, Req),
						lastname=saloon_util:pk(<<"last_name">>, Req),
						email=saloon_util:pk(<<"email">>, Req),
						roles=Role1++Role2++[user]
					}, saloon_util:md5(saloon_util:pk(<<"password">>, Req))
				}};
		Error -> {error, Error}
	end.
