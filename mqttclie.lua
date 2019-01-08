-- file : mqttclie.lua
local module = {}
m = nil

-- Sends Payload to broker
local function send_ping()
    m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0)
    m:publish(config.ENDPOINT .. "temp", temp1 ,0,0)
    m:publish(config.ENDPOINT .. "hum", hum1 ,0,0)
end

-- Sends my id to the broker for registration
local function register_myself()
    m:subscribe(config.ENDPOINT .. config.ID .. "/#",0,function(conn)
       print("Successfully subscribed to data endpoint")
    end)
end

local function handle_mqtt_error(conn, reason) 
  print("Failed to connect to mqtt-broker reason: " .. reason)
  oled.print("Failed to connect to mqtt-broker reason: ", reason)
end

local function mqtt_start()
    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
      endname = string.match(topic, config.ID .. '/(.*)')
      if endname == "luefter" and data == "1" then luefter.an()
      elseif endname == "luefter" and data == "0" then luefter.aus()
      elseif endname == "lichtmanuel" then   
                if config.lichtmanuel  then
                       config.lichtmanuel = true 
                else   config.lichtmanuel = false
               end 
      elseif endname == "ledblau" then
            led(config.LedBlau, data) 
      elseif endname == "ledrot" then
            led(config.LedRot, data)     
      end      
        -- do something, we have received a message
        print(topic .. ": " .. data)
        oled.print("Message:", data)
      end
    end)
    
    -- Connect to the Broker
        m:connect(config.HOST, config.PORT, 0, 1, function(con)       
        print("Connected to broker") 
        config.mqttconnected=1
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 60000, 1, send_ping)
    end, handle_mqtt_error)
    
end


function module.start()
  mqtt_start()
end

return module
