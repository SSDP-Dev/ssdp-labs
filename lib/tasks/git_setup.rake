desc "Clone into the correct git repo for whichever site we're going to manage"
task :git_setup do
  system('rm -rf lib/assets/managed_site')
  exec('git clone git@github.com:SSDP-Dev/website-rebuild.git lib/assets/managed_site')
end
