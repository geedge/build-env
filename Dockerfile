FROM centos:7

RUN yum install -y gcc gcc-c++ make libpcap-devel epel-release patch wget socat automake autoconf rpm-build git && \
    wget https://repos.fedorapeople.org/repos/pulp/pulp/rhel-pulp.repo -O /etc/yum.repos.d/rhel-pulp.repo && \
    yum install -y pulp-consumer-client pulp-rpm-consumer-extensions pulp-puppet-consumer-extensions pulp-agent && \
    yum install -y pulp-rpm-handlers pulp-rpm-yumplugins pulp-puppet-handlers python-gofer-qpid && \
    yum install -y pulp-admin-client pulp-rpm-admin-extensions pulp-puppet-admin-extensions pulp-docker-admin-extensions && \
    yum install -y python-pip && \
    pip install -i https://mirrors.aliyun.com/pypi/simple/ --no-cache-dir cmake && \
    curl -sL https://sentry.io/get-cli/ | bash && \
    yum clean all && \
    rm -rf /var/cache/yum

ADD repo.mesalab.cn.conf /etc/pulp/consumer/conf.d/repo.mesalab.cn.conf
ADD repo.mesalab.cn.conf /etc/pulp/admin/conf.d/repo.mesalab.cn.conf
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]