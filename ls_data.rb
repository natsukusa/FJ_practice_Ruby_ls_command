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

  class WithListOption
    def self.setup
      if Argv.files?
        file_details = make_instans(sort_and_reverse(Argv.files))
        file_details.each { |file_data| file_data.apend_info(file_data) }
        file_details.each { |file_data| Viewer.new.show_detail(file_data) }
      end

      directories = Argv.directories? ? Argv.directories.sort : [Dir.pwd]

      directories.each do |directory|
        @file_details = make_instans(sort_and_reverse(make_file_name_list(directory)))
        @file_details.each { |file_data| file_data.apend_info(file_data) }
        Viewer.new.show_directory(directory)
        puts "total: #{block_sum}"
        file_details.each { |file_data| Viewer.new.show_detail(file_data) }
      end
    end

    def self.make_instans(file_names)
      file_names.map { |file| FileData.new(file) }
    end

    def self.make_file_name_list(directory)
      Dir.chdir(directory)
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
      if Argv.files?
        file_names = Argv.files
        Viewer.new.show_name(sort_and_reverse(file_names))
      end
      if Argv.directories?
        directories = Argv.directories
        final_name_list(directories.sort!)
      end
      normal_name_list if Argv.both_empty?
    end

    def self.normal_name_list
      Dir.chdir(Dir.pwd)
      Viewer.new.show_name(sort_and_reverse(look_up_dir))
    end

    def self.final_name_list(directories)
      directories.each do |directory|
        Viewer.new.show_directory(directory)
        Dir.chdir(directory)
        Viewer.new.show_name(sort_and_reverse(look_up_dir))
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
      file_data.fill_nlink(file_data)
      file_data.fill_owner(file_data)
      file_data.fill_group(file_data)
      file_data.fill_size(file_data)
      file_data.fill_mtime(file_data)
      file_data.fill_blocks(file_data)
    end

    def instans_to_h
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
        format('%<char>03d', char: value.to_i.to_s(2))
          .tr('^1', 'r').tr('1$', 'x').tr('1', 'w').tr('0', '-')
      end
    end

    def fill_nlink(file_data)
      @nlink = File.lstat(file_data.file).nlink.to_s
    end

    def fill_owner(file_data)
      @owner = Etc.getpwuid(File.lstat(file_data.file).uid).name
    end

    def fill_group(file_data)
      @gourp = Etc.getgrgid(File.lstat(file_data.file).gid).name
    end

    def fill_size(file_data)
      @size = File.lstat(file_data.file).size
    end

    def fill_mtime(file_data)
      @mtime = File.lstat(file_data.file).mtime.strftime('%_m %_d %H:%M')
    end

    def fill_blocks(file_data)
      @blocks = File.lstat(file_data.file).blocks.to_i
    end
  end
end
