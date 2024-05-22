local ball = require("ball")

-- Win values
local win_w = love.graphics.getWidth()
local win_h = love.graphics.getHeight()
local win_xoffset = win_w / 2
local win_yoffset = win_h / 2

-- Stack balls
local balls = {}

for i = 1, 30 do
  local r = 15
  local dist = (r * i) / 2
  local x = dist * math.cos(dist)
  local y = dist * math.sin(dist)

  local ball = ball:new(win_xoffset + x, win_yoffset + y, r)
  ball.color = {math.random(), math.random(), 0.7}

  table.insert(balls, ball)
end

local function collision_circle_cirlce(x1, y1, r1, x2, y2, r2)
  return math.abs((x1 - x2)^2 + (y1 - y2)^2) <= (r1+r2)*(r1+r2)
end

local function collision_circle_point(x1, y1, r1, x2, y2)
  return math.abs((x1 - x2)^2 + (y1 - y2)^2) <= (r1*r1)
end

local collsion_pairs = {}
local mouse_x = 0
local mouse_y = 0
local selected_ball = nil

function love.update(dt)
  mouse_x = love.mouse.getX()
  mouse_y = love.mouse.getY()

  -- Selected ball
  if love.mouse.isDown(1) then
    if not selected_ball then
      for i = #balls, 1, -1 do
        local ball = balls[i]
        if collision_circle_point(ball.x, ball.y, ball.r, mouse_x, mouse_y) then
          selected_ball = ball
          ball.selected = true
          break
        end
      end
    end
  end

  -- Select and move ball
  -- if love.mouse.isDown(1) then
  --   if selected_ball then
  --     selected_ball.x = mouse_x
  --     selected_ball.y = mouse_y
  --   end
  -- else
  --   if selected_ball then
  --     selected_ball.selected = false
  --     selected_ball = nil
  --   end
  -- end

  -- Add impuls
  if not love.mouse.isDown(1) then
    if selected_ball then
      selected_ball.vx = (selected_ball.x - mouse_x) * 2
      selected_ball.vy = (selected_ball.y - mouse_y) * 2

      selected_ball.selected = false
      selected_ball = nil
    end
  end

  -- Update position
  for i = #balls, 1, -1 do
    local ball = balls[i]

    -- Ball physics
    ball.ax = -ball.vx * ball.friction
    ball.ay = -ball.vy * ball.friction
    ball.vx = ball.vx + ball.ax * dt
    ball.vy = ball.vy + ball.ay * dt
    ball.x  = ball.x  + ball.vx * dt
    ball.y  = ball.y  + ball.vy * dt

    -- Wrap the balls around screen
    if (ball.x - ball.r < 0) then
      ball.vx = -ball.vx
    end
    if (ball.x + ball.r >= win_w) then
      ball.vx = -ball.vx
    end
    if (ball.y - ball.r < 0) then
      ball.vy = -ball.vy
    end
    if (ball.y + ball.r >= win_h) then
      ball.vy = -ball.vy
    end

    -- Clamp velocity near zero
    if (math.abs(ball.vx*ball.vx + ball.vy*ball.vy) < 0.01) then
      ball.vx = 0
      ball.vy = 0
    end
  end

  -- Collision balls
  collsion_pairs = {}
  for ci = #balls, 1, -1 do
    for ti = #balls, 1, -1 do
      local target = balls[ti]
      local ball   = balls[ci]

      if (ball ~= target) then
        if collision_circle_cirlce(ball.x, ball.y, ball.r, target.x, target.y, target.r) then
          collsion_pairs[ball] = target

          -- Distance beetwen ball center
          local distance = math.sqrt((ball.x - target.x)^2 + (ball.y - target.y)^2)
          local overlap  = (distance - ball.r - target.r) * 0.5

          -- Displace current ball
          ball.x = ball.x - overlap * (ball.x - target.x) / distance
          ball.y = ball.y - overlap * (ball.y - target.y) / distance

          -- Displace target ball
          target.x = target.x + overlap * (ball.x - target.x) / distance
          target.y = target.y + overlap * (ball.y - target.y) / distance
        end
      end
    end
  end

  for ball, target in pairs(collsion_pairs) do
    if target then
      -- Distance between balls
      local distance = math.sqrt((ball.x - target.x)^2 + (ball.y - target.y)^2)

      -- Normal
      local nx = (target.x - ball.x) / distance
      local ny = (target.y - ball.y) / distance

      -- Wikipedia Version - Maths is smarter but same
      local kx = (ball.vx - target.vx)
      local ky = (ball.vy - target.vy)
      local p = 2.0 * (nx * kx + ny * ky) / (ball.m + target.m)
      ball.vx = ball.vx - p * target.m * nx
      ball.vy = ball.vy - p * target.m * ny
      target.vx = target.vx + p * ball.m * nx
      target.vy = target.vy + p * ball.m * ny
    end
  end
end

function love.draw()
  love.graphics.setBackgroundColor(0.3, 0.3, 0.5)

  -- Draw balls
  for i = #balls, 1, -1 do
    balls[i]:draw()
  end

  for ball, target in pairs(collsion_pairs) do
    if target then
      love.graphics.setColor(1, 1, 1)
      love.graphics.setLineWidth(3)
      love.graphics.line(ball.x, ball.y, target.x, target.y)
      love.graphics.setLineWidth(1)
      love.graphics.setColor(1, 1, 1)
    end
  end

  if love.mouse.isDown(1) then
    if selected_ball then
      love.graphics.setColor(1, 1, 0)
      love.graphics.setLineWidth(3)
      love.graphics.line(selected_ball.x, selected_ball.y, mouse_x, mouse_y)
      love.graphics.setLineWidth(1)
      love.graphics.setColor(1, 1, 1)
    end
  end
end
