FROM centos:7
COPY rpm_upload_tools.py /root/rpm_upload_tools.py
COPY file_upload_tools.py /root/file_upload_tools.py
COPY file_upload_tools_to_share_repo.py /root/file_upload_tools_to_share_repo.py
COPY repo.internal.geedge.net.repo /tmp/repo.internal.geedge.net.repo
COPY CentOS-Base.repo /tmp/CentOS-Base.repo
COPY CentOS-SCLo-scl.repo /tmp/CentOS-SCLo-scl.repo
COPY netrc.conf /root/.netrc
COPY cmake /tmp/build_cmake
COPY tshark/tshark.v3.2.17.el7 /usr/bin/tshark
COPY Sentinel-LDK-8.0.1.tar.gz /tmp/Sentinel-LDK-8.0.1.tar.gz
COPY GEEDGE.hvc /tmp/GEEDGE.hvc
COPY rebuildrpm_and_envelope.sh /root/rebuildrpm_and_envelope.sh
COPY aksusbd-8.23-1.x86_64.rpm /tmp/aksusbd-8.23-1.x86_64.rpm
COPY envconfig.cfgx /tmp/envconfig.cfgx

RUN rm -rf /etc/yum.repos.d/* && \
    chmod +x /usr/bin/tshark && \
    cp /tmp/*.repo /etc/yum.repos.d/ && \
    yum install -y gcc gcc-c++ make libpcap-devel epel-release patch wget socat automake autoconf libtool rpm-build git && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    cd /tmp/build_cmake && \
    tar xf cmake-3.12.4-Linux-x86_64.tar.gz && \
    cp -r cmake-3.12.4-Linux-x86_64/* /usr/local/ && \
    cp /usr/local/bin/cmake /usr/local/bin/cmake3 && \
    yum install -y python3-pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple httpie && \
    yum install -y devtoolset-7 devtoolset-7-libasan-devel && \
    yum install -y libasan libasan4 && \
    yum install -y rpmrebuild && \
    yum install -y cppcheck && \
    yum install -y sudo && \
    yum install -y elfutils-libelf-devel libmnl-devel libnfnetlink-devel gtest-devel && \
    yum install -y net-tools psmisc iproute initscripts gperftools-libs gdb snappy && \
    yum install -y libunwind gperftools numactl-devel zlib-devel librdkafka-devel systemd-devel jemalloc jemalloc-devel vim-common && \
    yum clean all && \
    rm -rf /var/cache/yum

    # 为二进制程序加壳示例
    # in: 设置开发商文件
    # in: 设置 feature_id
    # /opt/Sentinel/Linux/VendorTools/Envelope/linuxenv -v:/opt/VendorCodes/GEEDGE.hvc -f:100 --msg-out:4 --debug --memdump --randomize:1 /opt/MESA/bin/minidump-2-core /opt/MESA/bin/minidump-2-core_protected

CMD [ "/bin/bash" ]
