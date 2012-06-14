require 'thor'
require 'json'
require 'date'

module Seinfeld

  class Entry
    def initialize(attributes={})
      @attributes = attributes
      @attributes['date'] ||= Date.today
    end

    attr_reader :attributes

    def as_json
      attributes
    end

    def method_missing(name, *args)
      if attributes[name.to_s]
        return attributes[name.to_s]
      else
        super
      end
    end
  end

  class Habit
    def initialize(attributes={})
      @attributes = attributes
      if @attributes['entries']
        @entries = @attributes['entries'].map {|attrs| Entry.new(attrs)}
      else
        @entries = []
      end
    end

    attr_reader :attributes, :entries

    def as_json(options={})
      attributes.merge(
        'entries' => entries.map(&:as_json)
      )
    end

    def has_entry_for_date?(date)
      @entries.any? {|e| e.date == date.to_s }
    end

    def increment!
      unless has_entry_for_date?(Date.today)
        @entries << Entry.new
      end
    end

    def day_count
      @entries.length
    end

    def method_missing(name, *args)
      if attributes[name.to_s]
        return attributes[name.to_s]
      else
        super
      end
    end

  end

  class Application < Thor

    def initialize(*args)
      super *args

      @file = ENV['SEINFILE'] || File.join(ENV['HOME'], '.seinfile')

      if File.exists?(@file)
        data = JSON.parse(File.read(@file))
        @habits = data.inject({}) { |_, a| _.merge(a[0] => Habit.new(a[1])) }
      else
        @habits = {}
      end
    end

    attr_reader :habits

    desc "do", "Increment the day counter for the specified habit"
    def do(id)
      @habits[id] ||= Habit.new(id: id)
      @habits[id].increment!
      save!
      puts "[#{id}] #{@habits[id].day_count} consecutive day(s)."
    end

    desc "list", "List all habits and their current day counts"
    def list
      @habits.each do |id, habit|
        puts "[#{id}] #{habit.day_count} consecutive day(s)."
      end
    end


    no_tasks do
      def save!
        File.open(@file, 'w') do |file|
          file.write(JSON.pretty_generate(habits.inject({}) {|_, a| _.merge(a[0] => a[1].as_json)} ))
        end
      end
    end

  end

end
