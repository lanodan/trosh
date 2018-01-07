function love.conf(t)
	t.title = "TROSH: The Movie: The Game"
	t.author = "Maurice"
	t.console = false
	
	t.screen = t.window
	t.screen.vsync = true
	t.screen.width = 800
	t.screen.height = 600
	t.screen.msaa = 16
end
function math.mod(a, b)
	return a % b
end
