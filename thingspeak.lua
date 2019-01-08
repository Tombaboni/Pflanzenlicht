-- Thingspeak
local module = {}

function module.post()
print("Temp:" .. temp1 .. " C\n")
print("Hum:" .. hum1 .. " %\n")
-- conection to thingspeak.com
print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,'184.106.153.149') 
conn:send("GET /update?key=" .. config.API_KEY .. "&field1=" .. (temp1) .. "&field2=" .. (hum1) .. "&field3=" .. tostring(ds18temp[2]) .. "&field4=" .. tostring(ds18temp[1]) .. " HTTP/1.1\r\n") 
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
                                print("Got disconnection...")
  end)
end



return module
