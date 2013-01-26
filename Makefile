
bundle:
	bundle install --without test --path vendor/bundle --binstubs bin/ --deployment
	#(cd vendor/bundle/ruby/1.9.1/gems/unicorn-*; find . -type f -exec grep -l '/this/will/be/overwritten/or/wrapped/anyways/do/not/worry/ruby' {} \; |      xargs sed -i -e 's|/this/will/be/overwritten/or/wrapped/anyways/do/not/worry/ruby|/usr/bin/ruby|') || true

# install necessary packages (FIXME: this is for fedora 18 only so far)
necessary-packages:
	sudo yum -y install git rpm-build ruby ruby-devel gcc gcc-c++ mysql mysql-devel
