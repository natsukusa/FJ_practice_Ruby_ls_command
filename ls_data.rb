module Ls
  require 'etc'

  module Argv
    @path = []
    @name = []
    @option = {}
    class << self
      attr_accessor :path, :name, :option
    end
  end

  class WithListOption
    def self.setup
      if Argv.name.size > 0
        file_details = make_instans(sort_and_reverse(Argv.name))
        file_details.each { |file_data| file_data.apend_info(file_data) }
        file_details.each { |file_data| ConsoleView.new.print_detail(file_data) }
      end
    
      Argv.path.size > 0 ? dir_paths = Argv.path.sort : dir_paths = [Dir.pwd]
      dir_paths.each do |path|
        @file_details = make_instans(sort_and_reverse(make_file_name_list(path)))
        @file_details.each do |file_data|
          file_data.apend_info(file_data)
        end

        puts
        puts "#{path}:" if Argv.path.size > 0
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
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end

    def self.block_sum
      @file_details.inject(0) { |result, file_data| result + file_data.blocks }
    end

    def self.sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end

    def self.get_name_list
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end
  end

  class NonListOption
    def self.setup
      if Argv.name.size > 0
        file_names = Argv.name
        ConsoleView.new.display_file_name_list(sort_and_reverse(file_names))
      end
      if Argv.path.size > 0
        dir_paths = Argv.path
        final_name_list(dir_paths.sort!)
      end
        normal_name_list if Argv.name.size == 0 && Argv.path.size == 0
    end

    def self.normal_name_list
      Dir.chdir(Dir.pwd)
      ConsoleView.new.display_file_name_list(sort_and_reverse(get_name_list))
    end

    def self.final_name_list(dir_paths)
      dir_paths.each do |path|
        puts
        puts "#{path}:"
        Dir.chdir(path)
        ConsoleView.new.display_file_name_list(sort_and_reverse(get_name_list))
      end
    end

    def self.get_name_list
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
      file_data.fill_ftype
      file_data.fill_mode
      file_data.fill_nlink
      file_data.fill_owner
      file_data.fill_group
      file_data.fill_size
      file_data.fill_mtime
      file_data.fill_blocks
    end


    def instans_to_h
      # TODO オブジェクトの変数をハッシュで格納する。
      {ftype: self.ftype, mode: self.mode, nlink: self.nlink,
        owner: self.owner, group: self.group, size: self.size,
        mtime: self.mtime, file: self.file}
    end

    def fill_ftype
      hash = { 'blockSpecial' => 'b', 'characterSpecial' => 'c', 'directory' => 'd',
         'link' => 'l', 'socket' => 's', 'fifo' => 'p', 'file' => '-' }
      self.ftype = File.ftype(self.file).gsub(/[a-z]+/, hash)  
    end

    def fill_mode
      mode = File.lstat(self.file).mode.to_s(8)[-3..-1]
      self.mode = change_mode_style(mode).join
    end
    def change_mode_style(mode)
      mode.split(//).map do |value|
        ('%03d' % value.to_i.to_s(2)).gsub(/^1/, 'r').gsub(/1$/, 'x')
        .gsub(/1/, 'w').gsub(/0/, '-')
      end
    end

    def fill_nlink
      self.nlink = File.lstat(self.file).nlink.to_s
    end
    def fill_owner
      @owner = Etc.getpwuid(File.lstat(self.file).uid).name
    end
    def fill_group
      @group = Etc.getgrgid(File.lstat(self.file).gid).name
    end
    def fill_size
      @size = File.lstat(self.file).size
    end
    def fill_mtime
      @mtime = File.lstat(self.file).mtime.strftime("%_m %_d %H:%M")
    end
    def fill_blocks
      @blocks = File.lstat(self.file).blocks.to_i
    end

  end
end