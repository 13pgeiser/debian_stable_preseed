Debian Preseed, Ansible and Docker: the ultimate deployment solution
####################################################################

:date: 2020-07-28 14:00
:modified: 2022-11-27 14:00
:tags: debian, ansible, docker
:authors: Pascal Geiser
:summary: Fully automatic debian installation with preseed, ansible and docker

.. contents::

Build of ISOs, execution of the debian-installer in qemu and deployment with Ansible:


|github-badge|

.. |github-badge| image:: https://github.com/13pgeiser/debian_stable_preseed/actions/workflows/publish.yml/badge.svg
              :target: https://github.com/13pgeiser/debian_stable_preseed/actions/workflows/publish.yml

|

.. raw:: html

	<i class="fa fa-github" aria-hidden="true"></i>&nbsp;<a href="https://github.com/13pgeiser/debian_stable_preseed">repository: debian_stable_preseed</a>

|

M4 usage heavily inspired by http://bobbynorton.com/posts/includes-in-dockerfiles-with-m4-and-make/

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
 * debian-preseed-server.iso -> the available disk space is assigned mostly to /var
 * debian-preseed-standard.iso -> the available disk space is assigned mostly to /

To use the ISO::

	sudo dd if=debian-preseed-server.iso of=<put the device matching the USB key you just plugged>

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

As a demonstration, the following roles are applied (see `demo.yml <https://github.com/13pgeiser/ansible_debian/blob/master/demo/demo.yml>`__):
 * `ansible_debian <https://github.com/13pgeiser/ansible_debian/blob/master/tasks/tasks.yml>`__ : configure non-free, install firmwares and configure locales
 * `ansible_debian/roles/users <https://github.com/13pgeiser/ansible_debian/blob/master/roles/users>`__ : configure the user accounts
 * `ansible_debian/roles/docker <https://github.com/13pgeiser/ansible_debian/tree/master/roles/docker>`__ : install docker
 * `ansible_debian/roles/docker_portainer <https://github.com/13pgeiser/ansible_debian/tree/master/roles/docker_portainer>`__ : deploy `Portainer <https://www.portainer.io/>`__ to easily manage the containers locally
 * `ansible_debian/roles/groups <https://github.com/13pgeiser/ansible_debian/tree/master/roles/groups>`__ : Add users to groups

This is just an example how easy it is to deploy fully automatically a debian system.

Have fun!


