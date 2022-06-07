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
COPY cppcheck-2.7-1.el7.x86_64.rpm /tmp/cppcheck-2.7-1.el7.x86_64.rpm
COPY envconfig.cfgx /tmp/envconfig.cfgx

RUN cp /tmp/repo.internal.geedge.net.repo /etc/yum.repos.d/ && \
    yum install -y gcc gcc-c++ make epel-release patch wget socat automake autoconf libtool rpm-build git yum-utils && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum install -y docker-ce && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-archive-8.repo && \
    sed -i 's/epel-archive/epel/g' /etc/yum.repos.d/epel.repo && \
    yum-config-manager --enable powertools && \
    dnf --enablerepo=powertools install -y libpcap-devel && \
    yum install -y cmake3 && \
    yum install -y python2 && \
    yum install -y python3-pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple httpie && \
    curl -sL https://sentry.io/get-cli/ |sed 's#downloads\.sentry-cdn\.com#npm\.taobao\.org\/mirrors#g'|bash && \
    rpm -U /tmp/cppcheck-2.7-1.el7.x86_64.rpm && \
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

    # 为二进制程序加壳示例
    # in: 设置开发商文件
    # in: 设置 feature_id
    # /opt/Sentinel/Linux/VendorTools/Envelope/linuxenv -v:/opt/VendorCodes/GEEDGE.hvc -f:100 --msg-out:4 --debug --memdump --randomize:1 /opt/MESA/bin/minidump-2-core /opt/MESA/bin/minidump-2-core_protected

CMD [ "/bin/bash" ]
