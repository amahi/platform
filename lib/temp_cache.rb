
# utilities to manage a temporary cache of downloaded or generated files

class TempCache

	class << self
		# expire files that have not been accessed in a while
		def expire_unused_files
			Dir.glob(File.join(HDA_TMP_DIR, "**/**")) do |f|
				begin
					if File.exists?(f) && File.atime(f) < 3.months.ago
						FileUtils.rm_rf(f)
					end
				rescue
					# ignore errors, because it's theoretically possible that
					# there might be files in-flight and the exists? is true
					# yet the atime fails, or even the rm
				end
			end
		end

		# return a unique name for creating a file
		def unique_filename(base)
			expire_unused_files
			File.join(HDA_TMP_DIR, "#{base}-%d.%d" % [$$, rand(9999)])
		end
	end
end
