.PHONY: test
run:
	dune exec bin/app.exe

debug:
	dune exec bin/app.exe -- --debug

test:
	OCAMLRUNPARAM=b dune exec test/main.exe
