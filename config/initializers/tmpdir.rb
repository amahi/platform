# temp dir for our own use
if Rails.env != "production"
	# used in development
	HDA_TMP_DIR = File.join(Rails.root, 'tmp/cache/tmpfiles')
else
	HDA_TMP_DIR = '/var/hda/tmp'
end

FileUtils.mkdir_p(HDA_TMP_DIR)