-- same as extraChar example but this follows a chart
--[[local leJson = parse_json('songs/bopeebo/chart-erect') -- parse_json starts in 'assets/'
local funny = Chart.new()
funny.load_chart(leJson, 'v_slice', 'nightmare') -- has second param for specifying the chart type (assumes legacy by default)

local char = Character.new(boyfriend.position + Vector2(240, -325), 'pico', true)
add_char(char)
char.chart = funny.load_chart(leJson, 'v_slice', 'nightmare') --funny.get_must_hits()

print(#char.chart)]]