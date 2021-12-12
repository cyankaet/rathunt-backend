# Installing and Building the RatHunt Backend
RatHunt is a puzzlehunt website. On the backend server, we host answers and team profiles.

## PostgreSQL
This backend relies on having a working PostgreSQL installation. This will vary widely by OS. The Arch Linux installation instructions can be found [here](https://wiki.archlinux.org/title/PostgreSQL), or Google to find instructions for your own Linux or Mac computer. You'll need to create a database. The name of this database, along with your username, need to be available as a `$DATABASE_URL` environment variable. If you're not familiar with creating environment variables, you're going to need to either run `export DATABASE_URL=<url>`, which will create a temporary environment variable that will only exist within a single terminal session. To create this more permanently, and globally, add the variable to your `.bashrc` (or analagous). This url should take the form `postgresql://<uname>@localhost:5432/<database_name>`. If that doesn't work, you'll need to check your PostgreSQL config file to see what ports you're listening on.

## OPAM
Unlike our frontend, the backend uses the CS 3110 course-supported compiler. You can use your course switch, or create a new switch:
```
opam switch create rathunt ocaml-base-compiler.4.12.0
```
You'll need to install these packages:
```
opam install lwt lwt_ppx caqti caqti-lwt caqti-driver-postgresql ounit2
```
There are also some required packages that are not currently available through OPAM. Install these by pinning them:
```
opam pin add rock.~dev https://github.com/rgrinberg/opium.git
opam pin add opium.~dev https://github.com/rgrinberg/opium.git
```
## Local Hosting
You can run the server with the `make run` command. The server should run on on `localhost:3000`, unless you have a `PORT` environment variable specified. If you're having trouble making POST and GET requests, try setting that `PORT` variable. The API for the server is available in the README.