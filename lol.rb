#!/home/rohanprinja/.rvm/bin/ruby-1.9.3-p448@global -W0

# minimal working shell
# not my own code

putc'$';$<.each{|l|Process.wait fork{exec l};putc'$'}