# frozen_string_literal: true

module Ls
  require 'etc'

  module Argv
    @directories = []
    @files = []
    @option = {}
    class << self
      attr_accessor :directories, :files, :option

      def files?
        Argv.files.size.positive?
      end

      def directories?
        Argv.directories.size.positive?
      end

      def both_empty?
        Argv.files.size.zero? && Argv.directories.size.zero?
      end
    end
  end

  class Formatter
    def sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end

    def look_up_dir
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end
  end

  class DetailListFormatter < Formatter
    def setup
      if Argv.files?
        argv_file_on = Directory.new
        argv_file_on.setup(Argv.files)
        puts argv_file_on.finalize
      end

      if Argv.directories?
        directories = Argv.directories.sort
        directories.each do |directory|
          argv_dir_on = Directory.new
          argv_dir_on.setup(directory)
          argv_dir_on.show_directory(directory)
          puts argv_dir_on.finalize
        end
      end

      if Argv.both_empty?
        directory ||= Dir.pwd
        argv_empty_on = Directory.new
        argv_empty_on.setup(directory)
        puts "total #{argv_empty_on.block_sum}" unless Argv.files?
        puts argv_empty_on.finalize
      end
    end

  end

  class NameListFormatter < Formatter
    def setup
      if Argv.files?
        file_names = Argv.files
        Viewer.new.show_name(sort_and_reverse(file_names))
      end

      if Argv.directories?
        directories = Argv.directories.sort
        directories.each do |directory|
          Viewer.new.show_directory(directory)
          Dir.chdir(directory)
          Viewer.new.show_name(sort_and_reverse(look_up_dir))
        end
      end

      if Argv.both_empty?
        directory = Dir.pwd
        Dir.chdir(directory)
        Viewer.new.show_name(sort_and_reverse(look_up_dir))
      end
    end
  end

  class Directory
    attr_accessor :max_size_digit, :max_nlink_digit, :block_sum
    
    def initialize
      @file_details = []
      @max_size_digit = max_size_digit
      @max_nlink_digit = max_nlink_digit
      @block_sum = block_sum
    end

    def setup(directory)
      file_names = make_file_name_list(directory)
      make_instans(sort_and_reverse(file_names))
      update_file_data
      max_file_size_digit
      max_file_nlink_digit
    end

    def show_directory(directory)
      puts
      puts "#{directory}:"
    end

    def finalize
      @file_details.map { |file_data| show_detail(file_data) }
    end



    def make_file_name_list(directory)
      if directory == Argv.files
        Argv.files
      else
        Dir.chdir(directory)
        Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
      end
    end

    def make_instans(file_names)
      file_names.map { |file| @file_details << FileData.new(file) }
    end

    def update_file_data
      @file_details.each { |file_data| file_data.apend_info(file_data) }
    end

    def show_detail(file_data)
      format(detail_data_fomat, file_data.instans_to_h)
    end

    def detail_data_fomat
      "%<ftype>s%<mode>s  %<nlink>#{@max_nlink_digit}d %<owner>5s  %<group>5s  %<size>#{@max_size_digit}d %<mtime>s %<file>s"
    end

    def max_file_size_digit
      @max_size_digit = @file_details.max_by { |file_data| file_data.size }.size.to_s.length
    end

    def max_file_nlink_digit
      @max_nlink_digit = @file_details.max_by { |file_data| file_data.nlink.length }.nlink.length
    end

    def block_sum
      @block_sum = @file_details.inject(0) { |result, file_data| result + file_data.blocks }
    end

    def sort_and_reverse(array)
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
      fill_ftype
      fill_mode
      fill_nlink
      fill_owner
      fill_group
      fill_size
      fill_mtime
      fill_blocks
    end

    def instans_to_h
      { ftype: @ftype, mode: @mode, nlink: @nlink, owner: @owner,
        group: @group, size: @size, mtime: @mtime, file: @file }
    end

    def fill_ftype
      hash = { 'blockSpecial' => 'b', 'characterSpecial' => 'c',
               'directory' => 'd', 'link' => 'l', 'socket' => 's',
               'fifo' => 'p', 'file' => '-' }
      self.ftype = File.ftype(@file).gsub(/[a-z]+/, hash)
    end

    def fill_mode
      permission = File.lstat(@file).mode.to_s(8)[-3..-1]
      self.mode = change_mode_style(permission).join
    end

    def change_mode_style(permission)
      permission.split(//).map do |number|
        format('%<char>03d', char: number.to_i.to_s(2))
          .gsub(/^1/, 'r').gsub(/1$/, 'x').tr('1', 'w').tr('0', '-')
      end
    end

    def fill_nlink
      self.nlink = File.lstat(@file).nlink.to_s
    end

    def fill_owner
      self.owner = Etc.getpwuid(File.lstat(@file).uid).name
    end

    def fill_group
      self.group = Etc.getgrgid(File.lstat(@file).gid).name
    end

    def fill_size
      self.size = File.lstat(@file).size
    end

    def fill_mtime
      self.mtime = File.lstat(@file).mtime.strftime('%_m %_d %H:%M')
    end

    def fill_blocks
      self.blocks = File.lstat(@file).blocks.to_i
    end
  end
end
