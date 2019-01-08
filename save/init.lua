--init pwm
config = require("config")
app = require("application")
oled = require("oled")
setup = require("setup")
bme = require("bme")
--button = require("button")
pumpe = require("pumpe")
led = require("led")
thingspeak = require("thingspeak")
dofile("Time in hours.lua");
setup.start()

luefter = require("luefter");
