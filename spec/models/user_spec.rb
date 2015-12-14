require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do

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