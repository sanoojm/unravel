#!/bin/bash

# Disable SeLinux
disable_selinux() {
    setenforce Permissive
    sed -ie 's/^SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
}

# Install Amazon SSM Agent
install_ssm() {
    yum install -y https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/linux_amd64/amazon-ssm-agent.rpm
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
}

# Installing Unravel
install_unravel() {
    curl -v https://preview.unraveldata.com/unravel/RPM/${url_version}/unravel-${version}-cloud.rpm -o /tmp/unravel-${version}-cloud.rpm -u ${username}:${password}
    INSTALL_DIR="/usr/local/unravel"
    mkdir -p $INSTALL_DIR
    rpm -ivh /tmp/unravel-${version}-cloud.rpm
}

# Installing Unravel Dependencies
install_deps() {
    useradd hadoop
    yum install -y  libaio.x86_64 lzop.x86_64 ntp.x86_64
    service ntpd start
    ntpq -p
}

# Configuring Unravel Server
configure_unravel() {
    $INSTALL_DIR/unravel/versions/${version}/setup --enable-emr

    $INSTALL_DIR/unravel/manager configure properties set com.unraveldata.process.event.log false

    $INSTALL_DIR/unravel/manager config apply

    $INSTALL_DIR/unravel/manager start

    $INSTALL_DIR/unravel/manager report
}

install_ssm
disable_selinux
install_deps
install_unravel
configure_unravel
