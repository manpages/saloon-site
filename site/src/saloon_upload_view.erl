-module(saloon_upload_view).

-export([html/1]).

html(_) ->
<<"<form enctype=\"multipart/form-data\" method=\"post\"><p>Type some text (if you like):<br><input type=\"text\" name=\"textline\" size=\"30\"></p><p>Please specify a file, or a set of files:<br><input type=\"file\" name=\"datafile\" size=\"40\"></p><div><input type=\"submit\" value=\"Send\"></div></form>">>.
