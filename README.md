# Debian preseed ISO image

This repo contains a Dockerfile to create a Debian "preseeded" ISO image

[![Build Status](https://travis-ci.org/13pgeiser/debian_stable_preseed.svg?branch=master)](https://travis-ci.org/13pgeiser/debian_stable_preseed)
[![Build Status](https://dev.azure.com/pascalgeiser/debian_stable_preseed/_apis/build/status/13pgeiser.debian_stable_preseed?branchName=master)](https://dev.azure.com/pascalgeiser/debian_stable_preseed/_build/latest?definitionId=1&branchName=master)

https://wiki.debian.org/DebianInstaller/Preseed

The preseed.cfg creates a hands off installation with the following features:

* Swiss keyboard and locale
* GPT partioning
* No swap
* Sudo without password for users in the sudo group

BEWARE it will erase all data on the machine!
You've been warned!

2 ISOs are created:
* buster-server.iso -> the available disk space is assigned mostly to /var
* buster-standard.iso -> the available disk space is assigned mostly to /
