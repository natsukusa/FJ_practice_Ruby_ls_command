# frozen_string_literal: true

module Ls
  load './ls_data.rb'
  load './console_view.rb'

  class LsCommandUser
    # attr_accessor :argv_option, :dir_path

    def generate(argv_option, argv)
      argv.each do |value|
        if File.file?(value)
          Argv.name << value
        elsif File.directory?(value)
          Argv.path << value
        else
          warning(value)
        end
      end
      Argv.option = argv_option
      argv_option[:list] ? WithListOption.setup : NonListOption.setup
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

    LsCommandUser.new.generate(option, ARGV)
  end
end
