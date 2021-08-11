# frozen_string_literal: true

@redraw = true
@scores = 0
@maps = Dir['maps/*'].map { |f| f }
@level = 0

def init_variables
  @threads = []
  @map = []
  @enemies = []
  @redraw = true
  @player = [1, 1]
  @level_scores = 0
end

def read_map
  File.readlines(@maps[@level]).each { |line| @map << [line.strip] }
end

def build_level
  read_map
  while @enemies.size < 5
    coords = generate_coords
    coords = generate_coords until @map[coords[0]][0][coords[1]] == '.'
    @enemies << coords
  end
end

def generate_coords
  [rand(5..(@map.size - 1)), rand(5..(@map[0][0].size - 1))]
end

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
    line[0][-1] = '=' if @level_scores > 99 && @map.size == i + 2
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
  puts
  puts "\rYou are LOSE!"
  puts
  exit_game
end

def check_player_win(coord)
  return unless coord == '='

  @redraw = false
  puts
  puts "\rYou are WIN!"
  puts
  if @level == @maps.size
    exit_game
  else
    @level += 1
    @threads.each { |t| t.kill }
  end
end

def check_player_lose(coord)
  return unless coord == '¥'

  @redraw = false
  puts
  puts "\rYou are LOSE!"
  puts
  exit_game
end

def up_scores
  @scores += 1
  @level_scores += 1
end

def exit_game
  $stdin.echo = true
  $stdin.cooked!

  exit 0
end

def keyboard_turn
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
    end
  when "\e[B"
    x = @player[0] + 1
    y = @player[1]
    if good_turn.include?(@map[x][0][y])
      @map[x - 1][0][y] = ' '
      @player[0] = x
    end
  when "\e[C"
    x = @player[0]
    y = @player[1] + 1
    if good_turn.include?(@map[x][0][y])
      @map[x][0][y - 1] = ' '
      @player[1] = y
    end
  when "\e[D"
    x = @player[0]
    y = @player[1] - 1
    if good_turn.include?(@map[x][0][y])
      @map[x][0][y + 1] = ' '
      @player[1] = y
    end
  else
    @redraw = false
    exit_game
  end
  up_scores if @map[x][0][y] == '.'
  check_player_win(@map[x][0][y])
  check_player_lose(@map[x][0][y])
end

def print_logo
  system('clear')
  puts
  puts "\rPrepare For Level #{@level + 1}"
  puts
  puts "\rPress Enter to continue or ESC for exit"
  loop do
    c = read_char
    return if c == "\r"
    exit 0 if c == "\e"
  end
end
