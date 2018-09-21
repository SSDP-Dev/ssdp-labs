class Post < ApplicationRecord
  validates :title, uniqueness: true
  validates :slug, uniqueness: true

end
