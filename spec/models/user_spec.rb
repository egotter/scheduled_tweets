require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validation' do
    it do
      expect(User.new(uid: nil, screen_name: nil).valid?).to be_falsey
      expect(User.new(uid: nil, screen_name: 'name').valid?).to be_falsey
      expect(User.new(uid: 1, screen_name: nil).valid?).to be_falsey
      expect(User.new(uid: 1, screen_name: 'name').valid?).to be_truthy
    end
  end
end
