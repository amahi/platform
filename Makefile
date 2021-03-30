
foreman:
	PORT=3000 bundle exec foreman start -f Procfile.dev

rr:
	bundle exec rails routes > /tmp/rr
	less /tmp/rr

bundle:
	bin/bundle config set deployment 'true'
	bin/bundle config set path 'vendor/bundle'
	bin/bundle config set without 'test'
	bin/bundle install
	(cd vendor/bundle/ruby/ && rm -rf cache) || true
	(cd vendor/bundle/ruby/gems && rm -rf rails-*/guides */spec */doc */doc-api) || true
	(cd vendor/bundle/ruby/gems && rm -rf */test */tests) || true
	(cd vendor/bundle/ruby/ && find . \( -name '*.[coa]' -or -name '*.cc' -or -name '*.md' -or -name '.git' \) -exec rm -rf {} \;) || true

assets:
	RAILS_ENV=production bin/rails assets:precompile

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

# install necessary packages (FIXME: this is for fedora 18 only so far)
devel-rpms:
	sudo dnf -y install git rpm-build ruby ruby-devel gcc gcc-c++ mysql mysql-devel \
		libxml2-devel libxslt-devel sqlite sqlite-devel v8 v8-devel rubygem-bundler

run-tests:
	bin/bundle exec rake db:test:prepare
	bin/bundle exec rspec spec
