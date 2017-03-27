require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do

  describe '.internal_admin_user' do

    it "creates the internal admin user if it doesn't exist" do
      described_class.destroy_all
      expect(described_class.internal_admin_user).to be_persisted
    end

    it 'finds the internal admin user if it already exists' do
      described_class.destroy_all
      user = described_class.internal_admin_user
      expect(described_class.internal_admin_user).to eq(user)
    end

  end

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
