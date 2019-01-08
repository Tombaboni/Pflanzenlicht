-- Button.lua
local module = {}

-- init GPIO pin
local function button_init()
        gpio.mode(config.button_pin, gpio.INT, gpio.PULLUP)
        -- starte button listener
        gpio.trig(config.button_pin, "up", module.pin_cb)
        print("Button initialisiert")
end

-- define a callback function, "pin_cb" for "pin callback"
function module.pin_cb()
    print("Button Pressed")
    oled.print("Temp=" .. temp1, "Humidity=" .. hum1) 
   -- config.ledan = not config.ledan
   -- led.set(config.LedBlau, 1000)
   -- led.set(config.LedRot, 1000)
end

button_init()

return module
