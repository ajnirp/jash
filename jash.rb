#!/home/rohanprinja/.rvm/bin/ruby-1.9.3-p448@global -W0

require 'readline'
require './colorize.rb'
require './builtins.rb'
require './signals.rb'

include Builtins
include SignalHandlers

$my_pid = Process.pid

# read from aliases file
$aliases = Hash[IO.readlines('aliases.txt').map(&:split)]

# parse bash aliases file
bash_aliases = IO.readlines(Dir.home + '/.bash_aliases').reject { |line| line.eql?("\n") || line =~ /^\s*#/ }.map { |line| line.rstrip.split("=",2) }
bash_aliases.map! { |k, v| [k.gsub(/alias /, '') , v[0] == "'" ? v[1...-1] : v] }

# programs in the PATH variable
# paths = ENV['PATH'].split ':'
# programs = []
# paths.each { |path| programs.concat(Dir.glob("#{path}/*").select { |file| File.executable? file }) }

# p programs

$builtins = Builtins.instance_methods.map &:to_s

# Readline.completion_append_character = ' '

$fg_children = []
$stopped_children = []

$aliases.merge! Hash[bash_aliases]

$last_dir = Dir.pwd

def execute command
  command.strip!

  if $aliases.include? command
    return fork_and_exec $aliases[command]
  end

  # check for semicolons
  if command.include? ';'
    command.split(';').each { |cmd| execute cmd }
    return
  end

  tokens = command.split # need to replace this with something better
  # that can handle double quotes

  if tokens.include? '&'
  end
  if tokens.include? '|'
  end

  command_name = tokens.first

  if $builtins.include? command_name
    return send command_name, tokens
  end

  fork_and_exec command
end

def fork_and_exec command
  $fg_children << fork do
    execute_error = "#{"Error:".red.bold} could not execute command `#{command.split.first.green}'"
    exec command rescue STDERR.puts execute_error; STDERR.flush
  end
  Process.wait
  $fg_children.pop
end

def exit_shell
  $fg_children.each do |pid|
    Process.kill :USR1, pid
    $fg_children.pop
  end
  save_history
  exit
end

def read_command
  prompt = "#{Dir.pwd} >>> ".brown
  line = Readline.readline prompt
  return nil if line.nil?
  unless line =~ /^\s*$/ or Readline::HISTORY.to_a.last == line
    Readline::HISTORY.push line
  end
  return line
end

def greet
  username = `id -nu`
  puts "Welcome, #{username}"
  $stdout.flush
end

def main
  loop do
    command = read_command
    if command.nil? or command =~ /^\s*exit\s*$/
      puts "^D\nBye!"
      exit_shell
    elsif command.empty?
      next
    end
    execute command
  end
end

def save_history
  File.open '.history', 'w' do |f|
    Readline::HISTORY.each do |line|
      f.write line
      f.write "\n"
    end
  end
end

if __FILE__ == $0
  greet
  main
end