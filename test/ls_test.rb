require 'minitest/autorun'
require './ls_command_user'
# require './ls_data'
# require './console_view'

class LsNormalTest < Minitest::Test
  def setup
    Ls::User.new
  end

  def test_normal
    user = Ls::User.new
    expected = <<~TEXT
    console_view.rb         ls_command_user.rb      ls_data.rb              test                    
    TEXT
    assert_output(expected) { user.generate({}, []) }
  end

  def test_normal_a
    user = Ls::User.new
    expected = <<~TEXT
    .                       ..                      .byebug_history         .git                    .rubocop.yml            console_view.rb         ls_command_user.rb      ls_data.rb              test                    
    TEXT
    assert_output(expected) { user.generate({:all=>true}, []) }
  end

  def test_normal_l
    user = Ls::User.new
    assert_output(`ls -l`) { user.generate({:list=>true}, []) }
  end

  def test_normal_al
    user = Ls::User.new
    assert_output(`ls -al`) { user.generate({:all=>true, :list=>true}, []) }
  end
  
  def teardown
  end
  
end

class ArgvTest01 < Minitest::Test
  def setup
    Ls::User.new
  end

  def test_argv_f_l
    user = Ls::User.new
    assert_output(`ls -l /Users/natsu/vimtutorial console_view.rb`) { user.generate({:list=>true},
       ['/Users/natsu/vimtutorial', 'console_view.rb']) }
  end

  def test_argv_f_al
    user = Ls::User.new
    assert_output(`ls -al /Users/natsu/vimtutorial console_view.rb`) { user.generate({:all=>true, :list=>true},
       ['/Users/natsu/vimtutorial', 'console_view.rb']) }
  end

  def teardown
  end

end
