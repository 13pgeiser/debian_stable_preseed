Debian Preseed, Ansible and Docker: the ultimate deployment solution
####################################################################

:date: 2020-07-28 14:00
:modified: 2020-07-28 14:00
:tags: debian, ansible, docker
:authors: Pascal Geiser
:summary: Fully automatic debian installation with preseed, ansible and docker

.. contents::

Build of ISOs and execution of the debian-installer in qemu up to ssh connection when the machine is ready:

|travis-badge|

.. |travis-badge| image:: https://travis-ci.org/13pgeiser/debian_stable_preseed.svg?branch=master
              :target: https://travis-ci.org/github/13pgeiser/debian_stable_preseed

Build of ISOs, execution of the debian-installer in qemu and deployment with Ansible:

|azure-badge|

.. |azure-badge| image:: https://dev.azure.com/pascalgeiser/debian_stable_preseed/_apis/build/status/13pgeiser.debian_stable_preseed?branchName=master
              :target: https://dev.azure.com/pascalgeiser/debian_stable_preseed/_build/latest?definitionId=1&branchName=master

Debian Preseed
**************

`Debian Preseed <https://wiki.debian.org/DebianInstaller/Preseed>`__ is a mean to completely automate
the debian-installer steps.
There are several ways to setup the `debian installer "preseeding" <https://www.debian.org/releases/stable/amd64/apb.en.html>`__.
The one I choose is to edit the netboot ISO image in order to include my installer configuration.

The preseed.cfg creates a hands off installation with the following features:
 * Swiss keyboard and locale
 * GPT partioning
 * No swap
 * Sudo without password for users in the sudo group

Feel free to adapt to your needs!

To rebuild the ISO images, make sure you've Docker installed and type::

	make

This will download the debian installer ISO image, modify it and provide 2 ISO:
 * buster-server.iso -> the available disk space is assigned mostly to /var
 * buster-standard.iso -> the available disk space is assigned mostly to /

To use the ISO::

	sudo dd if=buster-server.iso of=<put the device matching the USB key you just plugged>

.. warning::

	this will erase the entire content of the USB key.

.. warning::

	the debian installer will not ask any question -> it will erase completely the first drive of the machine to install debian.


Testing the iso locally
=======================

To test the iso, first make sure you have KVM / Qemu and a vncviewer installed. You can then run:
 * *make test_iso* in one terminal: this will start QEMU in background and wait for the full installation to finish by connecting with SSH inside the resulting installation
 * *vncviewer localhost:59000* to see the process in action


.. image:: /images/debian_stable_preseed/Grub.png
    :alt: Grub menu


.. image:: /images/debian_stable_preseed/Partitioning.png
    :alt: Partitioning


.. image:: /images/debian_stable_preseed/Installing.png
    :alt: Installation


.. image:: /images/debian_stable_preseed/RunningPreseed.png
    :alt: Running Preseed

Ansible
*******

`Ansible <https://www.ansible.com/>`__ is the ultimate IT automation tool.
`test_ansible.sh <https://github.com/13pgeiser/debian_stable_preseed/blob/master/scripts/test_ansible.sh>`__ fetches
the roles using ansible-galaxy. Then, it calls ansible-playbook on the freshly installed debian image.

As a demonstration, the following roles are applied (see `task.yml <https://github.com/13pgeiser/ansible_machine_demo/blob/master/tasks/main.yml>`__):
 * `ansible_buster_base <https://github.com/13pgeiser/ansible_buster_base>`__ : configure non-free, install firmwares and configure locales
 * `ansible_users <https://github.com/13pgeiser/ansible_users>`__ : configure the user accounts
 * `ansible_docker <https://github.com/13pgeiser/ansible_docker>`__ : install docker
 * `ansible_portainer <https://github.com/13pgeiser/ansible_docker_portainer>`__ : deploy `Portainer <https://www.portainer.io/>`__ to easily manage the containers locally
 * `ansible_registy <https://github.com/13pgeiser/ansible_docker_registry>`__ : deploy a local docker registry
 * `ansible_groups <https://github.com/13pgeiser/ansible_groups>`__ : Add users to groups

This is just an example how easy it is to deploy fully automatically a debian system.

Have fun!


