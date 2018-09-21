require 'front_matter_parser'
require 'yaml'
require 'will_paginate/array'

class PagesController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @pages = Page.paginate(:page => params[:page]).order('created_at DESC')
  end

  def show
  end

  def new
  end

  def edit
    @file = page_params[:file]
    @parsed_file = FrontMatterParser::Parser.parse_file('./lib/assets/managed_site/content/' + page_params[:file])
    @front_matter = @parsed_file.front_matter #=> {'title' => 'Hello World', 'category' => 'Greetings'}
    @content = @parsed_file.content #=> 'Some actual content'
  end

  def write
    @page = Page.new()
    @page.title = page_params[:title]
    @page.title = page_params[:slug]
    @page.content = page_params[:pages][:content]
    @page.save
    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      # Make sure we're up to date
      system('git fetch --all')
      system('git reset --hard origin/master')
      # Add files
      open('./content/' + page_params[:slug] + '.md', 'w'){|f|
        f << @page.content
      }
      system('git add -A')
      system('git commit -m "Commit from SSDP LABS - writing a page"')
      system('git push');
    end
  end

  def destroy
    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      # Make sure we're up to date
      system('git fetch --all')
      system('git reset --hard origin/master')
      system('rm ./content/' + page_params[:file])
      system('git add -A')
      system('git commit -m "Commit from SSDP LABS - destroy a page"')
      system('git push');
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def page_params
    params.permit(:file, :content, :title, :slug, :category, pages: [:content])
  end
end
