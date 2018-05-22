
# work-around for a permissions issue in bootsnap
# see https://github.com/Shopify/bootsnap/issues/77 for details (it's not fixed, near as we can tell)

cache = File.join(Rails.root, "tmp/cache/bootsnap-compile-cache")
Dir.mkdir(cache, 0777) rescue nil
File.chmod(0777, cache) rescue nil
