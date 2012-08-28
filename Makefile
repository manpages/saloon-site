# Configurable values
NODE := saloon_demo
#/Configurable values

init:
	date 

	./rebar get-deps
	./rebar compile

	cd rel ;\
	../rebar create-node nodeid=$(NODE)

	sed ./reltool.config -e 's,saloon_demo,$(NODE),' > ./rel/reltool.conf

	date

update:
	date

	./rebar clean
	./rebar compile
	
	cd ./rel ;\
	../rebar generate force=1

	date

##
## Making the release bundle.
## TODO: tar the release and make the deployment script that checks compatibility
##
release:
	date

	cd ./rel ;\
	../rebar generate force=1

	date

.PHONY: update clean
