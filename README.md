# Multi-Project Buildbot Configuration Example #

[Buildbot](https://buildbot.net) is an excellent tool for automating
all of your build and deploy needs across platforms for a project.
However, a Buildbot instance isn't really designed for multiple,
disparate projects within an organization.  This configuration example
shows how to add a new buildbot master for each project, neatly
organizing them into containers and placing them behind reverse
proxies on the same domain.

We use docker-compose with Nginx, PostgreSQL and Buildbot Master
containers to configure multiple Buildbot masters which run
side-by-side.
                
    example.net/buildbot/project1  # buildbot master for proj1
    example.net/buildbot/project2  # buildbot master for proj2
    
Note that multi-project Buildbot is different than (but not
fundamentally incompatible with) Buildbot
[Multi-master](http://docs.buildbot.net/latest/manual/cfg-global.html#multi-master-mode)
which lets a single project have more than one master for
high-availability.

## Features ##
 
 - All buildbot masters under one domain for easy addition of SSL
 - All state in a single PostgreSQL database volume for easy backup
 - Easy to add a new master for a new project
 - Map all buildbot master config to host for easy iteration
 - Protected by auth-digest htpasswd in Nginx out of the gate
 - Letsencrypt SSL support
 - Containerized Worker example with non-root user for added security
 - Sample Systemd startup scripts

## Configuring auth ##

The file `/webproxy/conf/buildbot.htpasswd` should be set to the
login/passwords you want to use.  The easiest way to do this is to run
the following command:

    htpasswd -c buildbot.htpasswd <username>
                
## Adding a New Master ##

 1. Add the master to `docker-compose.yml`, copying the examples.
    - Set the `BUILDBOT_WEB_URL` to the path within the domain.
    - Set `POSTGRES_DB` to a unique db name, containing the state for this master.
    - In order to have workers connect, map `BUILDBOT_WORKER_PORT` to
      a unique port on the host.  ie: `"9999:9989"`, where 9999 is the
      host port to listen on, and 9989 is the container's `BUILDBOT_WORKER_PORT`.
    - Add your new master to the `links` section of `webproxy`.
    - Leave the web port at 8080; it's just for inside the container
      anyway, and is never made public.
 2. In `webproxy/conf/sites-enabled`, make the following changes:
    - Rename the example domain to your domain.
    
## Running Letsencrypt ##

The `ssl` subdirectory contains `init.sh` and `renew.sh` which
requests and renews letsencrypt certificates, placing them at
`/etc/letsencrypt` on the host system.

This avoids the need to reconfigure nginx to handle the ACME response.
However, it should not be attempted if you already have an
`/etc/letsencrypt` directory.  If that's the case, just edit the shell
scripts to a new path and change the Nginx keys to match.

Note that the `renew.sh` has not been sufficiently tested by the
developer because he hasn't actually had to renew his certificate at
the time this code was published.  This message will be updated once
this changes.

## Running on Startup ##

`install.sh` is provided to enable running on startup via systemd.
Configure the location of `docker-compose` in `buildbot.service`.

## Example Worker ##

There is a buildbot worker container in the `example-worker`
subdirectory which is not included in the docker-compose
configuration.  This is considered an example worker which
demonstrates how to containerize a worker for a single project.  It is
presumed that a serious multi-project configuration would have workers
strewn out over multiple computers, so it is only a standalone
example.

Containerization is relevant to multi-project configurations because
it allows for clean separation and upgrades of toolschains without
affecting other projects.

### Worker Features ###

The worker container provided is similar to the [official
image](https://hub.docker.com/r/buildbot/buildbot-worker/), but
updates package versions beyond the official one.

`build.sh` and `run.sh` demonstrate how to build and configure
environment variables to connect to a master.  Change the environment
variables to suit your configuration.

`install.sh` installs a systemd service to start the container on
system startup if that is something you would want to do.  Both it,
and the `buildbot-example-worker.service` must be configured to your
liking.  Consider it a template, or a starting point.

## Stuff to Back Up ##

Once set up, you will need to back up the following unique assets:
 
 1. All of your buildbot master configs, stored under `buildbot` outside of the containers.
 2. [PostgreSQL Docker volume](https://stackoverflow.com/questions/24718706/backup-restore-a-dockerized-postgresql-database).
 3. Letsencrypt state, stored at `ssl/mount` outside of the containers.
 4. Your customized Nginx config, stored at `webproxy/conf` outside of the containers.

