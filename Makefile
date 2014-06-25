
bundle:
	/usr/bin/bundle install --without test --path vendor/bundle --binstubs bin/ --deployment
	(cd vendor/bundle/ruby/ && find . -type f -exec grep -l '/usr/bin/ruby' {} \; | xargs sed -i -e 's|/usr/bin/ruby|/usr/bin/ruby|') || true

distclean: clean
	rm -rf vendor/bundle

# this is needed to package v8 for fedora 18, using the system v8
bundle-config:
	bundle config build.libv8 --with-system-v8

# cleanup misc files that bloat things up
clean:
	rm -f log/development.log
	rm -f log/test.log
	rm -rf tmp/cache/*
	rm -rf tmp/lm*
	rm -rf tmp/server*
	rm -rf tmp/smb*
	rm -rf tmp/key*
	rm -rf tmp/capybara
	rm -rf public/assets

# install necessary packages (FIXME: this is for fedora 18 only so far)
devel-rpms:
	sudo yum -y install git rpm-build ruby ruby-devel gcc gcc-c++ mysql mysql-devel \
		libxml2-devel libxslt-devel sqlite sqlite-devel v8 v8-devel rubygem-bundler

run-tests:
	bundle exec rake db:test:prepare
	bundle exec rspec spec
