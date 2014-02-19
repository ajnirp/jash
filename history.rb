def load_history
  if File.exists? $history_file
    IO.readlines($history_file).each do |line|
      next if line.strip =~ /^\s*$/
      clean_line = line.strip
      unless clean_line == Readline::HISTORY.to_a.last
        Readline::HISTORY.push clean_line
      end
    end
  else
    File.open $history_file, "w"
  end
end

def save_history
  File.open $history_file, 'w' do |f|
    Readline::HISTORY.each do |line|
      f.write line
      f.write "\n"
    end
  end
end