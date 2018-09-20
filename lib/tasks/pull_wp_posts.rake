require 'net/http'
require 'json'
desc "Pull all of the WordPress posts from a target site into the managed repo"
task :pull_wp_posts => :environment do
  # Clear the posts to avoid any conflicts in case updates were made outside of labs
  Post.delete_all
  Dir.chdir('./lib/assets/managed_site') do
    # Pull the repo using fetch/reset
    system('git fetch --all')
    system('git reset --hard origin/master');
  end
  uri = URI("https://ssdp.org/wp-json/wp/v2/posts")
  req = Net::HTTP::Get.new(uri)
  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
    http.request(req)
  }
  wp_total = res["X-WP-Total"].to_i
  wp_total.times do |i|
    i+= 1
    write_blog_post(i.to_s)
    Post.create(post_params(i.to_s))
    puts "Finished " + i.to_s + " out of " + wp_total.to_s
  end
  Dir.chdir('./lib/assets/managed_site') do
    system('git add -A')
    system('git commit -m "Commit from SSDP LABS - pulling down the WP posts"')
    system('git push');
  end
end

def write_blog_post(page)
  response_body_json = get_wp_data(page)
  slug = response_body_json["slug"]
  type = response_body_json["type"]
  if type == "post"
    post_path = './lib/assets/managed_site/content/blog/' + slug + '.md'
    open(post_path, 'w') { |f|
      f.puts "+++"
    }
    response_body_json.each do |key, value|
      if value
        case key
        when "guid"
          open(post_path, 'a') { |f|
            f.puts key.to_s + ' = """' + value["rendered"].to_s + '"""'
          }
        when "title"
          open(post_path, 'a') { |f|
            f.puts key.to_s + ' = """' + value["rendered"].to_s + '"""'
          }
        when "content"
        when "excerpt"
          open(post_path, 'a') { |f|
            f.puts key.to_s + ' = """' + value["rendered"].to_s + '"""'
          }
        when "_links"
        else
          open(post_path, 'a') { |f|
            f.puts key.to_s + ' = """' + value.to_s + '"""'
          }
        end
      end
    end
    open(post_path, 'a') { |f|
      f.puts "+++"
    }
    open(post_path, 'a') { |f|
      f.puts response_body_json["content"]["rendered"]
    }
  end
end

def post_params(page)
  response_body_json = get_wp_data(page)
  params_hash = { }
  response_body_json.each do |key, value|
    if value
      case key
      when "id"
        params_hash[:wpid] = value.to_i
      when "type"
        params_hash[:post_type] = value
      when "guid"
          params_hash[:guid] = value["rendered"].to_i
      when "title"
        params_hash[:title] = value["rendered"].to_s
      when "excerpt"
        params_hash[:excerpt] = value["rendered"].to_s
      when "author"
        params_hash[:author] = value.to_i
      when "featured_media"
        params_hash[:featured_media] = value.to_i
      when "content"
        params_hash[:content] = value["rendered"].to_s
      when "comment_status"
      when "ping_status"
      when "template"
      when "format"
      when "meta"
      when "categories"
      when "tags"
      when "_links"
      else
        params_hash[key] = value
      end
    end
  end
  return params_hash
end

def get_wp_data(page)
  uri = URI("https://ssdp.org/wp-json/wp/v2/posts?per_page=1&page=" + page)
  req = Net::HTTP::Get.new(uri)
  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
    http.request(req)
  }
  return response_body_json = JSON.parse(res.body)[0]
end
