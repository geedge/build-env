FROM centos:7
COPY rpm_upload_tools.py /root/rpm_upload_tools.py
COPY repo.internal.geedge.net.repo /etc/yum.repos.d/repo.internal.geedge.net.repo
COPY netrc.conf /root/.netrc
COPY cmake /tmp/build_cmake

RUN yum install -y gcc gcc-c++ make libpcap-devel epel-release patch wget socat automake autoconf libtool rpm-build git && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    cd /tmp/build_cmake && \
    tar xf cmake-3.12.4-Linux-x86_64.tar.gz && \
    cp -r cmake-3.12.4-Linux-x86_64/* /usr/local/  && \
    cp /usr/local/bin/cmake /usr/local/bin/cmake3  && \
    yum install -y python3-pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple httpie && \
    curl -sL https://sentry.io/get-cli/ | bash && \
    yum install -y centos-release-scl && \
    yum install -y devtoolset-7 && \
    yum install -y libasan4 && \
    yum clean all && \
    rm -rf /var/cache/yum

SHELL [ "/usr/bin/scl", "enable", "devtoolset-7"]

RUN gcc --version && g++ --version

CMD [ "/bin/bash" ]
