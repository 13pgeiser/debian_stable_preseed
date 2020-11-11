all: export MSYS_NO_PATHCONV = 1
all:
	for helper in *.sh; do docker run --rm -u `id -u`:`id -g` -v "$(shell pwd)":/mnt mvdan/shfmt -w /mnt/"$$helper";done
	for helper in *.sh; do docker run --rm -u `id -u`:`id -g` -v "$(shell pwd)":/mnt mvdan/shfmt -w /mnt/"$$helper";done
	bash ./helpers.sh || true
