FROM rockylinux:8.9
COPY rpm_upload_tools.py /root/rpm_upload_tools.py
COPY file_upload_tools.py /root/file_upload_tools.py
COPY file_upload_tools_to_share_repo.py /root/file_upload_tools_to_share_repo.py
COPY netrc.conf /root/.netrc

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' -i /etc/yum.repos.d/Rocky-*.repo  && \
    dnf install -y dnf-plugins-core && \
    dnf install -y epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y gcc gcc-c++ make epel-release patch wget socat automake autoconf libtool rpm-build git yum-utils libpcap-devel && \
    dnf install -y cmake python3-pip sudo && \
    dnf --enablerepo=devel install -y cppcheck && \
    python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install httpie && \
    yum clean all && \
    rm -rf /var/cache/yum
CMD [ "/bin/bash" ]
