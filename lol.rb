#!/home/rohanprinja/.rvm/bin/ruby-1.9.3-p448@global -W0

# minimal working shell
# not my own code

$>.print '-> ';$<.each{|l|Process.wait(pid=fork{exec l});$>.print '-> '}