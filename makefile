# Path to the common M4 files.
M4_COMMON = `pwd`/_m4
M4 = m4

# Debian buster preseed
DEBIAN_NET_INST_VER:=11.1.0
DEBIAN_NET_INST_SHA256:=8488abc1361590ee7a3c9b00ec059b29dfb1da40f8ba4adf293c7a30fa943eb2

# Include local config if any
-include ../docker_config.mak

# List of docker images & targets
DOCKERFILES=\
	debian_preseed/Dockerfile \
	debian_preseed/server.preseed \
	debian_preseed/standard.preseed \
	debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso \
	debian-preseed-standard.iso \
	debian-preseed-server.iso \

# Build default, build all Dockerfiles, this will create the associated images.
all:	$(DOCKERFILES)

# Default rule for m4 -> build docker image!
%: %.m4
	$(M4) -I $(M4_COMMON) $^ >$@.tmp
	$(eval IS_DOCKERFILE := $(shell echo $@ | grep Dockerfile))
	if [ "$(IS_DOCKERFILE)" != "" ]; then cd $(dir $@) && docker build --rm -f Dockerfile.tmp -t $(shell dirname $@) . && docker image prune -f ; fi
	mv $@.tmp $@

# Delete all Dockerfiles, this will force a rebuild.
clean:
	rm -f $(DOCKERFILES)
	rm -f qemu.pid hda.tmp
	rm -rf ./venv ./roles

# Clean everything
mrproper: clean
	docker rmi -f `docker images -q` || true
	docker rm -f `docker ps -a -q` || true
	docker system prune -f -a

debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso:
	if [ "`sha256sum debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso | cut -d' ' -f1`" != "$(DEBIAN_NET_INST_SHA256)" ]; then curl -SL https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso -o debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso; fi
	if [ "`sha256sum debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso | cut -d' ' -f1`" != "$(DEBIAN_NET_INST_SHA256)" ]; then echo "Invalid SHA256" ; rm -f debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso ; exit 1 ; fi
	touch $@

debian-preseed-standard.iso:	debian_preseed/standard.preseed debian_preseed/Dockerfile debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso
	bash scripts/create_iso.sh "debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso" debian-preseed-standard.iso debian_preseed/standard.preseed

debian-preseed-server.iso:	debian_preseed/server.preseed debian_preseed/Dockerfile debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso
	bash scripts/create_iso.sh "debian-$(DEBIAN_NET_INST_VER)-amd64-netinst.iso" debian-preseed-server.iso debian_preseed/server.preseed

test_iso:
	bash scripts/test_iso.sh

test_ansible:
	bash scripts/test_ansible.sh

.PHONY: clean test_iso test_ansible
