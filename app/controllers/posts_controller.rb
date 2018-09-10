require 'front_matter_parser'
require 'yaml'
require 'will_paginate/array'
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    # Change directory to the managed site
    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      system('git fetch --all')
      system('git reset --hard origin/master');
    end
    # We're just interested in the files that exist within the blog directory for the Post controller
    @files = Dir.entries('./lib/assets/managed_site/content/blog').paginate(page: params[:page])
  end

  def show
  end

  def new
  end

  def edit
    @file = post_params[:file]
    @parsed_file = FrontMatterParser::Parser.parse_file('./lib/assets/managed_site/content/blog/' + post_params[:file])
    @front_matter = @parsed_file.front_matter #=> {'title' => 'Hello World', 'category' => 'Greetings'}
    @content = @parsed_file.content #=> 'Some actual content'
  end

  def write
    @file = post_params[:file]
    @title = post_params[:title]
    @category = post_params[:category]
    @content = post_params[:content]

    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      # Make sure we're up to date
      system('git fetch --all')
      system('git reset --hard origin/master')
      # Add files
      open('./content/blog/' + post_params[:file], 'w'){|f|
        f << "---\n"
        f << "title: " + @title + "\n"
        f << "category: " + @category + "\n"
        f << "---\n"
        f << @content
      }
      system('git add -A')
      system('git commit -m "Commit from SSDP LABS - writing a post"')
      system('git push');
    end
  end

  def destroy
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
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.permit(:file, :content, :title, :category)
  end
end
