# vim:set ft=dockerfile:
include(`debian_base.m4')

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      xorriso	\
      cpio \
      syslinux \
      isolinux \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean
