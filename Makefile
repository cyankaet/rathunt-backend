.PHONY: test migrate

build:
	dune build

docs:
	dune build @doc
	
run:
	dune exec bin/app.exe -- -p ${PORT}

debug:
	dune exec bin/app.exe -- -p ${PORT} --debug

test:
	dune exec bin/migrate.exe && OCAMLRUNPARAM=b dune exec test/main.exe

utop:
	dune utop lib

migrate:
	dune exec bin/migrate.exe

rollback:
	dune exec bin/rollback.exe
