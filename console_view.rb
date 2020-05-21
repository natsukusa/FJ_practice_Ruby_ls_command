# frozen_string_literal: true

module Ls
  require 'io/console/size'

  class Viewer
    def show_name(array)
      make_variables(array)
      make_formatted_list(array, @max_file_length)
      make_name_view(@formatted_list, @number_of_rows)
    end

    def show_directory(directory)
      puts
      puts "#{directory}:"
    end

    private

    def console_width
      IO.console_size[1]
    end

    def make_variables(array)
      @max_file_length = array.max_by(&:length).length
      @number_of_columns = console_width / (@max_file_length + 6)
      @number_of_rows = (array.size / @number_of_columns.to_f).ceil
    end

    def make_formatted_list(array, max_file_length)
      @formatted_list = array.map { |name| name.ljust(max_file_length + 6) }
    end

    def make_name_view(formatted_list, number_of_rows)
      sliced_list = []
      formatted_list.each_slice(number_of_rows) { |file| sliced_list << file }
      sliced_list.last << '' while sliced_list.last.size < number_of_rows
      sliced_list.transpose.each { |v| print v.join + "\n" }
    end
  end



  # class ArgvArrenger < DetailListFormatter
  #   def setup
  #     if Argv.files?
  #       argv_file_on = Directory.new
  #       argv_file_on.setup(Argv.files)
  #       puts argv_file_on.finalize
  #     end

  #     if Argv.directories?
  #       directories = Argv.directories.sort
  #       directories.each do |directory|
  #         argv_dir_on = Directory.new
  #         argv_dir_on.setup(directory)
  #         argv_dir_on.show_directory(directory)
  #         puts argv_dir_on.finalize
  #       end
  #     end
  #   end
  # end



  # class NonListOption < NameListFormatter
  #   def setup
  #     if Argv.files?
  #       file_names = Argv.files
  #       Viewer.new.show_name(sort_and_reverse(file_names))
  #     end

  #     if Argv.directories?
  #       directories = Argv.directories.sort
  #       directories.each do |directory|
  #         Viewer.new.show_directory(directory)
  #         Dir.chdir(directory)
  #         Viewer.new.show_name(sort_and_reverse(look_up_dir))
  #       end
  #     end
  #   end
  # end
end
