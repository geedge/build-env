FROM quay.io/rockylinux/rockylinux:9.4

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' -i /etc/yum.repos.d/rocky-*.repo  && \
    dnf install -y dnf-plugins-core && \
    dnf install -y epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf install -y gcc gcc-c++ make epel-release patch wget socat automake autoconf libtool rpm-build git yum-utils libpcap-devel && \
    dnf install -y cmake python3-pip sudo && \
    dnf --enablerepo=devel install -y cppcheck && \
    dnf -y install pbzip2 buildah podman qemu-img qemu-kvm telnet net-tools procps-ng httpd libcurl-devel python3-devel openssl-devel && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip && \
    python3 -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    python3 -m pip install ansible j2cli j2cli[yaml] httpie pycurl

COPY rpm_upload_tools.py /root/rpm_upload_tools.py
COPY file_upload_tools_to_share_repo.py /root/file_upload_tools_to_share_repo.py
COPY netrc.conf /root/.netrc
COPY helm-v3.13.3-linux-arm64 /usr/local/bin/helm
COPY geedge.repo /etc/yum.repos.d/
RUN chmod 0755 /usr/local/bin/helm

CMD [ "/bin/bash" ]
