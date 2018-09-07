require 'net/http'
require 'json'
desc "Pull all of the WordPress posts from a target site into the managed repo"
task :pull_wp_posts do
  uri = URI("https://ssdp.org/wp-json/wp/v2/posts?per_page=1")
  req = Net::HTTP::Get.new(uri)
  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
    http.request(req)
  }
  response_body_json = JSON.parse(res.body)[0]
  slug = response_body_json["slug"]
  post_path = './lib/assets/managed_site/content/blog/' + slug + '.md'
  response_body_json.each do |key, value|
    open(post_path, 'a') { |f|
      f.puts key.to_s + ": " + value.to_s
    }
  end
end
