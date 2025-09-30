ARG MAIN_PACKAGES="coreutils-single libcurl-minimal curl"

ARG NEWROOT=/new-root-fs
ARG DNF_CACHE=/tmp/dnf-cache
ARG DNF_FLAGS="-y --installroot=${NEWROOT} \
      --use-host-config \
      --nodocs \
      --setopt=install_weak_deps=False \
      --setopt=cachedir=${DNF_CACHE} \
      --setopt=system_cachedir=${DNF_CACHE} \
      --setopt=logdir=${DNF_CACHE} \
      --setopt=varsdir=${DNF_CACHE}"

FROM quay.io/rhel-primitives-ci/builder:latest AS builder
ARG NEWROOT
ARG DNF_CACHE
ARG DNF_FLAGS
ARG MAIN_PACKAGES

RUN mkdir -p ${NEWROOT} ${DNF_CACHE}

RUN test -n "${MAIN_PACKAGES}" || (echo ">>>>> MAIN_PACKAGES not set <<<<<" && false)

RUN rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-* --root "${NEWROOT}"

RUN dnf ${DNF_FLAGS} install ${MAIN_PACKAGES}

RUN rm -rf \
      ${NEWROOT}/usr/lib/sysimage \
      ${NEWROOT}/usr/share/licenses


COPY entrypoint.sh ${NEWROOT}/

RUN groupadd -R ${NEWROOT} curl_group && \
    useradd -R ${NEWROOT} -u 65532 -g curl_group curl_user

FROM scratch
ARG NEWROOT
COPY --from=builder ${NEWROOT} /

LABEL maintainer="TODO <todo@redhat.com" \
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"


LABEL summary="Run curl in a container" \
      description="Run and work with curl in a container environment"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["curl"]
WORKDIR /home/curl_user

USER 65532
