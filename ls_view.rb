# frozen_string_literal: true

module Ls
  require 'io/console/size'

  class Viewer
    def show_name(array)
      make_variables(array)
      make_formatted_list(array, @columns_width)
      make_name_view(@formatted_list, @number_of_rows)
    end

    private

    def console_width
      IO.console_size[1]
    end

    # @columns_width = 8, 16, 24, 32, 40, 48 ...
    def make_variables(array)
      max_file_length = array.max_by(&:length).length
      @columns_width = ((max_file_length + 1) / 8.0).ceil * 8
      @number_of_columns = console_width / @columns_width
      @number_of_rows = (array.size / @number_of_columns.to_f).ceil
    end

    def make_formatted_list(array, columns_width)
      @formatted_list = array.map { |name| name.ljust(columns_width) }
    end

    def make_name_view(formatted_list, number_of_rows)
      sliced_list = []
      formatted_list.each_slice(number_of_rows) { |file| sliced_list << file }
      sliced_list.last << '' while sliced_list.last.size < number_of_rows
      sliced_list.transpose.each(&:join).map(&:join)
    end
  end
end
