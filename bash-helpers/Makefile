all:
	$(MAKE) format
	$(MAKE) check
	$(MAKE) run

.PHONY: check format run

check:
	for helper in *.sh; do docker run --rm -v "$(shell pwd)":/mnt mvdan/shfmt -d /mnt/"$$helper";done
	for helper in *.sh; do docker run --rm -e SHELLCHECK_OPTS="" -v "$(shell pwd)":/mnt koalaman/shellcheck:stable -x "$$helper";done

format:
	for helper in *.sh; do docker run --rm -u `id -u`:`id -g` -v "$(shell pwd)":/mnt mvdan/shfmt -w /mnt/"$$helper";done

run:
	bash ./helpers.sh || true
