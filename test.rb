require 'ruby2d'

set background: 'blue'

class Paddle
    HEIGHT = 150
    attr_writer :direction
    attr_reader :side
    def initialize(side, movement_speed)
        @side = side
        @movement_speed = movement_speed
        @direction = nil
        @y = 200
        if side == :left
            @x = 40
            @x_health = 170
        else
            @x = 575
            @x_health = 400
        end
    end

    def draw
        @shape = Rectangle.new(x: @x, y: @y, width: 25, height: HEIGHT, color: 'white')
    end

    def move
        if @direction == :up
            @y = [@y-@movement_speed, 0].max
        elsif @direction == :down
            @y = [@y+@movement_speed, max_y].min
        end
    end

    def hit_ball?(ball)
        ball.shape && [[ball.shape.x1, ball.shape.y1], [ball.shape.x2, ball.shape.y2],
         [ball.shape.x3, ball.shape.y3], [ball.shape.x4, ball.shape.y4]].any? do |coordinates|
            @shape.contains?(coordinates[0], coordinates[1])
        end
    end

    def y1
        @shape.y1
    end

    def show_health(health)
        @display_health = Text.new("lives: #{health}", color: 'white', size: 20, x: @x_health, y: 10, z: 5)
        @display_health.remove
        @display_health.add
    end

    def dead?(health)
        if health <= 0
            return true
        end
    end

    private
    
    def max_y
        Window.height - HEIGHT
    end

end

class Ball
    HEIGHT = 25

    attr_reader :shape

    def initialize(speed)
        @x = 320
        @y = 400
        @speed = speed
        @y_velocity = speed
        @x_velocity = -speed
    end

    def move
        if hit_bottom? || hit_top?
            @y_velocity = -@y_velocity
        end

        @x += @x_velocity
        @y += @y_velocity

    end

    def bounce_off(paddle)
        if @last_hit_side != paddle.side
            position = ((@shape.y1 - paddle.y1) / Paddle::HEIGHT.to_f)
            angle = position.clamp(0.2, 0.8) * Math::PI
            #puts "position = #{position}"

            if paddle.side == :left
                @x_velocity = Math.sin(angle) * @speed
                @y_velocity = -Math.cos(angle) * @speed
            else
                @x_velocity = -Math.sin(angle) * @speed
                @y_velocity = -Math.cos(angle) * @speed
            end

            @last_hit_side = paddle.side
        end
    end

    def draw
        @shape = Square.new(x: @x, y: @y, size: HEIGHT, color: 'black')
    end

    def out_of_bounds?
        if @x <= 0
            return 0
        elsif @shape.x2 >= Window.width
            return 1
        end
    end

    private

    def hit_bottom?
        @y + HEIGHT >= Window.height
    end

    def hit_top?
        @y <= 0
    end
end

@ball_velocity = 8
@player_health = 3
@opponent_health = 3
@screen = "intro"
@game = true

player = Paddle.new(:left, 4)
opponent = Paddle.new(:right, 4)
ball = Ball.new(@ball_velocity)


if @screen == "intro"
    clear
    Text.new('PONG GAME', size: 40, x: 150, y: 100)
elsif @screen == "main"
    clear
    set background: 'blue'
    update do
        clear
    
        if player.hit_ball?(ball)
            ball.bounce_off(player)
            #@ball_acceleration+=0.1
        end
    
        if opponent.hit_ball?(ball)
            ball.bounce_off(opponent)
            #@ball_acceleration+=0.1
        end
    
        player.move
        player.draw
    
        opponent.move
        opponent.draw
    
        ball.move
        ball.draw
    
        player.show_health(@player_health)
        opponent.show_health(@opponent_health)
    
        if ball.out_of_bounds? == 0
            @player_health-=1
            ball = Ball.new(@ball_velocity)
        elsif ball.out_of_bounds? == 1
            @opponent_health-=1
            ball = Ball.new(@ball_velocity)
        end
    
        if player.dead?(@player_health)
            @dead = "player"
            @screen == "game_over"
        elsif opponent.dead?(@opponent_health)
            @dead = "opponent"
            @screen == "game_over"
        end
    end

elsif @screen == "game_over"
    set background: 'black'
    clear
    if @dead == "player"
        Text.new('THE OPPONENT WINS!', x: 190, y: 220, size: 25)
    elsif @dead == "opponent"
        Text.new('THE PLAYER WINS!', x: 200, y: 220, size: 25)
    end

end


on :key_held do |event|
    if event.key == 'w'
        player.direction = :up
    elsif event.key == 's'
        player.direction = :down
    elsif event.key == 'up'
        opponent.direction = :up
    elsif event.key == 'down' 
        opponent.direction = :down
    elsif event.key == 'b'
        @screen = "main"
    elsif event.key == 'q'
        @game = false
    end
end

on :key_up do |event|
    player.direction = nil
    opponent.direction = nil
end


show