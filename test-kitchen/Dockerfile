FROM ubuntu:xenial

ENV user=kitchen
ENV VAGRANT_HOME=/home/${user}/.vagrant.d
#ARG gpgKeyServer=hkp://keys.gnupg.net
ARG gpgKeyServer=192.94.109.73


RUN \
    apt update \
    && apt install -y curl ruby-dev ruby-ffi cpp make libvirt-dev \
       bash-completion openssh-client \
    && curl \
       https://raw.githubusercontent.com/MarkBorcherding/test-kitchen-bash-completion/master/kitchen-completion.bash \
       --output /etc/bash_completion.d/kitchen \
    && curl \
       https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.deb \
       --output /tmp/vagrant.deb \
    && dpkg -i /tmp/vagrant.deb \
    && rm -v /tmp/vagrant.deb

RUN useradd --user-group --create-home --uid 1000 ${user};

# Install rvm
RUN su ${user} -c "gpg --keyserver ${gpgKeyServer} --recv-keys 7D2BAF1CF37B13E2069D6956105BD0E739499BDB 409B6B1796C275462A1703113804BB82D39DC0E3" \
    && su -l ${user} -c "curl -sSL https://get.rvm.io | bash -s stable" \
    && su -l ${user} -c 'rvm mount $(which ruby) -n current' \
    && su -l ${user} -c 'rvm use --default ext-current';

# Install vagrant-libvirt
RUN su -l ${user} -c "vagrant plugin install vagrant-libvirt"

# Install test-kitchen
RUN su -l ${user} -c 'gem install test-kitchen kitchen-vagrant kitchen-salt kitchen-ansible kitchen-puppet'

VOLUME ${VAGRANT_HOME}/boxes
VOLUME /home/${user}/project

COPY entrypoint.sh /usr/local/bin/entrypoint

ENTRYPOINT ["/usr/local/bin/entrypoint"]
