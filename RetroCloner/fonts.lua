-- print scaled fonts
function FontsPrint(text, x, y, w, h, fnt, quality, paper, pen)
    love.graphics.push()
	love.graphics.setFont(fnt)
	love.graphics.scale(1.0 / quality, 1.0 / quality)
	r, g, b = GetPenRGB(paper)
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle("fill", x * quality, y * quality, (w + 2) * quality, (h + 2) * quality)
	r, g, b = GetPenRGB(pen)
	love.graphics.setColor(r, g, b)
	love.graphics.print(text, (x + 1) * quality, (y + 1) * quality)
    love.graphics.pop()
end

