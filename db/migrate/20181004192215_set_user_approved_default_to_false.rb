class SetUserApprovedDefaultToFalse < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :approved, :boolean, :default => false
  end
end
