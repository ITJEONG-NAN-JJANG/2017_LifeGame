local M = {}
local widget = require "widget"
local json = require "json"
local sqlite3 = require "sqlite3"
local _W, _H = display.contentWidth, display.contentHeight

local path = system.pathForFile( "data.db", system.ApplicationSupportDirectory )

local statusBar, statusBar_content
local pop2, pop_bg2, pop_button2, pop_content2 -- 1 : myInfo / 2 : bag
local button_bag, button_myInfo

-- money hp maxHP weight attack int beauty luck
-- mirror book drink snack lamen steak
local userData =
{
	["money"] = 20000,
	["hp"] = 100,
	["maxHP"] = 100,
	["weight"] = 70,
	["attack"] = 0,
	["int"] = 0,
	["beauty"] = 0,
	["luck"] = 0,
	["mirror"] = 5,
	["book"] = 2,
	["drink"] = 3,
	["ramen"] = 2,
	["drink"] = 2,
	["snack"] = 2,
	["steak"] = 1,
	["type"] = 1,
	["name"] = "길동이",
	["state"] = 1
}

function M.getData(names)
	if userData[names] then return userData[names] end
end

function M.setData(names, n)
	if userData[names] and type(n) == 'number' then userData[names] = n end
	print( userData[names])
end

function showPop2(pop_type)
	local basicTop = _H*0.3875
	-- set button false
	button_bag:setEnabled( false )
	button_myInfo:setEnabled( false )

	-- create pop
	pop_bg2 = display.newRect( 0, 97, _W, _H-97 )
	pop_bg2.anchorX, pop_bg2.anchorY = 0, 0
	pop_bg2:setFillColor( 1, 1, 1, 0.5 )
	pop2 = display.newImage("image/popup.png", _W*0.5, _H*0.5 )
	pop2:scale(0.7, 0.7)

	pop_button2 = widget.newButton(
	{
		width = 43,
		height = 43,
		top = _H*0.3,
		left = pop2.x + pop2.contentWidth*0.5 - 44,
		top = pop2.y - pop2.contentHeight*0.5 + 2,
		defaultFile = "image/popup_button.png",
		overFile = "image/popup_button.png",
		onRelease = closePop
	})
	--print(pop.anchorX + pop.contentWidth*0.5 - 43)

	pop_content2 = {}

	if pop_type == 1 then --myInfo
		pop_content2[1] = display.newText( "내 정보", _W*0.5, _H*0.25, native.newFont( "NanumSquareB.ttf" ), 30 )
		pop_content2[1]:setFillColor( 0 )

		-- name
		pop_content2[2] = display.newText( "이름", _W*0.275, basicTop, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[2]:setFillColor( 0 )
		pop_content2[3] = display.newText( userData.name, _W*0.4, basicTop, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[3]:setFillColor( 0 )

		-- state
		pop_content2[4] = display.newText( "상태", _W*0.6, basicTop, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[4]:setFillColor( 0 )
		pop_content2[5] = display.newText( ( userData.hp <= 15 ) and "저체력" or ( ( userData.weight <= 40 ) and "저체중" or "정상" ), _W*0.7, basicTop, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[5]:setFillColor( 0 )


		-- hp/maxHP
		pop_content2[6] = display.newText( "현재 체력", _W*0.275, basicTop+_H*0.1, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[6]:setFillColor( 0 )
		pop_content2[7] = display.newText( userData.hp.."/"..userData.maxHP, _W*0.4, basicTop+_H*0.1, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[7]:setFillColor( 0 )

		-- weight
		pop_content2[8] = display.newText( "현재 체중", _W*0.6, basicTop+_H*0.1, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[8]:setFillColor( 0 )
		pop_content2[9] = display.newText( userData.weight, _W*0.7, basicTop+_H*0.1, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[9]:setFillColor( 0 )


		-- attack
		pop_content2[10] = display.newText( "현재 공격력", _W*0.275, basicTop+_H*0.2, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[10]:setFillColor( 0 )
		pop_content2[11] = display.newText( userData.attack, _W*0.4, basicTop+_H*0.2, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[11]:setFillColor( 0 )

		-- int
		pop_content2[12] = display.newText( "현재 지능", _W*0.6, basicTop+_H*0.2, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[12]:setFillColor( 0 )
		pop_content2[13] = display.newText( userData.int, _W*0.7, basicTop+_H*0.2, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[13]:setFillColor( 0 )


		-- beauty
		pop_content2[14] = display.newText( "현재 매력", _W*0.275, basicTop+_H*0.3, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[14]:setFillColor( 0 )
		pop_content2[15] = display.newText( userData.beauty, _W*0.4, basicTop+_H*0.3, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[15]:setFillColor( 0 )

		-- luck
		pop_content2[16] = display.newText( "현재 운", _W*0.6, basicTop+_H*0.3, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[16]:setFillColor( 0 )
		pop_content2[17] = display.newText( userData.luck, _W*0.7, basicTop+_H*0.3, native.newFont("NanumSquareB.ttf"), 25 )
		pop_content2[17]:setFillColor( 0 )
	elseif pop_type == 2 then --myBag
		-- beef
		pop_content2[1] = display.newImageRect( userData.steak == 0 and "image/button_beef.png" or "image/button_beef_c.png" , 100, 100 )
		pop_content2[1].x, pop_content2[1].y = _W*0.23, _H*0.3

		pop_content2[2] = display.newText( userData.steak.."개", pop_content2[1].x, pop_content2[1].y + 90, native.newFont( "NanumSquareB.ttf" ), 25 )
		pop_content2[2]:setFillColor( 0 )

		-- drink
		pop_content2[3] = display.newImageRect(  userData.drink == 0 and "image/button_drink.png" or "image/button_drink_c.png " , 60, 100 )
		pop_content2[3].x, pop_content2[3].y = _W*0.47, _H*0.3

		pop_content2[4] = display.newText( userData.drink.."개", pop_content2[3].x, pop_content2[3].y + 90, native.newFont( "NanumSquareB.ttf" ), 25 )
		pop_content2[4]:setFillColor( 0 )

		-- ramen
		pop_content2[5] = display.newImageRect( userData.ramen == 0 and "image/button_ramen_b.png" or "image/button_ramen.png", 100, 100 )
		pop_content2[5].x, pop_content2[5].y = _W*0.35, _H*0.3

		pop_content2[6] = display.newText( userData.ramen.."개", pop_content2[5].x, pop_content2[5].y + 90, native.newFont( "NanumSquareB.ttf" ), 25 )
		pop_content2[6]:setFillColor( 0 )

		-- snack
		pop_content2[7] = display.newImageRect( userData.snack == 0 and "image/button_snack.png" or "image/button_snack_c.png", 95, 100 )
		pop_content2[7].x, pop_content2[7].y = _W*0.575, _H*0.3

		pop_content2[8] = display.newText( userData.snack.."개", pop_content2[7].x, pop_content2[7].y + 90, native.newFont( "NanumSquareB.ttf" ), 25 )
		pop_content2[8]:setFillColor( 0 )

		-- mirror
		pop_content2[9] = display.newImageRect( userData.mirror == 0 and "image/button_mirror.png" or "image/button_mirror_c.png", 75, 100 )
		pop_content2[9].x, pop_content2[9].y = _W*0.23, _H*0.63

		pop_content2[10] = display.newText( userData.mirror.."개", pop_content[9].x, pop_content[9].y + 90, native.newFont( "NanumSquareB.ttf" ), 25 )
		pop_content2[10]:setFillColor( 0 )

		-- book
		pop_content[11] = display.newImageRect( userData.book == 0 and "image/button_book.png" or "image/button_book_c.png", 100, 100 )
		pop_content[11].x, pop_content[11].y = _W*0.34, _H*0.63

		pop_content[12] = display.newText( userData.book.."개", pop_content[11].x, pop_content[11].y + 90, native.newFont( "NanumSquareB.ttf" ), 25 )
		pop_content[12]:setFillColor( 0 )

	end
end

function closePop2()
	-- set button true
	button_bag:setEnabled( true )
	button_myInfo:setEnabled( true )

	-- remove pop
	pop:removeSelf( )
	pop_button:removeSelf( )
	pop_bg:removeSelf( )
	pop = nil
	pop_bg = nil
	pop_button = nil

	--remove popContent
	for i = 1, table.maxn(pop_content), 1 do
		pop_content[i]:removeSelf( )
		pop_content[i] = nil
	end
	pop_content = nil
end

function createUI()
	statusBar = display.newImage( "image/bg_statusbar.png" )
	statusBar.anchorX, statusBar.anchorY = 0, 0

	button_myInfo = widget.newButton(
	{
	    width = 97,
	    height = 96,
	    left = _W*0.81,
	    top = _H*0.005,
	    defaultFile = "image/button_myinf.png",
	    overFile = "image/button_myinfo.png",
	    onRelease = function() print("1") showPop2(1) end
	})
	button_myInfo:scale(0.8, 0.8)


	button_bag = widget.newButton(
	{
	    width = 97,
	    height = 96,
	    left = _W*0.9,
	    top = _H*0.005,
	    defaultFile = "image/button_bag.png",
	    overFile = "image/button_bago.png",
	    onRelease = function() print("2") showPop2(2) end
	})
	button_bag:scale(0.8, 0.8)

	statusBar_content2 = {}

	-- money
	statusBar_content[1] = display.newText( userData.money, _W*0.125, _H*0.065, native.newFont( "NanumSquareB.ttf" ), 23 )

	-- hp
	statusBar_content[2] = display.newText( userData.hp, _W*0.293, _H*0.0685, native.newFont( "NanumSquareB.ttf" ), 23 )

	-- weight
	statusBar_content[3] = display.newText( userData.weight, _W*0.387, _H*0.0685, native.newFont( "NanumSquareB.ttf" ), 23 )

	-- attack
	statusBar_content[4] = display.newText( userData.attack, _W*0.499, _H*0.0685, native.newFont( "NanumSquareB.ttf" ), 23 )

	-- int
	statusBar_content[5] = display.newText( userData.int, _W*0.592, _H*0.0685, native.newFont( "NanumSquareB.ttf" ), 23 )

	-- beauty
	statusBar_content[6] = display.newText( userData.beauty, _W*0.687, _H*0.0685, native.newFont( "NanumSquareB.ttf" ), 23 )

	-- luck
	statusBar_content[7] = display.newText( userData.luck, _W*0.763, _H*0.0685, native.newFont( "NanumSquareB.ttf" ), 23 )
end

function M.loadData()
	local file, errorString = io.open( path, "r" )
	if not file then
		print("load error : "..errorString)
	else
		local decoded, pos, msg = json.decodeFile( path )

		if not decoded then
			print("save progress")
		else
			userData.money = decoded.money
			userData.hp = decoded.hp
			userData.maxHP = decoded.maxHP
			userData.weight = decoded.weight
			userData.attack = decoded.attack
			userData.int = decoded.int
			userData.beauty = decoded.beauty
			userData.luck = decoded.luck
			userData.mirror = decoded.mirror
			userData.book = decoded.book
			userData.drink = decoded.drink
			userData.ramen = decoded.ramen
			userData.steak = decoded.steak
			userData.name = decoded.name
			userData.state = userData.state
		end
	end
end

function M.saveData()
	local file, errorString = io.open( path, "w" )

	local encoded = json.encode( userData )

	if not file then
		print("error : "..errorString)
	else
		file:write( encoded )

		io.close( file )
		print("Save Data Successful.");
	end

	file = nil
end

function M.init()
	-- create pop-up
	createUI()
end



return M