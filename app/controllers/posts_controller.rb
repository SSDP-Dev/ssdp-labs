require 'front_matter_parser'
require 'yaml'
require 'will_paginate/array'
require 'toml-rb'
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @files = Post.paginate(:page => params[:page])
  end

  def show
  end

  def new
  end

  def edit
    lines = File.read('./lib/assets/managed_site/content/blog/' + post_params[:file])
    @file = post_params[:file]
    @front_matter = TomlRB.parse(lines.split("+++")[1])
    @content = lines.split("+++")[2]
  end

  def write
    @title = post_params[:title]
    @content = post_params[:posts][:content]

    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      # Make sure we're up to date
      system('git fetch --all')
      system('git reset --hard origin/master')
      # Add files
      open('./content/blog/' + post_params[:slug] + '.md', 'w'){|f|
        f.puts "+++"
        f.puts ""
        f.puts "+++"
        f << @content
      }
      system('git add -A')
      system('git commit -m "Commit from SSDP LABS - writing a post"')
      system('git push');
    end
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
    params.permit(:id, :file, :content, :title, :category, :slug, posts: [:content, :slug])
  end
end
