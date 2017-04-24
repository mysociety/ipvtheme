# -*- encoding : utf-8 -*-
# Here you can override or add to the pages in the core website

Rails.application.routes.draw do
  scope '/profile' do
    match '/change_address' => 'user#signchangeaddress',
          :as => :signchangeaddress,
          :via => [:get, :post]
    match '/change_dob' => 'user#signchangedob',
          :as => :signchangedob,
          :via => [:get, :post]
  end
end
