#!/bin/bash
docker_configure() { #helpmsg: Basic compatibility for MSYS

	DOCKER_FLAGS=""
	if [ "$(getent group docker)" ]; then
		DOCKER_FLAGS="--group-add $(getent group docker | cut -d: -f3) -v /var/run/docker.sock:/var/run/docker.sock"
	fi
	DOCKER_RUN_CMD="docker run --rm  $DOCKER_FLAGS -u $(id -u):$(id -g)"
	if [ "$OSTYPE" == "msys" ]; then
		DOCKER_RUN_CMD="MSYS_NO_PATHCONV=1 $DOCKER_RUN_CMD"
	fi
	export DOCKER_RUN_CMD
	DOCKER_BUILDKIT=1
	export DOCKER_BUILDKIT
}

docker_setup() { #helpmsg: Setup variables for docker: image, volume, ...
	docker_configure
	# Image and volume names are prefixed by user name
	IMAGE_NAME="${USER}_$1"
	export IMAGE_NAME
	VOLUME_NAME="${USER}_home"
	export VOLUME_NAME
	DOCKERFILE="Dockerfile"
	export DOCKERFILE
	DOCKER_BUILDKIT=1
	export DOCKER_BUILDKIT
	DOCKER_RUN_BASE="$DOCKER_RUN_CMD -v $VOLUME_NAME:/home/$USER -v $(pwd):/mnt --name ${IMAGE_NAME}_container"
	export DOCKER_RUN_BASE
	DOCKER_RUN_I="$DOCKER_RUN_BASE -i $IMAGE_NAME"
	export DOCKER_RUN_I
	DOCKER_RUN_IT="$DOCKER_RUN_BASE -it $IMAGE_NAME"
	export DOCKER_RUN_IT
}

docker_build_image_and_create_volume() { # create the volume for the home user and build the docker image
	docker volume create "$VOLUME_NAME"
	docker build -t "$IMAGE_NAME" . --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" --build-arg USER="$USER"
}

dockerfile_create() { #helpmsg: Start the dockerfile
	cat >$DOCKERFILE <<'EOF'
# Automatically created!
# DO NOT EDIT!
FROM debian:buster-slim
# Configure current user
ARG USER=host_user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $USER
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $USER
RUN mkdir -p /work
RUN chown -R ${USER}.${USER} /work
EOF
}

dockerfile_setup_python() { #helpmsg: Install python3 + pip + setuptools + venv
	cat >>$DOCKERFILE <<'EOF'
# Install the bare minimum to use python
RUN 	apt-get update && \
        apt-get dist-upgrade -y && \
        apt-get install -y --no-install-recommends \
                git \
                make \
                python3-pip \
                python3-setuptools \
                python3-venv \
                python3-wheel && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*
EOF
	if [ -f ./requirements.txt ]; then
		cat <<EOF >>"$DOCKERFILE"
# Copy requirements and install them
COPY ./requirements.txt /
RUN python3 -m pip install -r requirements.txt
EOF
	fi
}

dockerfile_install_ssh() { #helpmsg: Install ssh
	cat >>$DOCKERFILE <<'EOF'
# Install ssh client
RUN 	apt-get update && \
        apt-get dist-upgrade -y && \
        apt-get install -y --no-install-recommends \
                ssh && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*
EOF
}

dockerfile_appimage() {
	cat >>$DOCKERFILE <<'EOF'
# Install base deps
RUN set -ex \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
	git \
	ca-certificates \
	build-essential \
	cmake \
	autoconf \
	automake \
	libtool \
	pkg-config \
	wget \
	xxd \
	desktop-file-utils \
	libglib2.0-dev \
	libcairo2-dev \
	fuse \
	libfuse-dev \
	zsync \
	yasm \
	strace \
	adwaita-icon-theme \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
EOF
	if [ -f AppRun ]; then
		cat >>$DOCKERFILE <<'EOF'
COPY AppRun /work/AppDir/AppRun
RUN set -ex \
    && chmod a+x /work/AppDir/AppRun \
    && wget https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage -P /work \
    && chmod +x /work/appimagetool-x86_64.AppImage
RUN chown -R ${USER}.${USER} /work
EOF
	fi
}

dockerfile_switch_to_user() { #helpmsg: switch to the user in the dockerfile and set workdir
	cat >>$DOCKERFILE <<'EOF'
USER $USER
ENV PATH="/home/${USER}/.local/bin:${PATH}"
WORKDIR /mnt
EOF
}

run_shfmt_and_shellcheck() { #helpmsg: Execute shfmt and shellcheck
	docker_configure
	for helper in *.sh; do
		$DOCKER_RUN_CMD -v "$PWD":/mnt mvdan/shfmt -w /mnt/"$helper"
		$DOCKER_RUN_CMD -e SHELLCHECK_OPTS="" -v "$PWD":/mnt koalaman/shellcheck:stable -x "$helper"
	done
}
