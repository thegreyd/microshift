ARG BASE_IMAGE_URL
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_URL}:${BASE_IMAGE_TAG}

# Start Konflux-specific steps
RUN mkdir -p /tmp/yum_temp; mv /etc/yum.repos.d/*.repo /tmp/yum_temp/ || true
COPY .oit/unsigned.repo /etc/yum.repos.d/
ADD https://certs.corp.redhat.com/certs/Current-IT-Root-CAs.pem /tmp
# End Konflux-specific steps
ENV __doozer=update BUILD_RELEASE=202409050953.p0.g1c4e745.assembly.microshift.el9 BUILD_VERSION=v4.18.0 OS_GIT_MAJOR=4 OS_GIT_MINOR=18 OS_GIT_PATCH=0 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=4.18.0-202409050953.p0.g1c4e745.assembly.microshift.el9 SOURCE_GIT_TREE_STATE=clean __doozer_group=openshift-4.18 __doozer_key=microshift-bootc __doozer_version=v4.18.0 
ENV __doozer=merge OS_GIT_COMMIT=1c4e745 OS_GIT_VERSION=4.18.0-202409050953.p0.g1c4e745.assembly.microshift.el9-1c4e745 SOURCE_DATE_EPOCH=1725481003 SOURCE_GIT_COMMIT=1c4e74586569e54f0169337feec6c010ec084be6 SOURCE_GIT_TAG=4.18.0-ec.0-202409020818.p0-14-g1c4e74586 SOURCE_GIT_URL=https://github.com/thegreyd/microshift 

RUN mv /etc/selinux /etc/selinux.tmp && \
    dnf upgrade -y && \
    dnf install -y firewalld microshift && \
    systemctl enable microshift && \
    dnf clean all && \
    mv /etc/selinux.tmp /etc/selinux

# Mandatory firewall configuration
RUN firewall-offline-cmd --zone=public --add-port=22/tcp && \
    firewall-offline-cmd --zone=trusted --add-source=10.42.0.0/16 && \
    firewall-offline-cmd --zone=trusted --add-source=169.254.169.1

# Create a systemd unit to recursively make the root filesystem subtree
# shared as required by OVN images
COPY ./systemd/microshift-make-rshared.service /etc/systemd/system/microshift-make-rshared.service
RUN systemctl enable microshift-make-rshared.service

# Start Konflux-specific steps
RUN cp /tmp/yum_temp/* /etc/yum.repos.d/ || true
# End Konflux-specific steps

LABEL \
        name="openshift/microshift-bootc" \
        com.redhat.component="microshift-bootc-container" \
        io.openshift.maintainer.project="OCPBUGS" \
        io.openshift.maintainer.component="Unknown" \
        version="v4.18.0" \
        release="202409050953.p0.g1c4e745.assembly.microshift.el9" \
        io.openshift.build.commit.id="1c4e74586569e54f0169337feec6c010ec084be6" \
        io.openshift.build.source-location="https://github.com/thegreyd/microshift" \
        io.openshift.build.commit.url="https://github.com/thegreyd/microshift/commit/1c4e74586569e54f0169337feec6c010ec084be6"

