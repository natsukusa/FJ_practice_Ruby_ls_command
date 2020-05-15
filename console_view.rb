require 'io/console/size'

class ConsoleView

  def display_file_name_list(array)
    make_variables(array)
    make_formatted_list(array, @max_file_length)
    make_final_view_list(@formatted_list, @number_of_rows)
  end
  
  # TODO 合計値の表示
  # puts "total #{block_sum}"

  # nlink と size の表示幅の変数が必要
  def print_detail(file_data)
    puts sprintf('%{ftype}%{mode}  %<nlink>2d %{owner}  %{group} %<size>5d %{mtime} %{file}',
       file_data.instans_to_h)
  end

  private

  def console_width
    IO.console_size[1]
  end
  
  def make_variables(array)
    @max_file_length = array.max_by { |name| name.length }.length
    @number_of_columns = console_width / (@max_file_length + 9)
    @number_of_rows = (array.size / @number_of_columns.to_f).ceil
  end

  def make_formatted_list(array, max_file_length)
    @formatted_list = array.map { |name| name.ljust(max_file_length + 9) }
  end

  def make_final_view_list(formatted_list, number_of_rows)
    sliced_list = []
    formatted_list.each_slice(number_of_rows) { |file| sliced_list << file }
    # 分割した配列の要素数を揃えるために最後の要素に空文字列を追加
    sliced_list.last << '' while sliced_list.last.size < number_of_rows
    # 配列の行と列を変換
    sliced_list.transpose.each { |v| print v.join + "\n" }
  end

end
