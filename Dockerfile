FROM ocaml/opam
RUN opam init --bare -a -y
RUN opam switch create backend ocaml-base-compiler.4.12.0
RUN opam install lwt lwt_ppx caqti caqti-lwt caqti-driver-postgresql

WORKDIR /usr/app
COPY . .

CMD make debug