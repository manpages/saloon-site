-module(saloon_lang).

-export([t/1]).

-define(SRCPATH, "site/src/").
-define(BINPATH, "site/ebin/").

-include_lib("eunit/include/eunit.hrl").
-include_lib("kernel/include/file.hrl").

%%spawnpoint

t([{Tag,X}]) -> 
	Fname = ?SRCPATH ++ saloon_util:to_list(?MODULE) ++ ".erl",
	{_, Myself} = file:read_file(Fname),
	NewFunText = io_lib:format("%%spawnpoint~n~nt([{~w,<<\"~ts\">>}]) -> ~n	case saloon_ctx:language() of ~n", [Tag,X]),
	NewFunText2= lists:foldl(fun (L, Acc) -> Acc ++ io_lib:format("		~ts -> <<\"~ts\">>;~n", [L, X]) end, "", saloon_conf:languages()),
	NewFunText3= io_lib:format("		_ -> <<\"*~ts*\">>~n	end;", [X]),
	NewerSelf = re:replace(
		Myself, 
		<<"%%spawnpoint">>, 
		unicode:characters_to_binary(NewFunText ++ NewFunText2 ++ NewFunText3)
	),
	file:write_file("site/src/saloon_lang.erl", NewerSelf),
	compile:file(Fname, [verbose,report_errors,report_warnings,{outdir,?BINPATH}]),
	%os:cmd("erlc " ++ Fname ++ " -o " ++ ?BINPATH), %%TODO: change to compile:file!
	code:purge(saloon_lang),
	code:load_file(saloon_lang),
	[<<"¡">>, X, <<"!">>].
