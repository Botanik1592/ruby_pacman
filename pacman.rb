# frozen_string_literal: true

require 'io/console'
require './data'

while @level <= @maps.size - 1
  print_logo
  init_variables
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

  build_level

  @threads << tr
  @threads << tr2
  @threads << tr3

  @threads.each(&:join)
end
