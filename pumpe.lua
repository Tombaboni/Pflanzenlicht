-- Pumpe
local module = {}

--initialise
local function pumpe_init()
     gpio.mode(config.Pumpe, gpio.OUTPUT)
     gpio.write(config.Pumpe, gpio.HIGH)
     -- Timer der nach 5 Minuten den Luefter wieder abschaltet
     pumptimer = tmr.create()
     pumptimer:register(config.pumpdauer, tmr.ALARM_SEMI, function()
            gpio.write(config.Pumpe, gpio.HIGH) 
            print("Pumpe gestoppt")
            end)
     print("Pumpe initialisiert")
end

--  Startet Pumpe
function module.an()
        gpio.write(config.Pumpe, gpio.LOW)
        pumptimer:stop()
        pumptimer:start()
        print("Pumpe startet")
end

--  Stoppe Pumpe
function module.aus()
        gpio.write(config.Pumpe, gpio.HIGH)
        print("Pumpe gestoppt")
end

pumpe_init()

return module
