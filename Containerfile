# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/silverblue-main:latest

### MODIFICATIONS

ADD keyboard-layout/etc/xkb /etc/xkb
ADD mousebuttons/usr/lib/udev/hwdb.d/61-kensington-mouse-buttons.hwdb /usr/lib/udev/hwdb.d/61-kensington-mouse-buttons.hwdb

RUN mkdir /nix

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
