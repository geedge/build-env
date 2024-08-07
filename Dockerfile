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
    yum install -y gcc gcc-c++ make epel-release patch wget socat automake autoconf libtool rpm-build git yum-utils && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-archive-8.repo && \
    sed -i 's/epel-archive/epel/g' /etc/yum.repos.d/epel.repo && \
    yum-config-manager --enable powertools && \
    dnf --enablerepo=powertools install -y libpcap-devel jq wireshark wireshark-cli && \
    yum install -y tcpdump  libibverbs numactl-libs cmake3 && \
    yum install -y python2 && \
    yum install -y python3-pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple httpie && \
    yum install -y sudo && \
    yum install -y elfutils-libelf-devel libmnl-devel libnfnetlink-devel gtest-devel && \
    yum install -y net-tools psmisc iproute initscripts gperftools-libs gdb snappy && \
    yum install -y libunwind gperftools numactl-devel zlib-devel librdkafka-devel systemd-devel jemalloc jemalloc-devel vim-common && \
    dnf --enablerepo=powertools install -y libnsl && \
    dnf install gperftools libasan -y && \
    yum clean all && \
    rm -rf /var/cache/yum

CMD [ "/bin/bash" ]
