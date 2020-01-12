# Path to the common M4 files.
M4_COMMON = `pwd`/_m4
M4 = m4

# Debian buster preseed
BUSTER_NET_INST_VER:=10.2.0
BUSTER_NET_INST_MD5:=36de671429939e90f2a31ce3fbed0aaf

# Include local config if any
#-include ../docker_config.mak

# List of docker images & targets
DOCKERFILES=\
	debian_preseed/Dockerfile \
	debian_preseed/server.preseed \
	debian_preseed/standard.preseed \
	debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso \
	buster-standard.iso \
	buster-server.iso \

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

# Clean everything
mrproper: clean
	docker rmi -f `docker images -q` || true
	docker rm -f `docker ps -a -q` || true
	docker system prune -f -a

debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso:
	if [ "`md5sum debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso | cut -d' ' -f1`" != "$(BUSTER_NET_INST_MD5)" ]; then curl -SL https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso -o debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso; fi
	if [ "`md5sum debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso | cut -d' ' -f1`" != "$(BUSTER_NET_INST_MD5)" ]; then echo "Invalid MD5" ; rm -f debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso ; exit 1 ; fi
	touch $@

buster-standard.iso:	debian_preseed/standard.preseed debian_preseed/Dockerfile debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso
	bash scripts/create_iso.sh "debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso" buster-standard.iso debian_preseed/standard.preseed

buster-server.iso:	debian_preseed/server.preseed debian_preseed/Dockerfile debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso
	bash scripts/create_iso.sh "debian-$(BUSTER_NET_INST_VER)-amd64-netinst.iso" buster-server.iso debian_preseed/server.preseed

