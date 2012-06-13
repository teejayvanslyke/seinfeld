require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'fileutils'

describe Seinfeld::Application do
  def test_seinfile_path
    File.dirname(__FILE__) + '/test-seinfile'
  end

  subject { Seinfeld::Application.new(file: test_seinfile_path) }
  describe "do" do
    before do
      subject.do 'yoga'
    end

    its(:habits) { should have(1).item }
  end
end

describe Seinfeld::Habit do
  subject { Seinfeld::Habit.new(id: 'yoga') }
  its(:day_count) { should equal(1) }
end

describe "persistence" do

  def test_seinfile_path
    File.dirname(__FILE__) + '/test-seinfile'
  end

  before do
    @app = Seinfeld::Application.new(file: test_seinfile_path)
    @app.do 'yoga'
  end

  after do
    FileUtils.rm test_seinfile_path
  end

  it "should persist the data when reinstantiating with the same file" do
    new_app = Seinfeld::Application.new(
      file: test_seinfile_path
    )

    new_app.habits['yoga'].id.should == "yoga"
  end
end
