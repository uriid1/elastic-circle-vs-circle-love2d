--------------------------
-- Object ball prototype
--------------------------
local ball = {}
ball.__index = ball

function ball:new(x, y, r)
  local obj = setmetatable({}, self)

  obj.x = x
  obj.y = y
  obj.r = r or 30
  obj.vx = 0
  obj.vy = 0
  obj.ax = 0
  obj.ay = 0
  obj.m = obj.r * 10
  obj.friction = (obj.m * 9.8) / 2000
  obj.selected = false
  obj.color = {1, 1, 1}

  return obj
end

function ball:draw()
  love.graphics.setColor(self.color)
  if self.selected then
    love.graphics.setColor(1, 1, 1)
  end

  love.graphics.circle("fill", self.x, self.y, self.r)
  love.graphics.setColor(1, 1, 1)

  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(2)
  love.graphics.circle("line", self.x, self.y, self.r)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0, 0, 0)
end

return ball
