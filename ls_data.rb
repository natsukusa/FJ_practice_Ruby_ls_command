module Ls
  require 'etc'

  module Argv
    @path = []
    @name = []
    @option = {}
    class << self
      attr_accessor :path, :name, :option

      def name?
        Argv.name.size.positive?
      end

      def path?
        Argv.path.size.positive?
      end
    end
  end

  class WithListOption

    def self.setup
      if Argv.name?
        file_details = make_instans(sort_and_reverse(Argv.name))
        file_details.each { |file_data| file_data.apend_info(file_data) }
        file_details.each { |file_data| ConsoleView.new.print_detail(file_data) }
      end
    
      Argv.path? ? dir_paths = Argv.path.sort : dir_paths = [Dir.pwd]
      dir_paths.each do |path|
        @file_details = make_instans(sort_and_reverse(make_file_name_list(path)))
        @file_details.each { |file_data| file_data.apend_info(file_data) }

        puts
        puts "#{path}:" if Argv.path?
        puts "total: #{block_sum}"

        @file_details.each do |file_data|
          ConsoleView.new.print_detail(file_data)
        end
      end
    end

    def self.make_instans(file_names)
      file_names.map { |file| FileData.new(file) }
    end

    def self.make_file_name_list(path)
      Dir.chdir(path)
      look_up_dir
    end

    def self.block_sum
      @file_details.inject(0) { |result, file_data| result + file_data.blocks }
    end

    def self.sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end

    def self.look_up_dir
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end
  end

  class NonListOption
    def self.setup
      if Argv.name?
        file_names = Argv.name
        ConsoleView.new.display_file_name_list(sort_and_reverse(file_names))
      end
      if Argv.path?
        dir_paths = Argv.path
        final_name_list(dir_paths.sort!)
      end
        normal_name_list if Argv.name.size.zero? && Argv.path.size.zero?
    end

    def self.normal_name_list
      Dir.chdir(Dir.pwd)
      ConsoleView.new.display_file_name_list(sort_and_reverse(look_up_dir))
    end

    def self.final_name_list(dir_paths)
      dir_paths.each do |path|
        puts
        puts "#{path}:"
        Dir.chdir(path)
        ConsoleView.new.display_file_name_list(sort_and_reverse(look_up_dir))
      end
    end

    def self.look_up_dir
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end

    def self.sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end
  end

  class FileData
    attr_accessor :file, :ftype, :mode, :nlink,
                  :owner, :group, :size, :mtime, :blocks
    
    def initialize(file)
      @file = file
    end

    def apend_info(file_data)
      file_data.fill_ftype(file_data)
      file_data.fill_mode(file_data)
      @nlink = File.lstat(file_data.file).nlink.to_s
      @owner = Etc.getpwuid(File.lstat(file_data.file).uid).name
      @group = Etc.getgrgid(File.lstat(file_data.file).gid).name
      @size = File.lstat(file_data.file).size
      @mtime = File.lstat(file_data.file).mtime.strftime("%_m %_d %H:%M")
      @blocks = File.lstat(file_data.file).blocks.to_i
    end


    def instans_to_h
      # TODO オブジェクトの変数をハッシュで格納する。
      { ftype: @ftype, mode: @mode, nlink: @nlink, owner: @owner,
        group: @group, size: @size, mtime: @mtime, file: @file }
    end

    def fill_ftype(file_data)
      hash = { 'blockSpecial' => 'b', 'characterSpecial' => 'c',
               'directory' => 'd', 'link' => 'l', 'socket' => 's',
               'fifo' => 'p', 'file' => '-' }
      @ftype = File.ftype(file_data.file).gsub(/[a-z]+/, hash)
    end

    def fill_mode(file_data)
      mode = File.lstat(file_data.file).mode.to_s(8)[-3..-1]
      @mode = change_mode_style(mode).join
    end

    def change_mode_style(mode)
      mode.split(//).map do |value|
        ('%03d' % value.to_i.to_s(2)).gsub(/^1/, 'r').gsub(/1$/, 'x')
        .gsub(/1/, 'w').gsub(/0/, '-')
      end
    end

  end
end
