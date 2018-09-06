require 'front_matter_parser'
require 'yaml'
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
    @files = Dir.entries('./lib/assets/managed_site/content/blog')
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
    @file = post_params[:file]
    @parsed_file = FrontMatterParser::Parser.parse_file('./lib/assets/managed_site/content/blog/' + post_params[:file])
    @front_matter = @parsed_file.front_matter #=> {'title' => 'Hello World', 'category' => 'Greetings'}
    @content = @parsed_file.content #=> 'Some actual content'
  end

  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @file = post_params[:file]
    @title = post_params[:title]
    @category = post_params[:category]
    @content = post_params[:Content]
    open('./lib/assets/managed_site/content/blog/' + post_params[:file], 'w'){|f|
      f << "---\n"
      f << "title: " + @title + "\n"
      f << "category: " + @category + "\n"
      f << "---\n"
      f << @content
    }
    Dir.chdir('./lib/assets/managed_site') do
      # Pull the repo using fetch/reset
      # Make sure we're up to date
      system('git fetch --all')
      system('git reset --hard origin/master')
      # Add files
      system('git add -A')
      system('git commit -m "Commit from SSDP LABS"')
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
      system('git commit -m "Commit from SSDP LABS"')
      system('git push');
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.permit(:file, :Content, :title, :category)
  end
end
