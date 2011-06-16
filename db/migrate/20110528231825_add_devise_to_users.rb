class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      # t.database_authenticable
      t.string :encrypted_password, :null => false, :default => '', :limit => 128
    end
  end
end
