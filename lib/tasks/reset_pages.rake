require 'net/http'
require 'json'
desc "Add pages into local db from git repo"
task :reset_pages => :environment do
  Page.delete_all
  Dir.chdir('./lib/assets/managed_site') do
    # Pull the repo using fetch/reset
    system('git fetch --all')
    system('git reset --hard origin/master');
    Dir['./content/*.md'].each do |file_name|
      localfile = file_name.split('/')[2]
      slug = localfile.split('.')[0]
      content = File.read(file_name)
      Page.create(:slug => slug, :title => slug, :content => content)
    end
  end
end
