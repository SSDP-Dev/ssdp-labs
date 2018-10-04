desc "Clone into the correct git repo for whichever site we're going to manage"
task :git_setup do
  system('rm -rf ' + Rails.root.to_s + 'lib/assets/managed_site')
  exec('git clone git@github.com:SSDP-Dev/website-rebuild.git ' + Rails.root.to_s + '/lib/assets/managed_site')
end
