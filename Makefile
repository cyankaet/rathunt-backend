.PHONY: test migrate

build:
	dune build
	
run:
	dune exec bin/app.exe

debug:
	dune exec bin/app.exe -- -p ${PORT} --debug

test:
	OCAMLRUNPARAM=b dune exec test/main.exe

utop:
	dune utop lib

migrate:
	dune exec bin/migrate.exe

rollback:
	dune exec bin/rollback.exe
