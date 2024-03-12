require 'rails_helper'

RSpec.describe Annotator, type: :model do
  let(:annotator) { build :annotator }
  subject { annotator }

  it "should be valid" do
    is_expected.to be_valid
  end

  it "username should be present" do
    annotator.username = ' '
    is_expected.to be_invalid
  end

  it "username should be unique" do
    duplicate_annotator = annotator.dup
    duplicate_annotator.save
    is_expected.to be_invalid
  end

  it "screenname should be present" do
    annotator.screenname = ' '
    is_expected.to be_invalid
  end

  it "password should be present" do
    annotator.password = annotator.password_confirmation = ' ' * 6
    is_expected.to be_invalid
  end

  it "password should have a minimum length" do
    annotator.password = annotator.password_confirmation = 'a' * 5
    is_expected.to be_invalid
  end
end
