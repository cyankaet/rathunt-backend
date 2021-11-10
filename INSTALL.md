# Installing and Building the RatHunt Backend
RatHunt is a puzzlehunt website. On the backend server, we host answers and team profiles.

## PostgreSQL
This backend relies on having a working PostgreSQL installation. This will vary widely by OS. The Arch Linux installation instructions can be found [here](https://wiki.archlinux.org/title/PostgreSQL), or Google to find instructions for your own Linux or Mac computer. You'll need to create a database. The name of this database, along with your username, need to be embedded in `db.ml`'s *connection_url* field. This url should take the form `postgresql://<uname>@localhost:5432/<dataBaseName>`. If that doesn't work, you'll need to check your PostgreSQL config file to see what ports you're listening on.

## OPAM
Unlike our frontend, the backend uses the CS 3110 course-supported compiler. You can use your course switch, or create a new switch:
```
opam switch create rathunt ocaml-base-compiler.4.12.0
```
You'll need to install these packages:
```
opam install lwt lwt_ppx caqti caqti-lwt caqti-driver-postgresql
```
There are also some required packages that are not currently available through OPAM. Install these by pinning them:
```
opam pin add rock.~dev https://github.com/rgrinberg/opium.git
opam pin add opium.~dev https://github.com/rgrinberg/opium.git
```
## Local Hosting
While the API is currently non-existent, I can tell you that it runs on `localhost:3000`.