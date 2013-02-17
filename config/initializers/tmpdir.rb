if File.exists?('/var/hda/tmp')
	# temp dir for our own use -- in F18, /tmp is "chrooted" for apache for security
	TMPDIR = '/var/hda/tmp'
else
	TMPDIR = File.join(Rails.root, 'tmp')
end
