module Builtins
  def cd tokens
    if tokens.length == 1
      Dir.chdir # go to home directory
    else
      STDERR.puts "Ignoring extra arguments to cd" if tokens.length > 2
      destination_dir = tokens[1]
      if destination_dir.eql? '-'
        destination_dir = $last_dir
        $last_dir = Dir.pwd
      end
      Dir.chdir destination_dir
    end
  end

  def pwd tokens
    Dir.pwd
  end

  def show_aliases
    $aliases.each { |k, v| puts "#{k} is aliased to #{v}" }
  end

  def clearhistory
    File.truncate $history_file, 0
  end
end