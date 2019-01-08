-- file : application.lua
local module = {}
m = nil

-- Sends Payload to broker
local function send_ping()
    m:publish(config.ENDPOINT .. config.ID .. "/temp", temp1 ,0,0)
    m:publish(config.ENDPOINT .. config.ID .. "/hum", hum1 ,0,0) 
    m:publish(config.ENDPOINT .. config.ID .. "/templed", ds18temp[2] ,0,0) 
    m:publish(config.ENDPOINT .. config.ID .. "/tempwater", ds18temp[1] ,0,0) 
    m:publish(config.ENDPOINT .. config.ID .. "/ledmanuel", (ledmanuel or 0) ,0,0)
end

-- Sends my id to the broker for registration
local function register_myself()
    m:subscribe(config.ENDPOINT .. config.ID .. "/#",0,function(conn)
    m:publish(config.ENDPOINT .. config.ID .. "/connected", 1 ,0,0)
    print("Successfully subscribed to data endpoint")
    end)
end

local function handle_mqtt_error(conn, reason) 
  config.mqttconnected = false
  print("Failed to connect to mqtt-broker reason: " .. reason)
  oled.print("Failed to connect to mqtt-broker reason: ", reason)
end

local function mqtt_start()
    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        local endname = string.match(topic, config.ID .. '/(.*)')
        if endname == "luefter" then
                if data == "1" then luefter.an()
                else luefter.aus()
                end
        elseif endname ==  "pumpe" then
                if data == "1" then  pumpe.an()
                else pumpe.aus() 
                end               
        elseif string.match(topic, config.ID .. '/(.-)/' ) == "set" then
            local endname = config[(string.match(topic, 'set/(.*)'))]
            if data == "true" then config[endname] = true 
            elseif data == "false" then config[endname] = false
                if endname == "ledmanuel" then 
                    local pwmdauer = led.getPWM()
                    led.set(config.LedBlau, pwmdauer)
                    led.set(config.LedRot, pwmdauer)
                end
            elseif endname == "ledblau" then 
                led.set(config.LedBlau, data)
                config.ledmanuel = true     
            elseif endname == "ledrot" then 
                led.set(config.LedBlau, data)
                config.ledmanuel = true
            else config[(string.match(topic, 'set/(.*)'))] = data
            end
            oled.print("Topic:" .. endname,"Message:" .. data)
            print("set " .. string.match(topic, 'set/(.*)') .. " to " .. data)
        elseif endname == "get" then
            if (config[(data)] ~= '' or config[(data)] ~= nil) then
            m:publish(config.ENDPOINT .. config.ID .. data, config[(data)] ,0,0)
            else m:publish(config.ENDPOINT .. config.ID .. data, "null" ,0,0)
            end
        end  
        -- print recieved Message when recieved on set channel
        print("Message recieved " .. topic .. " : " .. data)       
      end
    end)
    
    -- Connect to the Broker
        m:connect(config.HOST, config.PORT, 0, 0, function(conn)       
        print("Connected to broker")
        config.mqttconnected=true
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 60000, 1, send_ping)
    end, handle_mqtt_error)
    
end

function module.start()
    mqtt_start()
    ds18b20.setup(config.owpin)
            
    bme.read()
    ds18b20.read(     function(ind,rom,res,temp,tdec,par)   ds18temp[ind]=temp  print("Temp ds18module " .. ind .. "= " .. ds18temp[ind])    end, {})     
    syncTime()
   -- mainroutine checke jede 60 sec die zeit und schalte Licht an oder aus
    tmr.alarm(0,60000, 1, function()
        time = getTime()
        print("Time =", time)
        if not config.mqttconnected then    mqtt_start()      end
        if not config.ledmanuel then
            local pwmdauer = led.getPWM()
            led.set(config.LedBlau, pwmdauer)
            led.set(config.LedRot, pwmdauer)
        
             if config.mqttconnected then
                     m:publish(config.ENDPOINT .. config.ID .. "/ledblau", pwmdauer ,0,0)
                     m:publish(config.ENDPOINT .. config.ID .. "/ledrot", pwmdauer ,0,0)
             end
        end
        bme.read()
        ds18b20.read(     function(ind,rom,res,temp,tdec,par)   ds18temp[ind]=temp  print("Temp ds18module " .. ind .. "= " .. ds18temp[ind])    end, {})     
        
        if time%100%30 == 0 then -- Alle halbe Stunde Lüfter an
                luefter.an() end

--if ds18temp[2] >= config.ledmaxtemp then 
--      luefter.an() end
                
        if time%5 == 0 then     -- poste to thingspeak alle 5 min
                thingspeak.post() end        
        
        if     time == 200  then   syncTime()
        elseif time == 730  then   pumpe.an()
        end                              
    end)
end

return module
