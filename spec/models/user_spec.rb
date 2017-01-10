require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do

  describe :address do

    it 'requires address' do
      user = FactoryGirl.build(:user, :address => nil)
      user.valid?
      expect(user.errors[:address].size).to eq(1)
    end

    it 'is not valid with an address longer than 255 characters' do
      user = FactoryGirl.build(:user, :address => 'x' * 256)
      user.valid?
      expect(user.errors[:address].size).to eq(1)
    end

    it 'is valid with an address' do
      user = FactoryGirl.build(:user, :address => 'The Street, The City, 1234')
      expect(user).to be_valid
    end

  end

  describe :dob do

    it 'requires date of birth' do
      user = FactoryGirl.build(:user, :dob => nil)
      puts user.errors[:dob]
      user.valid?
      expect(user.errors[:dob].size).to eq(1)
    end

    it 'is not valid with an invalid date' do
      user = FactoryGirl.build(:user, :dob => 'notadate')
      user.valid?
      expect(user.errors[:dob].size).to eq(1)
    end

    it 'is valid with a valid date' do
      user = FactoryGirl.build(:user, :dob => '2015/04/30')
      expect(user).to be_valid
    end

  end

end
