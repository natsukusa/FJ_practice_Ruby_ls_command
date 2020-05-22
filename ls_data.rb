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

  class DetailListFormatter
    def initialize
      @final_view = []
    end

    def setup
      generate_with_argv_files if Argv.files?
      generate_with_argv_directories if Argv.directories?
      generate_with_non_argv if Argv.both_empty?
      puts @final_view
    end

    private

    def generate_with_argv_files
      argv_files_in_dir = Directory.new
      argv_files_in_dir.setup(Argv.files)
      @final_view << argv_files_in_dir.finalize
    end

    def generate_with_argv_directories
      # directories ||= Argv.directories.sort
      directories ||= sort_and_reverse(Argv.directories)
      directories.each do |directory|
        argv_dir_in_dir = Directory.new
        argv_dir_in_dir.setup(directory)
        @final_view.push("\n") unless @final_view.empty?
        @final_view << argv_dir_in_dir.finalize_at_argv_directories(directory)
      end
    end

    def generate_with_non_argv
      directory ||= Dir.pwd
      argv_empty_in_dir = Directory.new
      argv_empty_in_dir.setup(directory)
      @final_view.push("total #{argv_empty_in_dir.block_sum}")
      @final_view << argv_empty_in_dir.finalize
    end

    def sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end
  end

  class NameListFormatter
    def initialize
      @final_view = []
    end

    def setup
      generate_with_argv_files if Argv.files?
      generate_with_argv_directories if Argv.directories?
      generate_with_non_argv if Argv.both_empty?
      puts @final_view
    end

    private

    def generate_with_argv_files
      file_names = Argv.files
      @final_view << Viewer.new.show_name(sort_and_reverse(file_names))
    end

    def generate_with_argv_directories
      directories = sort_and_reverse(Argv.directories)
      directories.each do |directory|
        @final_view.push("\n") unless @final_view.empty?
        @final_view << "#{directory}:"
        file_names = Dir.chdir(directory) { sort_and_reverse(look_up_dir) }
        @final_view << Viewer.new.show_name(file_names)
      end
    end

    def generate_with_non_argv
      directory = Dir.pwd
      file_names = Dir.chdir(directory) { sort_and_reverse(look_up_dir) }
      @final_view << Viewer.new.show_name(file_names)
    end

    def sort_and_reverse(array)
      Argv.option[:reverse] ? array.sort.reverse : array.sort
    end

    def look_up_dir
      Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end
  end

  class Directory
    attr_accessor :max_size_digit, :max_nlink_digit

    def initialize
      @file_details = []
      @max_size_digit = max_size_digit
      @max_nlink_digit = max_nlink_digit
    end

    def setup(directory)
      file_names = make_file_name_list(directory)
      make_instans(sort_and_reverse(file_names))
      update_file_data(directory)
      max_file_size_digit
      max_file_nlink_digit
    end

    def finalize
      @file_details.map { |file_data| show_detail(file_data) }
    end

    def finalize_at_argv_directories(directory)
      ary = @file_details.map { |file_data| show_detail(file_data) }
      ary.unshift("total #{block_sum}")
      ary.unshift("#{directory}:")
    end

    def block_sum
      @file_details.inject(0) { |result, file_data| result + file_data.blocks }
    end

    private

    def make_file_name_list(directory)
      if directory == Argv.files
        Argv.files
      else
        Dir.chdir(directory) { Argv.option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*') }
      end
    end

    def make_instans(file_names)
      file_names.map { |file| @file_details << FileData.new(file) }
    end

    def update_file_data(directory)
      if directory == Argv.files
        @file_details.each(&:apend_info)
      else
        Dir.chdir(directory) { @file_details.each(&:apend_info) }
      end
    end

    def show_detail(file_data)
      format(detail_data_fomat, file_data.instans_to_h)
    end

    def detail_data_fomat
      "%<ftype>s%<mode>s  %<nlink>#{@max_nlink_digit}d %<owner>5s  %<group>5s  %<size>#{@max_size_digit}d %<mtime>s %<file>s"
    end

    def max_file_size_digit
      @max_size_digit = @file_details.max_by(&:size).size.to_s.length
    end

    def max_file_nlink_digit
      @max_nlink_digit = @file_details.max_by { |file_data| file_data.nlink.length }.nlink.length
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

    def apend_info
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

    private

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
