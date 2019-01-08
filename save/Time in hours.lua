

--sync time
function syncTime()
        tmr.alarm(1,900, 1, function()
            if wifi.sta.status() == 5 then
             sntp.sync()
             print("Time Synced")
             tmr.unregister(1)
            end
        end)           
end

    -- get time german timezone
function getTime()
   local utime = rtctime.get()+7200
   local tm = rtctime.epoch2cal(utime)
   local time = string.format("%02d%02d", tm["hour"],tm["min"])
    --print(string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
   return tonumber(time)
end
