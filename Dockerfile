# Using official fedora 29 as base image
FROM fedora:29

RUN mkdir /amahi
WORKDIR /amahi

# Install ruby and all dependencies of rails
RUN dnf -y install ruby-devel mysql mysql-devel git libtool \
  zlib zlib-devel gcc-c++ patch readline readline-devel \
  libyaml-devel libffi-devel openssl-devel make bzip2 curl \
  autoconf automake bison sqlite-devel redhat-rpm-config \
  && dnf clean all

# Gemrc file to ignore documentation installation
COPY .gemrc /amahi/.gemrc

# Install bundler and rails
RUN gem install bundler --no-ri --no-rdoc
RUN gem install rails -v 5.2.0 --no-ri --no-rdoc

# Installs hda-ctl. Comment out if not needed.
# RUN rpm -Uvh http://f29.amahi.org/noarch/hda-release-12.0.0-1.noarch.rpm && dnf -y install hda-ctl && dnf clean all
