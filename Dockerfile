FROM ubuntu:20.04

COPY DUE-4.0.1.tar.gz /tmp/DUE-4.0.1.tar.gz

###############################################################################
# Install Tools
###############################################################################
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    apt-get install -y git && \
    apt-get install -y gnupg && \
    apt-get install -y curl && \
    apt-get install -y rsync && \
    apt-get install -y wget && \
    apt-get install -y sudo && \
    apt-get install -y vim && \
    apt-get install -y build-essential

###############################################################################
# Install Docker: https://docs.docker.com/engine/install/debian/
###############################################################################
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null && \
    apt-get update && \
    apt-get install -y docker-ce && \
    apt-get install -y docker-ce-cli && \
    apt-get install -y containerd.io && \
    apt-get install -y docker-buildx-plugin && \
    apt-get install -y docker-compose-plugin

###############################################################################
# Usermod For DUE
###############################################################################
RUN /usr/sbin/usermod -a -G docker root

RUN echo export PATH="/sbin:/usr/sbin:\$PATH" >>.bashrc

CMD ["/bin/bash", "--login"]