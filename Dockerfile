FROM fedora

RUN mkdir /amahi
WORKDIR /amahi

# Install ruby and all dependencies of rails
RUN dnf -y install ruby-devel-2.3.1 mysql mysql-devel git && dnf clean all
RUN dnf -y install zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel redhat-rpm-config && dnf clean all

# Gemrc file to ignore documentation installation
ADD .gemrc /amahi/.gemrc

# Install bundler and rails
RUN gem install bundler --no-ri --no-rdoc
RUN gem install rails -v 4.2.8 --no-ri --no-rdoc

# Installs hda-ctl. Comment out of not needed
#RUN rpm -Uvh http://f23.amahi.org/noarch/hda-release-6.9.0-1.noarch.rpm && dnf -y install hda-ctl && dnf clean all
