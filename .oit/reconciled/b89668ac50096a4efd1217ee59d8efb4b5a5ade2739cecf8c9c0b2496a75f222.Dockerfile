ARG BASE_IMAGE_URL
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_URL}:${BASE_IMAGE_TAG}

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
