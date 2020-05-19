# frozen_string_literal: true

module Ls
  require 'io/console/size'

  class Viewer
    def show_name(array)
      make_variables(array)
      make_formatted_list(array, @max_file_length)
      make_name_view_list(@formatted_list, @number_of_rows)
    end

    def show_detail(file_data)
      puts format(detail_data_fomat, file_data.instans_to_h)
    end

    def show_directory(directory)
      puts
      puts "#{directory}:" if Argv.directories?
    end

    private

    def detail_data_fomat
      '%<ftype>s%<mode>s  %<nlink>2d %<owner>5s  %<group>s %<size>5d %<mtime>s %<file>s'
    end

    def console_width
      IO.console_size[1]
    end

    def make_variables(array)
      @max_file_length = array.max_by(&:length).length
      @number_of_columns = console_width / (@max_file_length + 9)
      @number_of_rows = (array.size / @number_of_columns.to_f).ceil
    end

    def make_formatted_list(array, max_file_length)
      @formatted_list = array.map { |name| name.ljust(max_file_length + 9) }
    end

    def make_name_view_list(formatted_list, number_of_rows)
      sliced_list = []
      formatted_list.each_slice(number_of_rows) { |file| sliced_list << file }
      sliced_list.last << '' while sliced_list.last.size < number_of_rows
      sliced_list.transpose.each { |v| print v.join + "\n" }
    end
  end
end
