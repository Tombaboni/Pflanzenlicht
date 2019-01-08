
local module = {}

function oled_init() --Set up the u8glib lib
     sla = 0x3C
     i2c.setup(0, config.sda, config.scl, i2c.SLOW)
     disp = u8g.ssd1306_128x32_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     disp:setRot180()           -- Rotate Display if needed
    
     oledtimer = tmr.create()
     oledtimer:register(config.oleddauer, tmr.ALARM_SEMI, function() disp:sleepOn() end)
     print("Oled-Display initialisiert")
     module.print()
end

function module.print(string1, string2)
    disp:sleepOff()
    oledtimer:stop()
    oledtimer:start()
    disp:firstPage()
    if not (string1 == "" or string1 == nil) then str1=string1 end
    if not (string2 == "" or string2 == nil) then str2=string2 end
    repeat
     disp:drawFrame(2,2,126,30)
     disp:drawStr(5, 10, str1)
     disp:drawStr(5, 20, str2)
     disp:drawCircle(18, 47, 14)
   until disp:nextPage() == false
   
end

function module.start()
    -- Main Program 
    str1="Starting"
    str2="..."
    oled_init()
end

module.start()

return module
