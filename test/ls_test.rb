# frozen_string_literal: true

require 'minitest/autorun'
require './ls_user'
require './ls_data'
require './ls_view'

class LsNormalTest < Minitest::Test
  # def setup
  #   Ls::User.new
  # end

  def test_normal
    user_a = Ls::User.new
    expected = <<~TEXT
    console_view.rb         ls_command_user.rb      ls_data.rb              test                    
    TEXT
    assert_output(expected) { user_a.generate({}, []) }
  end

  def test_normal_a
    user_b = Ls::User.new
    expected = <<~TEXT
    .                       ..                      .byebug_history         .git                    .rubocop.yml            console_view.rb         ls_command_user.rb      ls_data.rb              test                    
    TEXT
    assert_output(expected) { user_b.generate({:all=>true}, []) }
  end

  def test_normal_l
    user_c = Ls::User.new
    assert_output(`ls -l`) { user_c.generate({:list=>true}, []) }
  end

  def test_normal_al
    user_d = Ls::User.new
    assert_output(`ls -al`) { user_d.generate({:all=>true, :list=>true}, []) }
  end
  
  def teardown
  end

end

class ArgvTest01 < Minitest::Test
  # def setup
  #   Ls::User.new
  # end

  def test_argv_f_l
    user_1 = Ls::User.new
    assert_output(`ls -l /Users/natsu/vimtutorial console_view.rb`) { user_1.generate({:list=>true},
       ['/Users/natsu/vimtutorial', 'console_view.rb']) }
  end

  def test_argv_f_al
    user_2 = Ls::User.new
    assert_output(`ls -al /Users/natsu/vimtutorial console_view.rb`) { user_2.generate({:all=>true, :list=>true},
       ['/Users/natsu/vimtutorial', 'console_view.rb']) }
  end

  # def teardown
  # end

end
