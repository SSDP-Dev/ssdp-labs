require 'net/http'
require 'json'
desc "Add pages into local db from git repo"
task :reset_pages => :environment do
