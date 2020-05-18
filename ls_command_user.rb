module Ls
  load './ls_data.rb'
  load './console_view.rb'

  class LsCommandUser
    attr_accessor :argv_option, :dir_path

    def generate(argv_option, argv)
      argv.each do |value|
        if File.file?(value)
          Argv.name << value
        elsif File.directory?(value)
          Argv.path << value
        else
          warning(value)
          return
        end
      end
      Argv.option = argv_option

      # p Argv.name
      # p Argv.path
      # p Argv.option

      # NonListOption.setup
      WithListOption.setup
    end

    def warning(value)
      puts "ls: #{value}: No such file or directory"
    end

  end


  if $0 == __FILE__
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


