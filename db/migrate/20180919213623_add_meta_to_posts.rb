class AddMetaToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :date, :string
    add_column :posts, :date_gmt, :string
    add_column :posts, :guid, :integer
    add_column :posts, :wpid, :integer
    add_column :posts, :link, :string
    add_column :posts, :modified, :string
    add_column :posts, :modified_gmt, :string
    add_column :posts, :slug, :string
    add_column :posts, :status, :string
    add_column :posts, :type, :string
    add_column :posts, :password, :string
    add_column :posts, :title, :string
    add_column :posts, :content, :text
    add_column :posts, :author, :integer
    add_column :posts, :excerpt, :text
    add_column :posts, :featured_media, :integer
  end
end
