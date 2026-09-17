require 'test_helper'
require 'stringio'

class CloneCommandTest < Minitest::Test
  class RecordingCloneCommand < Gem::Commands::CloneCommand
    attr_reader :spawned

    def initialize(exit_status)
      super()
      @exit_status = exit_status
    end

    def system(*args)
      @spawned = args
      # A real process, so $? carries a status. RUBYOPT is dropped to skip bundler.
      super({ 'RUBYOPT' => nil }, RbConfig.ruby, '--disable-gems', '-e', "exit #{@exit_status}")
    end
  end

  def setup
    @command = Gem::Commands::CloneCommand.new
  end

  def test_initialize
    assert_equal 'clone', @command.command
    assert_equal 'Clone a gem repository using git goget, ghq, or git', @command.summary
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

  def test_normalize_repository_url_with_fragment
    url = "https://github.com/cucumber/messages#readme"
    expected = "https://github.com/cucumber/messages"
    assert_equal expected, @command.send(:normalize_repository_url, url)
  end

  def test_normalize_repository_url_with_query
    url = "https://github.com/user/repo?tab=readme-ov-file"
    expected = "https://github.com/user/repo"
    assert_equal expected, @command.send(:normalize_repository_url, url)
  end

  def test_normalize_repository_url_with_git_suffix
    url = "https://github.com/ioquatix/bake.git"
    expected = "https://github.com/ioquatix/bake"
    assert_equal expected, @command.send(:normalize_repository_url, url)
  end

  def test_normalize_repository_url_with_www_and_http
    url = "http://www.github.com/instructure/soap4r-middleware"
    expected = "https://github.com/instructure/soap4r-middleware"
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

  def test_clone_runners_pass_the_url_as_a_single_argument
    url = "https://github.com/user/repo; echo injected"

    {
      clone_with_git_goget: ["git", "goget", url],
      clone_with_ghq: ["ghq", "get", url],
      clone_with_git: ["git", "clone", url],
    }.each do |runner, expected|
      command = RecordingCloneCommand.new(0)
      with_captured_ui { command.send(runner, url) }
      assert_equal expected, command.spawned
    end
  end

  def test_clone_with_git_goget_reports_an_unreachable_repository
    url = "https://github.com/gone/repo"
    command = RecordingCloneCommand.new(3)

    _, err, status = with_captured_ui { command.send(:clone_with_git_goget, url) }

    assert_includes err, "Repository is unreachable: #{url}"
    assert_equal 1, status
  end

  def test_clone_with_git_goget_reports_a_failure
    command = RecordingCloneCommand.new(1)

    _, err, status = with_captured_ui { command.send(:clone_with_git_goget, "https://github.com/user/repo") }

    assert_includes err, "Failed to clone repository with git goget."
    assert_equal 1, status
  end

  def with_captured_ui
    out, err = StringIO.new, StringIO.new
    previous_ui = Gem::DefaultUserInteraction.ui
    Gem::DefaultUserInteraction.ui = Gem::StreamUI.new(StringIO.new, out, err)
    status = nil
    begin
      yield
    rescue Gem::SystemExitException => e
      status = e.exit_code
    end
    [out.string, err.string, status]
  ensure
    Gem::DefaultUserInteraction.ui = previous_ui
  end
end
