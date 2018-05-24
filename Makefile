
bundle:
	bin/bundle install --without test --path vendor/bundle --binstubs bin/ --deployment
	#(cd vendor/bundle/ruby/ && find . -type f -exec grep -l '/usr/bin/ruby' {} \; | xargs sed -i -e 's|/usr/bin/ruby|/usr/bin/ruby|') || true
	# clean up things that are not needed at run time
	(cd vendor/bundle/ruby/ && rm -rf cache) || true
	(cd vendor/bundle/ruby/gems && rm -rf rails-*/guides */spec */doc */doc-api) || true
	(cd vendor/bundle/ruby/gems && rm -rf */test */tests) || true
	(cd vendor/bundle/ruby/ && find . \( -name '*.[coa]' -or -name '*.cc' -or -name '*.md' -or -name '.git' \) -exec rm -rf {} \;) || true

distclean: clean
	rm -rf vendor/bundle

# this is needed to package v8 for fedora 18, using the system v8
bundle-config:
	bin/bundle config build.libv8 --with-system-v8

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
	sudo dnf -y install git rpm-build ruby ruby-devel gcc gcc-c++ mysql mysql-devel \
		libxml2-devel libxslt-devel sqlite sqlite-devel v8 v8-devel rubygem-bundler

run-tests:
	bin/bundle exec rake db:test:prepare
	bin/bundle exec rspec spec
