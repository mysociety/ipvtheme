# -*- encoding : utf-8 -*-
class IpvthemeAddAddressAndDobToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :address, :string
    add_column :users, :dob, :date
  end

  def self.down
    remove_column :users, :dob
    remove_column :users, :address
  end
end
