#
# IMPORTANT: This file is used in container image build pipelines and it must
# be self-contained. Do not use any external files from the current repository
# because they would not be accessible in the pipelines.
#
ARG BASE_IMAGE_URL
ARG BASE_IMAGE_TAG
FROM registry.redhat.io/rhel9/rhel-bootc:9.4

# Start Konflux-specific steps
RUN mkdir -p /tmp/yum_temp; mv /etc/yum.repos.d/*.repo /tmp/yum_temp/ || true
COPY .oit/unsigned.repo /etc/yum.repos.d/
ADD https://certs.corp.redhat.com/certs/Current-IT-Root-CAs.pem /tmp
# End Konflux-specific steps
ENV __doozer=update BUILD_RELEASE=202409100953.p0.gcf43442.assembly.microshift.el9 BUILD_VERSION=v4.18.0 OS_GIT_MAJOR=4 OS_GIT_MINOR=18 OS_GIT_PATCH=0 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=4.18.0-202409100953.p0.gcf43442.assembly.microshift.el9 SOURCE_GIT_TREE_STATE=clean __doozer_group=openshift-4.18 __doozer_key=microshift-bootc __doozer_version=v4.18.0 
ENV __doozer=merge OS_GIT_COMMIT=cf43442 OS_GIT_VERSION=4.18.0-202409100953.p0.gcf43442.assembly.microshift.el9-cf43442 SOURCE_DATE_EPOCH=1725982354 SOURCE_GIT_COMMIT=cf434420ec0c906159f3593053f6f3bf35ccc8c0 SOURCE_GIT_TAG=4.18.0-ec.0-202409020818.p0-29-gcf434420e SOURCE_GIT_URL=https://github.com/thegreyd/microshift 

RUN mv /etc/selinux /etc/selinux.tmp && dnf upgrade -y && \
    dnf install -y firewalld microshift && \
    systemctl enable microshift && \
    dnf clean all

# Mandatory firewall configuration
RUN firewall-offline-cmd --zone=public --add-port=22/tcp && \
    firewall-offline-cmd --zone=trusted --add-source=10.42.0.0/16 && \
    firewall-offline-cmd --zone=trusted --add-source=169.254.169.1

# Create a systemd unit to recursively make the root filesystem subtree
# shared as required by OVN images.
RUN printf '[Unit]\n\
Description=Make root filesystem shared\n\
Before=microshift.service\n\
ConditionVirtualization=container\n\
[Service]\n\
Type=oneshot\n\
ExecStart=/usr/bin/mount --make-rshared /\n\
[Install]\n\
WantedBy=multi-user.target\n' > /etc/systemd/system/microshift-make-rshared.service && \
    systemctl enable microshift-make-rshared.service

# Start Konflux-specific steps
RUN cp /tmp/yum_temp/* /etc/yum.repos.d/ || true
# End Konflux-specific steps

LABEL \
        name="openshift/microshift-bootc" \
        com.redhat.component="microshift-bootc-container" \
        io.openshift.maintainer.project="OCPBUGS" \
        io.openshift.maintainer.component="Unknown" \
        version="v4.18.0" \
        release="202409100953.p0.gcf43442.assembly.microshift.el9" \
        io.openshift.build.commit.id="cf434420ec0c906159f3593053f6f3bf35ccc8c0" \
        io.openshift.build.source-location="https://github.com/thegreyd/microshift" \
        io.openshift.build.commit.url="https://github.com/thegreyd/microshift/commit/cf434420ec0c906159f3593053f6f3bf35ccc8c0"

