FROM rockylinux/rockylinux:8.4

COPY debug_tools/vtysh /tmp/vtysh
COPY debug_tools/maat_redis_tool /tmp/maat_redis_tool
COPY netrc.conf /root/.netrc
COPY el8.repo.internal.geedge.net.repo /tmp/repo.internal.geedge.net.repo
COPY telegraf-1.25.0-1.x86_64.rpm /tmp/telegraf-1.25.0-1.x86_64.rpm

RUN cp /tmp/repo.internal.geedge.net.repo /etc/yum.repos.d/ && \
    yum install -y wget && \
    yum install -y yum-utils && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-archive-8.repo && \
    sed -i 's/epel-archive/epel/g' /etc/yum.repos.d/epel.repo && \
    yum-config-manager --enable powertools && \
    # dev tools
    yum install -y nc && \
    yum install -y jq && \
    yum install -y git && \
    yum install -y vim && \
    yum install -y gdb && \
    yum install -y gcc && \
    yum install -y gcc-c++ && \
    yum install -y sudo && \
    yum install -y tree && \
    yum install -y fish && \
    yum install -y htop && \
    yum install -y make && \
    yum install -y clang && \
    yum install -y iftop && \
    yum install -y patch && \
    yum install -y socat && \
    yum install -y cmake3 && \
    yum install -y bpftool && \
    yum install -y libtool && \
    yum install -y cppcheck && \
    yum install -y tcpdump && \
    yum install -y iptables && \
    yum install -y valgrind && \
    yum install -y automake && \
    yum install -y autoconf && \
    yum install -y net-tools && \
    yum install -y rpm-build && \
    yum install -y python2 && \
    yum install -y python3-pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple httpie tomlq && \
    yum install -y scapy && \
    # depend lib
    rpm -ivh --prefix=/opt/telegraf/ /tmp/telegraf-1.25.0-1.x86_64.rpm && \
    yum install -y libasan && \
    yum install -y zlib-devel && \
    yum install -y brotli-devel && \
    yum install -y numactl-devel && \
    yum install -y systemd-devel && \
    yum install -y elfutils-libelf-devel && \
    dnf --enablerepo=powertools install -y llvm && \
    dnf --enablerepo=powertools install -y glibc-devel && \
    dnf --enablerepo=powertools install -y libbpf-devel && \
    dnf --enablerepo=powertools install -y libmnl-devel && \
    dnf --enablerepo=powertools install -y libpcap-devel && \
    dnf --enablerepo=powertools install -y liburing-devel && \
    dnf --enablerepo=powertools install -y libnfnetlink-devel && \
    # depend lib
    yum install -y bfdd && \
    yum install -y mrzcpd-corei7 && \
    yum install -y sapp-devel && \
    yum install -y libelua-devel && \
    yum install -y libcjson-devel && \
    yum install -y libWiredLB-devel && \
    yum install -y librdkafka-1.2.2.1218b3c && \
    yum install -y librdkafka-devel-1.2.2.1218b3c && \
    yum install -y libmaatframe-devel && \
    yum install -y librulescan-devel && \
    yum install -y libwiredcfg-devel && \
    yum install -y libmaatframe-devel && \
    yum install -y libMESA_htable-devel && \
    yum install -y libbreakpad_mini-devel && \
    yum install -y libMESA_prof_load-devel && \
    yum install -y libMESA_field_stat2-devel && \
    yum install -y libfieldstat3-devel && \
    yum install -y libfieldstat4-devel && \
    yum install -y libMESA_handle_logger-devel && \
    cp /tmp/maat_redis_tool /usr/bin/ && \
    cp /tmp/vtysh /usr/bin/ && \
    # clean
    yum clean all && \
    rm -rf /var/cache/yum

CMD [ "/bin/bash" ]