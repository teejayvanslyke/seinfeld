require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'fileutils'

describe Seinfeld::Application do
  def test_seinfile_path
    File.dirname(__FILE__) + '/test-seinfile'
  end

  before { ENV['SEINFILE'] = test_seinfile_path }
  after  { ENV['SEINFILE'] = nil }

  subject { Seinfeld::Application.new }
  describe "do" do
    before do
      subject.do 'yoga'
    end

    its(:habits) { should have(1).item }
  end
end

describe Seinfeld::Habit do
  before { @habit = Seinfeld::Habit.new(id: 'yoga') }
  subject { @habit }
  its(:day_count) { should == 0 }

  describe "#increment!" do
    before { @habit.increment! }
    subject { @habit }
    its(:day_count) { should == 1 }
    its(:entries) { should have(1).item }
    describe "first entry" do
      subject { @habit.entries.first }
      its(:date) { should == Date.today }
    end

    describe "adding two entries for the same day" do
      before { @habit.increment! }
      subject { @habit }
      its(:day_count) { should == 1 }
      its(:entries) { should have(1).item }
    end
  end
end

describe "persistence" do

  def test_seinfile_path
    File.dirname(__FILE__) + '/test-seinfile'
  end

  before do
    @app = Seinfeld::Application.new
    @app.do 'yoga'
  end

  after do
    FileUtils.rm test_seinfile_path
  end

  it "should persist the data when reinstantiating with the same file" do
    new_app = Seinfeld::Application.new

    new_app.habits['yoga'].id.should == "yoga"
  end
end
