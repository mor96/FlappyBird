W = love.graphics.getWidth()
H = love.graphics.getHeight()

gameObjects = {}
globals = {}

backImg = love.graphics.newImage("flappy-bird-assets-master/sprites/background-night.png")
ground = love.graphics.newImage("flappy-bird-assets-master/sprites/base.png")

function reset()
  love.timer.sleep( 0.4)
  world:destroy( )
  love.load()
end

function love.load()

  globals.METERSCALE = 1.6
  globals.GRAVITY = 1000
  love.physics.setMeter(globals.METERSCALE)
  text = "no collide"
  gameOver = false

  local tmp = 0
  tmp1 = {}
  tmp1.first = 0
  tmp1.second = 0
  tmp1.third = 0

  dieSound = love.audio.newSource("flappy-bird-assets-master/audio/die.wav", "static")
  hitSound = love.audio.newSource("flappy-bird-assets-master/audio/hit.wav", "static")
  pointSound = love.audio.newSource("flappy-bird-assets-master/audio/point.wav", "static")
  wingSound = love.audio.newSource("flappy-bird-assets-master/audio/wing.wav", "static")

  local tmp_score = 0

  score_image = {}

  for i=0,9 do
    score_image[i] = love.graphics.newImage("flappy-bird-assets-master/sprites/" .. i ..".png")
  end

  gameObjects.player = {}
  gameObjects.player.x = 30
  gameObjects.player.y = 80
  gameObjects.player.rotation = 0
  gameObjects.player.score = 0

  world = love.physics.newWorld(0, globals.GRAVITY*globals.METERSCALE, true)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)


  gameObjects.player.image = love.graphics.newImage("flappy-bird-assets-master/sprites/yellowbird-midflap.png")
  gameObjects.player.body = love.physics.newBody( world, gameObjects.player.x, gameObjects.player.y, "dynamic" )
  gameObjects.player.shape = love.physics.newRectangleShape( 20, 20 )
  gameObjects.player.fixture = love.physics.newFixture(gameObjects.player.body,gameObjects.player.shape)
  --gameObjects.player.fixture:setFricion(2)
  --gameObjects.player.image = love.graphics.newImage("flappy-bird-assets-master/sprites/yellowbird-midflap.png")
--  pipe_height = love.math.random(100, 330)


  pipes = {}

  for i=1,6 do
    pipe_height = love.math.random(100, 330)
    uppipe_h = 500 - pipe_height - 140
    pipes[i] = makeObject(pipe_height, (i - 1) * 150,uppipe_h)
  end

end

-- Creating the pipes
function makeObject(pipe_height, x,uppipe_h)
    local pipe = {}
    pipe.bottom = {}
    pipe.up = {}
    pipe.bottom.image = love.graphics.newImage("flappy-bird-assets-master/sprites/pipe-green.png")
    pipe.up.image = love.graphics.newImage("flappy-bird-assets-master/sprites/pipe-green-up.png")

    image_h = pipe.up.image:getHeight()
    image_w = pipe.up.image:getWidth()

    local bodyType = "static"-- "static" or "dynamic"

    botpipe_y = 503 - pipe_height / 2

    pipe.bottom.body = love.physics.newBody(world, W + x, botpipe_y, bodyType) --x,y
    pipe.bottom.shape = love.physics.newRectangleShape(image_w,   pipe_height) --w,h
    -- attach shape to body
    pipe.bottom.fixture = love.physics.newFixture(pipe.bottom.body, pipe.bottom.shape)
    pipe.bottom.fixture:setUserData(objectType)
    pipe.bottom.fixture:setFriction(0)

    pipe.up.body = love.physics.newBody(world, W + x, 0 + uppipe_h / 2 , bodyType) --x,y
    pipe.up.shape = love.physics.newRectangleShape(image_w,   uppipe_h) --w,h
    -- attach shape to body
    pipe.up.fixture = love.physics.newFixture(pipe.up.body, pipe.up.shape)
    pipe.up.fixture:setUserData(objectType)
    pipe.up.fixture:setFriction(0)

    pipe.up.objectNumber = objectNumber


    function pipe.update()
        pipe.bottom.body:setX(pipe.bottom.body:getX() - 1)
        pipe.up.body:setX(pipe.up.body:getX() - 1)
        if (pipe.bottom.body:getX() < -20) then
          pipe.bottom.body:setX(W + 100)
          pipe.up.body:setX(W + 100)

      end
      if (pipe.bottom.body:getX() == 20) then
        gameObjects.player.score = gameObjects.player.score + 1
        tmp1.first = tmp1.first + 1
        pointSound:play()
      end
    end

    function pipe.draw()
      love.graphics.setColor(1,1,1,1)
      topLeftX, topLeftY, bottomRightX, bottomRightY = pipe.bottom.fixture:getBoundingBox()
      local bot_x, bot_y = pipe.bottom.body:getPosition()
      local up_x, up_y = pipe.up.body:getPosition()


      love.graphics.draw(pipe.bottom.image,
          bot_x - image_w / 2, bot_y - pipe_height / 2)
      love.graphics.draw(pipe.up.image,
          up_x - image_w / 2, -320 + uppipe_h)

    end

    return pipe
end

local function draw_player()
  love.graphics.setColor(1,1,1,1)
  local tmp_x, tmp_y = gameObjects.player.body:getPosition()
  love.graphics.draw(gameObjects.player.image,
    tmp_x - 13, tmp_y - 10,   gameObjects.player.rotation)
end


local function handleScore()
  -- I creared a feild for evey digit because i coudlnt fine a way to read a specific index of a number
  if tmp1.first > 9 then
    tmp1.first = 0
    tmp1.second = tmp1.second + 1
  end

  if tmp1.second > 9 then
    tmp1.second = 0
    tmp1.third = tmp1.third + 1
  end

  love.graphics.draw(score_image[tmp1.first],
    W/2, 30)

    if tmp1.second > 0 then
      love.graphics.draw(score_image[tmp1.second],
        W/2 - 23, 30)
    end
    if tmp1.third > 0 then
      love.graphics.draw(score_image[tmp1.third],
        W/2 - 46, 30)
    end



 end

function love.draw()
  love.graphics.draw(backImg)
  --love.graphics.draw(ground, 0, 500)
  tmp_x, tmp_y = gameObjects.player.body:getPosition()
  draw_player()

for i=1,#pipes do
  pipes[i].draw()
end

handleScore()

if gameOver == true then
    m = love.graphics.newImage("flappy-bird-assets-master/sprites/gameover.png")
    love.graphics.draw(m,  300, 250)
    if love.keyboard.isDown("space") then
      reset()
    -- press the up arrow key to set the ball in the air
    end
end

 love.graphics.draw(ground, 0, 500)
end

function love.update(dt)
  if gameOver == false then
    if gameObjects.player.body:getY() > 490 or gameObjects.player.body:getY() < 5  then
      hitSound:play()
      gameOver = true
    end
    world:update(dt)

    for i=1,#pipes do
      pipes[i].update(dt)
    end

    tmp = gameObjects.player.y

    if love.keyboard.isDown("space") then
      lvx,lvy = gameObjects.player.body:getLinearVelocity()
      gameObjects.player.body:setLinearVelocity(lvx,0)
      gameObjects.player.body:applyLinearImpulse(0, -1000050)
        wingSound:play()
    -- press the up arrow key to set the ball in the air
    end
    if love.keyboard.isDown("right") then
      gameObjects.player.body:setX(gameObjects.player.body:getX() + 1)
    end
    if love.keyboard.isDown("left") then
      gameObjects.player.body:setX(gameObjects.player.body:getX() - 1)
    end
  end
end

function beginContact(a, b, coll)
  text = "collide"
  hitSound:play()
  gameOver = true
end
