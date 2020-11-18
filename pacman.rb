# frozen_string_literal: false
require 'io/console'

@map = []
@enemies = []
File.readlines('map1').each { |line| @map << [line.strip] }

@player = [1, 1]
5.times do
  coords = [rand(5..17), rand(5..42)]
  while @enemies.size < 5 && @map[coords[0]][0][coords[1]] == '.'
    @enemies << coords
    coords = [rand(5..17), rand(5..42)]
  end
end
@redraw = true
@scores = 0

def draw_map
  system('clear')
  puts
  puts "SCORES: #{@scores}"
  puts
  good_turn = [' ', '.', 'Ö']
  @map.each_with_index do |line, i|
    line[0][@player[1]] = 'Ö' if i == @player[0] && good_turn.include?(line[0][@player[1]])
    @enemies.each do |enemy|
      line[0][enemy[1]] = '¥' if i == enemy[0] && good_turn.include?(line[0][enemy[1]])
    end
    line[0][-1] = '=' if @scores > 100 && @map.size == i + 2
    puts "\r#{line[0]}"
  end
end

def read_char
  $stdin.echo = false
  $stdin.raw!

  input = $stdin.getc.chr
  if input == "\e"
    input << $stdin.read_nonblock(3) rescue nil
    input << $stdin.read_nonblock(2) rescue nil
  end
ensure
  return input
end

def comp_turn(enemy)
  x = enemy[0]
  y = enemy[1]
  good_turn = [' ', 'Ö', '.']
  if x > @player[0] && good_turn.include?(@map[x - 1][0][y])
    @map[x][0][y] = @map[x - 1][0][y]
    enemy[0] = x - 1
  elsif x < @player[0] && good_turn.include?(@map[x + 1][0][y])
    @map[x][0][y] = @map[x + 1][0][y]
    enemy[0] = x + 1
  elsif y > @player[1] && good_turn.include?(@map[x][0][y - 1])
    @map[x][0][y] = @map[x][0][y - 1]
    enemy[1] = y - 1
  elsif y < @player[1] && good_turn.include?(@map[x][0][y + 1])
    @map[x][0][y] = @map[x][0][y + 1]
    enemy[1] = y + 1
  elsif good_turn.include?(@map[x - 1][0][y])
    @map[x][0][y] = @map[x - 1][0][y]
    enemy[0] = x - 1
  elsif good_turn.include?(@map[x + 1][0][y])
    @map[x][0][y] = @map[x + 1][0][y]
    enemy[0] = x + 1
  elsif good_turn.include?(@map[x][0][y - 1])
    @map[x][0][y] = @map[x][0][y - 1]
    enemy[1] = y - 1
  elsif good_turn.include?(@map[x][0][y + 1])
    @map[x][0][y] = @map[x][0][y + 1]
    enemy[1] = y + 1
  end
end

def check_lose(vrag)
  return unless vrag == @player

  @redraw = false
  puts "\n\rYou are LOSE!"
  exit_game
end

def up_scores
  @scores += 1
end

def exit_game
  $stdin.echo = true
  $stdin.cooked!
  exit 0
end

def show_single_key
  c = read_char
  good_turn = [' ', '.']

  case c
  when "\u0003"
    @redraw = false
    exit_game
  when 'c'
    @redraw = false
    exit_game
  when "\e[A"
    x = @player[0] - 1
    y = @player[1]
    if good_turn.include?(@map[x][0][y])
      @map[x + 1][0][y] = ' '
      @player[0] = x
      up_scores if @map[x][0][y] == '.'
    elsif @map[x][0][y] == '='
      @redraw = false
      puts "\n\rYou are WIN!"
      exit_game
    elsif @map[x][0][y] == '¥'
      @redraw = false
      puts "\n\rYou are LOSE!"
      exit_game
    end
  when "\e[B"
    x = @player[0] + 1
    y = @player[1]
    if good_turn.include?(@map[x][0][y])
      @map[x - 1][0][y] = ' '
      @player[0] = x
      up_scores if @map[x][0][y] == '.'
    elsif @map[x][0][y] == '='
      @redraw = false
      puts "\n\rYou are WIN!"
      exit_game
    elsif @map[x][0][y] == '¥'
      @redraw = false
      puts "\n\rYou are LOSE!"
      exit_game
    end
  when "\e[C"
    x = @player[0]
    y = @player[1] + 1
    if good_turn.include?(@map[x][0][y])
      @map[x][0][y - 1] = ' '
      @player[1] = y
      up_scores if @map[x][0][y] == '.'
    elsif @map[x][0][y] == '='
      @redraw = false
      puts "\n\rYou are WIN!"
      exit_game
    elsif @map[x][0][y] == '¥'
      @redraw = false
      puts "\n\rYou are LOSE!"
      exit_game
    end
  when "\e[D"
    x = @player[0]
    y = @player[1] - 1
    if good_turn.include?(@map[x][0][y])
      @map[x][0][y + 1] = ' '
      @player[1] = y
      up_scores if @map[x][0][y] == '.'
    elsif @map[x][0][y] == '='
      @redraw = false
      puts "\n\rYou are WIN!"
      exit_game
    elsif @map[x][0][y] == '¥'
      @redraw = false
      puts "\n\rYou are LOSE!"
      exit_game
    end
  else
    @redraw = false
    exit_game
  end
end

threads = []

tr = Thread.new(@enemies) do |enemies|
  loop do
    enemies.each do |enemy|
      sleep 0.09
      comp_turn(enemy)
      check_lose(enemy)
    end
  end
end

tr3 = Thread.new do
  while @redraw
    sleep 0.09
    show_single_key
  end
end

tr2 = Thread.new do
  loop do
    sleep 0.09
    draw_map
  end
end

threads << tr
threads << tr2
threads << tr3

threads.each{ |thr| thr.join }
