-- luefter.lua file
local module = {}

--initialise
local function luefter_init()
     gpio.mode(config.luefter, gpio.OUTPUT)
     gpio.write(config.luefter, gpio.LOW)
     -- Timer der nach 5 Minuten den Luefter wieder abschaltet
     lueftertimer = tmr.create()
     lueftertimer:register(config.luefterdauer, tmr.ALARM_SEMI, function()
            gpio.write(config.luefter, gpio.LOW) 
            print("Lüfter gestoppt")
            end)
     print("Lüfter initialisiert")
end

--  Startet Lüfter
function module.an()
        gpio.write(config.luefter, gpio.HIGH)
        lueftertimer:stop()
        lueftertimer:start()
        print("Lüfter startet")
end

--  Stoppe Lüfter
function module.aus()
        gpio.write(config.luefter, gpio.LOW)
        print("Lüfter gestoppt")
end


luefter_init()

--package.loaded['luefter']=nil

return module
