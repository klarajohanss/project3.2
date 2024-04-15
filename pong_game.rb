require 'ruby2d'

set background: 'blue'

class Paddle 
    attr_writer :direction
    def initialize(side, movement_speed)
        @movement_speed = movement_speed
        @direction = nil
        @y = 200
        if side == :left
            @x = 40
        else
            @x = 600
        end
    end

    def draw
        Rectangle.new(x: @x, y: @y, width: 25, height: 150, color: 'white')
    end

    def move
        if @direction == :up
            @y-=@movement_speed
        elsif @direction == :down
            @y+=@movement_speed
        end
        
    end

end

player = Paddle.new(:left, 4)

update do
    clear
    player.move
    player.draw
end

on :key_down do |event|
    if event.key == 'up'
        player.direction = :up
    elsif event.key == 'down'
        player.direction = :down
    end
end

on :key_up do |event|
    player.direction = nil
end
    

show