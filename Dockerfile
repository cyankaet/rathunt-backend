FROM ocaml/opam
RUN opam init --bare -a -y
RUN opam switch create backend ocaml-base-compiler.4.12.0
RUN eval $(opam env)

RUN opam install dune lwt lwt_ppx caqti caqti-lwt caqti-driver-postgresql
RUN opam pin add rock.~dev https://github.com/rgrinberg/opium.git
RUN opam pin add opium.~dev https://github.com/rgrinberg/opium.git

WORKDIR /usr/app
COPY . .

CMD make debug