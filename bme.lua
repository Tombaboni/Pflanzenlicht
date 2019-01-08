-- bme Sensor 
local module = {}

-- initialisiere BME sensor
local function bme_init()
        i2c.setup(0, config.sda, config.scl, i2c.SLOW) -- call i2c.setup() only once
        bme280.setup()
        print("BME280 initialisiert")
end

-- Liest bme280 aus 
function module.read()
    T, P, H, QNH = bme280.read(config.alt)
    local Tsgn = (T < 0 and -1 or 1); T = Tsgn*T
    print("Temp:", T/100, "Pressure:",P/1000, "Humidity:", H/1000)
    temp1=string.format("%s%d.%02d", Tsgn<0 and "-" or "", (T/100)-2, T%100)
    hum1=(string.format("%d.%03d%%", (H/1000)+13, H%1000))
end

temp1=""
hum1=""
bme_init()

return module
