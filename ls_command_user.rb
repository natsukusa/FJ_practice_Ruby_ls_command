load './ls_data.rb'
load './console_view.rb'

class LsCommandUser
  attr_accessor :argv_option, :dir_path


  def generate(argv_option, dir_path)
    @argv_option = argv_option
    @dir_path = (dir_path ||= Dir.pwd)

    DemandInfo.setup(argv_option, dir_path)
    # DemandInfo.file_details
    # p DemandInfo.path_name
    # p FileData.dir_path
    # p make_file_name_list(dir_path)
    # instans.display_file_name_list(@file_name_list, argv_option)
  end
end


if $0 == __FILE__
  require 'optparse'
  opt = OptionParser.new

  params = {}

  opt.on('-a') { |v| params[:all] = v }
  opt.on('-l') { |v| params[:list] = v }
  opt.on('-r') { |v| params[:reverse] = v }

  opt.parse!(ARGV)
  
  # new_user = LsCommandUser.new(params, ARGV.first)
  # new_user.generate
  LsCommandUser.new.generate(params, ARGV.first)
end




