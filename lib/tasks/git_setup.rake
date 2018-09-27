desc "Clone into the correct git repo for whichever site we're going to manage"
task :git_setup do
  system('rm -rf lib/assets/managed_site')
  exec('git clone https://' + ENV["GITHUB_USER"] + ':' + ENV["GITHUB_PASSWORD"] + '@github.com/ogdenstudios/website-rebuild.git' + Rails.root.to_s + '/lib/assets/managed_site')
end
