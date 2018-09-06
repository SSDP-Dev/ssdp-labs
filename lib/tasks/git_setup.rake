desc "Clone into the correct git repo for whichever site we're going to manage"
task :git_setup do
  exec('git clone git@github.com:ogdenstudios/hugo-test-site.git lib/assets/managed_site')
end
