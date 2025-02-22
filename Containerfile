ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora-ostree-desktops}"
ARG BASE_IMAGE="quay.io/${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.9.7-200.fc40.x86_64}"
ARG IMAGE_REGISTRY=ghcr.io/ublue-os

FROM ghcr.io/ublue-os/config:latest AS config
FROM ghcr.io/ublue-os/main-kernel:${KERNEL_VERSION} AS kernel

FROM scratch AS ctx
COPY / /

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.9.7-200.fc40.x86_64}"

ADD keyboard-layout/etc/xkb /etc/xkb
ADD mousebuttons/usr/lib/udev/hwdb.d/61-kensington-mouse-buttons.hwdb /usr/lib/udev/hwdb.d/61-kensington-mouse-buttons.hwdb

COPY sys_files/usr /usr

RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=bind,from=config,src=/rpms,dst=/tmp/rpms \
    --mount=type=bind,from=kernel,src=/tmp/rpms,dst=/tmp/kernel-rpms \
    rm -f /usr/bin/chsh && \
    rm -f /usr/bin/lchsh && \
    mkdir -p /var/lib/alternatives && \
    /ctx/install.sh && \
    /ctx/post-install.sh && \
    mv /var/lib/alternatives /staged-alternatives && \
    /ctx/cleanup.sh && \
    ostree container commit && \
    mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp
