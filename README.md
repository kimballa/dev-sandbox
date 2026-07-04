
# dev-sandbox

A docker configuration for a minimal Ubuntu sandbox in which I can write and run code.
Also contains some convenience scripts for local mgmt/access.

## Setup

```
$ make build
$ ./up # or `make up`

... when finished:
# ./down # or `make down`
```

## Logging in

`make shell` will use `docker container exec` to drop into bash. 
The `ssh-sandbox` script will ssh you in.

## Environment

* Ubuntu 24.04 LTS
* username: `dev`
* ssh available on `localhost:2222`
* `$HOME/.ssh` is mounted into the sandbox to provide your private key.
* `$HOME/workspace` is a persistent volume.



