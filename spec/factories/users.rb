# -*- encoding : utf-8 -*-
FactoryGirl.modify do

  factory :user do
    dob '2015/04/30'
    address <<-EOF.strip_heredoc
    The Street,
    The City,
    123403
    EOF
  end

end
