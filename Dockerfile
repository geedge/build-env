FROM centos:7
COPY rpm_upload_tools.py /root/rpm_upload_tools.py
COPY repo.internal.geedge.net.repo /etc/yum.repos.d/repo.internal.geedge.net.repo
COPY netrc.conf /root/.netrc

RUN yum install -y gcc gcc-c++ make libpcap-devel epel-release patch wget socat automake autoconf libtool rpm-build git && \
    yum install -y cmake3 && \
    yum install -y python3-pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple httpie && \
    curl -sL https://sentry.io/get-cli/ | bash && \
    yum clean all && \
    rm -rf /var/cache/yum &&\

CMD [ "/bin/bash" ]
