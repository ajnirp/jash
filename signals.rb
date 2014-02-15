module SignalHandlers
  trap :INT do
    if $my_pid == Process.pid
      unless $fg_children.empty?
        Process.kill :INT, $fg_children.last
        $fg_children.pop
      end
      puts "^C"
      main
    end
  end

  trap :TSTP do
    if $my_pid == Process.pid
      unless $fg_children.empty?
        Process.kill :TSTP, $fg_children.last
        puts "Stopped: #{fg_children.last}"
        $stopped_children << $fg_children.pop
      end
    end
  end

  trap :CONT do
    if $my_pid == Process.pid
      unless $stopped_children.empty?
        puts "Resumed: #{stopped_children.last}"
        Process.kill :CONT, $stopped_children.last
        $fg_children << $stopped_children.pop
      end
    end
  end

  trap :CHLD do
  end
end