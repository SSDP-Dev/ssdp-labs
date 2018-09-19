class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :date
      t.string :date_gmt
      t.string :guid
      t.integer :wpid
      t.string :link
      t.string :modified
      t.string :modified_gmt
      t.string :slug
      t.string :status
      t.string :type
      t.string :password
      t.string :title
      t.text :content
      t.integer :author
      t.text :excerpt
      t.integer :featured_media
      t.string :comment_status
      t.string :ping_status
      t.string :format
      t.boolean :sticky

      t.timestamps
    end
  end
end
