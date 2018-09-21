class Page < ApplicationRecord
  validates :title, uniqueness: true
  validates :slug, uniqueness: true

end
