# frozen_string_literal: true

module Ls
  load './ls_data.rb'
  load './console_view.rb'

  class User
    # attr_accessor :option, :dir_path

    def generate(option, argv)
      check_argv(argv)
      Argv.option = option
      option[:list] ? WithListOption.setup : NonListOption.setup
    end

    def check_argv(argv)
      argv.each do |value|
        if File.file?(value)
          Argv.files << value
        elsif File.directory?(value)
          Argv.directories << value
        else
          warning(value)
        end
      end
    end

    def warning(value)
      puts "ls: #{value}: No such file or directory"
      exit
    end
  end

  if $PROGRAM_NAME == __FILE__
    require 'optparse'
    opt = OptionParser.new

    option = {}

    opt.on('-a') { |v| option[:all] = v }
    opt.on('-l') { |v| option[:list] = v }
    opt.on('-r') { |v| option[:reverse] = v }

    opt.parse!(ARGV)

    User.new.generate(option, ARGV)
  end
end
