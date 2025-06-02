require 'test_helper'

class CloneCommandTest < Minitest::Test
  def setup
    @command = Gem::Commands::CloneCommand.new
  end

  def test_initialize
    assert_equal 'clone', @command.command
    assert_equal 'Clone a gem repository using ghq', @command.summary
  end

  def test_arguments
    assert_includes @command.arguments, 'GEM_NAME'
  end

  def test_description
    assert_includes @command.description, 'clone command fetches gem metadata'
  end

  def test_normalize_repository_url_with_tree_path
    url = "https://github.com/rails/rails/tree/v8.0.2"
    expected = "https://github.com/rails/rails"
    assert_equal expected, @command.send(:normalize_repository_url, url)
  end

  def test_normalize_repository_url_with_blob_path
    url = "https://github.com/user/repo/blob/main/README.md"
    expected = "https://github.com/user/repo"
    assert_equal expected, @command.send(:normalize_repository_url, url)
  end

  def test_normalize_repository_url_with_clean_url
    url = "https://github.com/user/repo"
    assert_equal url, @command.send(:normalize_repository_url, url)
  end

  def test_normalize_repository_url_with_trailing_slash
    url = "https://github.com/user/repo/"
    expected = "https://github.com/user/repo"
    assert_equal expected, @command.send(:normalize_repository_url, url)
  end

  def test_normalize_repository_url_with_nil
    assert_nil @command.send(:normalize_repository_url, nil)
  end

  def test_normalize_repository_url_with_empty_string
    assert_equal "", @command.send(:normalize_repository_url, "")
  end

  def test_show_url_option_parsing
    @command.handle_options(['--show-url'])
    assert @command.options[:show_url]
  end

  def test_verbose_option_parsing
    @command.handle_options(['-v'])
    assert @command.options.has_key?(:verbose)
  end

  def test_command_available_with_existing_command
    assert @command.send(:command_available?, 'ruby')
  end

  def test_command_available_with_nonexistent_command
    refute @command.send(:command_available?, 'nonexistent_command_xyz_12345')
  end
end
