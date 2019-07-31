FROM centos:7
MAINTAINER Gopala Krishnan <gopac25@gmail.com>
RUN yum -y install which git wget unzip python-devel epel-release vim && \
    yum -y groupinstall 'Development Tools' && \
    yum -y install java-1.8.0-openjdk-devel  && \
	curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo && \
	rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key && \
	yum install jenkins && \
	systemctl start jenkins && \
	systemctl enable jenkins && \
	firewall-cmd --permanent --zone=public --add-port=8080/tcp && \
	firewall-cmd --reload && \
    yum install ansible && \
	yum install -y yum-utils device-mapper-persistent-data lvm2 && \
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
	yum install docker-ce && \
	usermod -aG docker jenkins && \
	systemctl enable docker.service && \
	systemctl start docker.service && \
	wget --no-verbose -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python /tmp/get-pip.py && \
	pip install docker-compose && \
	wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip && \
	unzip ./terraform_0.11.13_linux_amd64.zip -d /usr/local/bin/ && \
	yum upgrade python* && \
	chown -c jenkins /var/lib/jenkins && \
    chsh -s /bin/bash jenkins
USER jenkins
ENV USER jenkins
