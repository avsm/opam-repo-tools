all:
	ocaml setup.ml -configure
	ocaml setup.ml -build

clean:
	rm -rf dist _build
