require 'front_matter_parser'
require 'yaml'
require 'will_paginate/array'

class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  # GET /pages
  # GET /pages.json
  def index
    @pages = Page.paginate(:page => params[:page]).order('created_at DESC')
  end

  def show
  end

  def new
  end

  def edit
    @page = Page.find(page_params[:file])
  end

  def create
    @page = Page.new()
    @page.title = page_params[:title]
    @page.slug = page_params[:slug]
    @page.content = page_params[:pages][:content]
    if @page.save
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
      redirect_to pages_url
    else
      flash[:error] = "Something went wrong - try again"
      redirect_to posts_new_url
    end

  end
  def write
    @page = Page.find(page_params[:id])
    @page[:title] = page_params[:title]
    @page[:slug] = page_params[:slug]
    @page[:content] = page_params[:pages][:content]
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
    redirect_to pages_path
  end

  def destroy
    @page = Page.find(page_params[:id])

    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      # Make sure we're up to date
      system('git fetch --all')
      system('git reset --hard origin/master')
      system('rm ./content/' + @page.slug + '.md')
      system('git add -A')
      system('git commit -m "Commit from SSDP LABS - destroy a page"')
      system('git push');
    end
    @page.destroy
    redirect_to pages_url
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_page
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def page_params
    params.permit(:file, :content, :title, :slug, :category, :id, pages: [:content])
  end
end
