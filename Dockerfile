FROM rockylinux/rockylinux:8.4
COPY rpm_upload_tools.py /root/rpm_upload_tools.py
COPY file_upload_tools.py /root/file_upload_tools.py
COPY file_upload_tools_to_share_repo.py /root/file_upload_tools_to_share_repo.py
COPY el8.repo.internal.geedge.net.repo /tmp/repo.internal.geedge.net.repo
COPY netrc.conf /root/.netrc
COPY Sentinel-LDK-8.0.1.tar.gz /tmp/Sentinel-LDK-8.0.1.tar.gz
COPY GEEDGE.hvc /tmp/GEEDGE.hvc
COPY rebuildrpm_and_envelope.sh /root/rebuildrpm_and_envelope.sh
COPY aksusbd-8.23-1.x86_64.rpm /tmp/aksusbd-8.23-1.x86_64.rpm
COPY envconfig.cfgx /tmp/envconfig.cfgx

RUN cp /tmp/repo.internal.geedge.net.repo /etc/yum.repos.d/ && \
    sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
        -i.bak  \
    /etc/yum.repos.d/Rocky-*.repo && \
    yum install -y gcc gcc-c++ make epel-release patch wget socat automake autoconf libtool rpm-build git yum-utils && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-archive-8.repo && \
    sed -i 's/epel-archive/epel/g' /etc/yum.repos.d/epel.repo && \
    yum-config-manager --enable powertools && \
    dnf --enablerepo=powertools install -y libpcap-devel && \
    yum install -y cmake3 && \
    yum install -y python2 && \
    yum install -y python3-pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple httpie && \
    rpm -U https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/c/cppcheck-2.7-1.el7.x86_64.rpm && \
    yum install -y sudo && \
    mkdir -p /opt/VendorCodes/ && \
    mv /tmp/GEEDGE.hvc /opt/VendorCodes/GEEDGE.hvc && \
    mv /tmp/envconfig.cfgx /opt/VendorCodes/envconfig.cfgx && \
    mkdir -p /opt/Sentinel/ && \
    tar xf /tmp/Sentinel-LDK-8.0.1.tar.gz -C /opt/Sentinel/ && \
    yum localinstall -y /tmp/aksusbd-8.23-1.x86_64.rpm && \
    chmod o+x /opt/Sentinel/Linux/VendorTools/Envelope/linuxenv && \
    chmod o+x /root/rebuildrpm_and_envelope.sh && \
    yum clean all && \
    rm -rf /var/cache/yum
CMD [ "/bin/bash" ]
