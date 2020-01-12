# Debian preseed ISO image

This repo contains a Dockerfile to create a Debian "preseeded" ISO image

https://wiki.debian.org/DebianInstaller/Preseed

The preseed.cfg creates a hands off installation with the following features:

* Swiss keyboard and locale
* GPT partioning
* No swap
* Docker-ce and docker-compose pre-installed.
* Sudo without password for users in the sudo group

BEWARE it will erase all data on the machine!
You've been warned!

2 ISOs are created:
* buster-server.iso -> the available disk space is assigned mostly to /var
* buster-standard.iso -> the available disk space is assigned mostly to /
