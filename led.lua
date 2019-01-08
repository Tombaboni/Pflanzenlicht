local module = {}
--initialise
local function initpwm()
    pwm.setup(config.LedBlau, 100, 0)
    pwm.setup(config.LedRot, 100, 0)
    pwm.start(config.LedBlau)
    pwm.start(config.LedRot)
end

--ermittle pwm Dauer anhand Start und Endzeit
function module.getPWM()
    local highnoon=(config.starttime+config.endtime)/2
    local param1 = -config.maxhue/(config.starttime-highnoon)^2
    local pwmdauerfunc= param1*(time-highnoon)^2+config.maxhue
    print("Light intensity(PWM):", math.max(pwmdauerfunc,0))
    return math.max(pwmdauerfunc,0)
end

function module.set(Ledpin, Pwmdauer)
    if not config.ledan then
        pwm.setduty(Ledpin, 0) 
    else
        pwm.setduty(Ledpin, Pwmdauer) 
    end
end

initpwm()

return module
