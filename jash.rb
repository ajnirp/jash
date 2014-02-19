#!/home/rohanprinja/.rvm/bin/ruby-1.9.3-p448@global -W0

require 'readline'

require './colorize.rb'
require './builtins.rb'
require './signals.rb'
require './history.rb'

include Builtins
include SignalHandlers

$my_pid = Process.pid

$home_directory = Dir.home
$home_regex = Regexp.new $home_directory

$history_file = "#{$home_directory}/.history"
# $aliases_file = "#{$home_directory}/aliases.txt"
$aliases_file = "./aliases.txt"

# read from aliases file
$aliases = Hash[IO.readlines($aliases_file).map(&:split)]

# parse bash aliases file
bash_aliases = IO.readlines(Dir.home + '/.bash_aliases').reject { |line| line.eql?("\n") || line =~ /^\s*#/ }.map { |line| line.rstrip.split("=",2) }
bash_aliases.map! { |k, v| [k.gsub(/alias /, '') , v[0] == "'" ? v[1...-1] : v] }

# programs in the PATH variable
paths = ENV['PATH'].split ':'
programs = []
paths.each do |path|
  executables = Dir.glob("#{path}/*").select { |file| File.executable? file }
  basenames = executables.map { |exe| File.basename exe }
  programs.concat basenames
end
programs.sort!

$builtins = Builtins.instance_methods.map &:to_s

Readline.completion_append_character = ' '
Readline.completion_proc = proc { |s| programs.grep(/^#{Regexp.escape(s)}/) }

$fg_children = []
$bg_children = []
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

  if tokens.include? '|'
  end

  command_name = tokens.first

  if $builtins.include? command_name
    return send command_name, tokens
  end

  fork_and_exec(command, tokens.last == '&')
end

def fork_and_exec command, bg=false
  (bg ? $bg_children : $fg_children) << fork do
    execute_error = "#{"Error:".red.bold} could not execute command `#{command.split.first.green}'"
    begin
      Process.setpgrp if bg
      exec command
    rescue
      STDERR.puts execute_error
      STDERR.flush
    end
  end
  Process.wait
  (bg ? $bg_children : $fg_children).pop
end

def exit_shell
  $fg_children.each do |pid|
    Process.kill :KILL, pid
    $fg_children.pop
  end
  save_history
  puts "Bye!"
  exit
end

def read_command
  working_dir = Dir.pwd.gsub $home_regex, "~"
  prompt = "#{working_dir} >>> ".brown
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
    next if command =~ /^\s*$/
    if command.nil? or command =~ /^\s*exit\s*$/
      if command.nil? then puts "^D" end
      exit_shell
    end
    execute command
  end
end

if __FILE__ == $0
  load_history
  greet
  main
end