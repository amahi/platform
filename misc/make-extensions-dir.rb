# for testing the search function in a real hda:
#
# 	define EXT2ICON
# 	require 'fileutils'
# 	make_extensions_test_folder
# 	sudo updatedb &
# 	locate extension-test
# 	rm -rf /var/hda/files/docs/extension-test
#
def make_extensions_test_folder
	Dir.chdir(Share.full_path('docs')) do
		FileUtils.mkdir_p "extension-test"
		Dir.chdir "extension-test"
		EXT2ICON.each_pair do |type, regexp|
			all = regexp.split '|'
			all.each { |e| system "touch", "test.#{e}" }
		end
	end
end
