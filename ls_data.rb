require 'etc'

class DemandInfo
  def self.setup(argv_option, dir_path)
    @dir_path = dir_path
    file_names = make_file_name_list(argv_option, dir_path)
    file_names.sort!
    file_names.reverse! if argv_option[:reverse]

    if argv_option[:list]
      p 'under construction!'
      # file_names = make_file_name_list(argv_option, dir_path)
      @file_details = make_instans(file_names)
      @file_details.each do |file_data| 
        file_data.apend_info(file_data)
      end

      # nlink と size の表示幅を計算するメソッドが必要
      @file_details.each do |file_data| 
        ConsoleView.new.print_detail(file_data)
      end
      
      block_sum
      # make_detail_array
    else
      # file_names = make_file_name_list(argv_option, dir_path)
      ConsoleView.new.display_file_name_list(file_names)
    end
  end

  def self.file_details # テスト用
    p @file_details
  end

  def self.make_instans(file_names)
    file_names.map { |file| FileData.new(file) }
  end

  def self.make_file_name_list(argv_option, dir_path)
    Dir.chdir(dir_path)
    argv_option[:all] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
  end

  def self.block_sum
    @file_details.inject(0) { |result, file_data| result + file_data.blocks }
  end

  # def self.make_detail_array # インスタンスに含まれる変数の一覧取得
  #   p @file_details.map(&:instance_variables)
  # end
end

class FileData
  # DIR_PATH = DemandInfo.path_name
  
  # def self.dir_path
  #   @@dir_path = DemandInfo.path_name
  # end

  attr_accessor :file
  attr_accessor :ftype
  attr_accessor :mode
  attr_accessor :nlink
  attr_accessor :owner
  attr_accessor :group
  attr_accessor :size
  attr_accessor :mtime
  attr_accessor :blocks
  
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
    hash = {'directory'=>'d', 'link'=>'l', 'file'=>'-' }
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
