module Builtins
  def cd tokens
    if tokens.length == 1
      $last_dir = Dir.pwd
      Dir.chdir # go to home directory
    else
      STDERR.puts "Ignoring extra arguments to cd" if tokens.length > 2
      destination_dir = tokens[1] == '-' ? $last_dir : tokens[1]
      $last_dir = Dir.pwd
      Dir.chdir destination_dir
    end
  end

  def pwd tokens
    Dir.pwd
  end

  def show_aliases tokens
    $aliases.each { |k, v| puts "#{k} is aliased to #{v}" }
  end

  def clearhistory tokens
    # clear history
    File.truncate $history_file, 0
    # clear readline stack
    until Readline::HISTORY.size.zero?
      Readline::HISTORY.pop
    end
  end
end