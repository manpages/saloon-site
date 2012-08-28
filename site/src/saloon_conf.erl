-module(saloon_conf).

-export([
		dispatch/0,
		port/0,
		languages/0,
		initial_data/0,
		initial_testing_data/0
	]).


dispatch() ->
	[
		{'_', [
				%%
				%% Site controllers
				%%

				 {[<<"register">>, '...'], saloon_user, ["register"]}
				,{[<<"login">>, '...'], saloon_user, ["login"]}
				,{[<<"logout">>, '...'], saloon_user, ["logout"]}

				%%
				%% Default handlers
				%%

				,{[<<"static">>, '...'], cowboy_http_static, 
					[
						 {directory, <<"./static">>}
						,{mimetypes, [
								 {<<".txt">>, [<<"text/plain">>]}
								,{<<".html">>, [<<"text/html">>]}
								,{<<".htm">>, [<<"text/html">>]}
								,{<<".css">>, [<<"text/css">>]}
								,{<<".js">>, [<<"application/javascript">>]}
						]}
					]
				 }
				,{'_', saloon_main, []}
			]}
	].

languages() -> [en, ru, lv].

port() -> 50607.

%%
%% Initial data for production installations K->V
%%
initial_data() -> 
	[].

%%
%% Initial data for dev. environments K->V
%%
initial_testing_data() ->
	[].
