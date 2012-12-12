## Configurable values
# Node ID. Unique per system. Lowercase-only.
NODE := saloon_demo

init:
	date 

	./rebar get-deps
	./rebar compile

	id [ ! -d "rel" ] ; then mkdir "rel" ; fi
	cd rel ;\
	../rebar create-node nodeid=$(NODE)

	sed ./reltool.config -e 's,saloon_demo,$(NODE),' > ./rel/reltool.conf
	sed ./dev.sh.demo -e 's,saloon_demo_dev,$(NODE)_dev,' > ./dev.sh

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
