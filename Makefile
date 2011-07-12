.PHONY: rel deps test

all: deps compile

compile:
	./rebar compile

deps:
	./rebar get-deps

clean:
	./rebar clean

test:
	./rebar skip_deps=true eunit suite=exml_tests