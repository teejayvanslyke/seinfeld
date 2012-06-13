require 'thor'
require 'json'

module Seinfeld

  class Habit
    def initialize(attributes={})
      @attributes = attributes
      @attributes['day_count'] ||= 1
    end

    attr_reader :attributes

    def to_json(options={})
      attributes.to_json
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

    def initialize(options={})
      @file = options[:file] || '~/.seinfile'

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
      @habits[id] = Habit.new(id: id)
      save!
    end

    no_tasks do
      def save!
        File.open(@file, 'w') do |file|
          file.write(JSON.pretty_generate(habits))
        end
      end
    end

  end

end
