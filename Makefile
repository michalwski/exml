.PHONY: rel deps test

all: deps compile

compile: rebar
	./rebar compile

deps: rebar
	./rebar get-deps

clean: rebar
	./rebar clean

test-deps: rebar
	./rebar -C rebar.test.config get-deps

test-compile: rebar test-deps
	./rebar -C rebar.test.config compile

test: test-compile
	./rebar -C rebar.test.config skip_deps=true eunit

coverage-report: $(shell ls -1rt `find .eunit -type f -name \*.coverdata 2>/dev/null` | tail -n1)
	erl -noshell -pa ebin deps/*/ebin -eval 'ecoveralls:travis_ci("$?"), init:stop()'

rebar:
	wget https://github.com/rebar/rebar/releases/download/2.5.1/rebar &&\
	chmod u+x rebar

dialyzer/erlang.plt:
	@mkdir -p dialyzer
	@dialyzer --build_plt --output_plt dialyzer/erlang.plt \
	-o dialyzer/erlang.log --apps kernel stdlib erts; \
	status=$$? ; if [ $$status -ne 2 ]; then exit $$status; else exit 0; fi

dialyzer/exml.plt:
	@mkdir -p dialyzer
	@dialyzer --build_plt --output_plt dialyzer/exml.plt \
	-o dialyzer/exml.log ebin; \
	status=$$? ; if [ $$status -ne 2 ]; then exit $$status; else exit 0; fi

erlang_plt: dialyzer/erlang.plt
	@dialyzer --plt dialyzer/erlang.plt --check_plt -o dialyzer/erlang.log; \
	status=$$? ; if [ $$status -ne 2 ]; then exit $$status; else exit 0; fi

exml_plt: dialyzer/exml.plt
	@dialyzer --plt dialyzer/exml.plt --check_plt -o dialyzer/exml.log; \
	status=$$? ; if [ $$status -ne 2 ]; then exit $$status; else exit 0; fi

dialyzer: erlang_plt exml_plt
	@dialyzer --plts dialyzer/*.plt --no_check_plt \
	--get_warnings ebin

