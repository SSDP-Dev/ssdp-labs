require 'front_matter_parser'
require 'yaml'
require 'will_paginate/array'
require 'toml-rb'
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.paginate(:page => params[:page]).order('date DESC')
  end

  def show
  end

  def new
  end

  def edit
    @post = Post.find(post_params[:file])
  end

  def create
    @post = Post.new(post_params[:posts])
    @post[:date] = DateTime.now.to_date
    if @post.save
      flash[:success] = "Micropost created!"
      redirect_to posts_url
    end
  end

  def write
    @post = Post.find(post_params[:id])
    puts @post.title
    @post[:title] = post_params[:title]
    puts @post.title
    @post[:slug] = post_params[:slug]
    @post[:content] = post_params[:posts][:content]
    puts @post.content
    @post[:status] = post_params[:status]
    @post[:excerpt] = post_params[:excerpt]
    @post.save
    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      # Make sure we're up to date
      system('git fetch --all')
      system('git reset --hard origin/master')
      # Add files
      open('./content/blog/' + post_params[:slug] + '.md', 'w'){|f|
        f.puts "+++"
        @post.attributes.each_pair do |name, value|
          if name == "excerpt"
            f.puts '"' + name + '" = """' + value.to_s + '"""'
          elsif name == "content"
          else
            f.puts '"' + name +  '"="' + value.to_s + '"'
          end
        end
        f.puts "+++"
        f.puts @post[:content]
      }
      system('git add -A')
      system('git commit -m "Commit from SSDP LABS - writing a post"')
      system('git push');
    end
    redirect_to posts_path
  end

  def destroy
    @post = Post.find(post_params[:id])
    @post.destroy
    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      # Make sure we're up to date
      system('git fetch --all')
      system('git reset --hard origin/master')
      system('rm ./content/blog/' + post_params[:file])
      system('git add -A')
      system('git commit -m "Commit from SSDP LABS - destroying a post"')
      system('git push');
    end
    redirect_to posts_path
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.permit(:id, :file, :content, :title, :category, :slug, posts: [:content, :slug, :title, :category])
  end
end
