# Location Manager

I have laptops that I use in several different places.  I want to change things like barrier configs when moving locations.

If I am using a laptop in the living room, it should be able to control the PC on the TV.  If my laptop is in the office my gaming PC should be able to control it.

# Locations

## Living Room

Detection

  * Bluetooth or wifi scan?
      * `nmcli -f SSID,SIGNAL device wifi list`
      * LE not supported by all laptops
      * Add underpowered blackhole 2.4Ghz SSID to corner of house?
  * Put a docking station behind the charger cord?
      * Won't work for Eames

Tasks

  * Turn off all external monitors
  * Turn on living room TV
  * Barrier server starts for living room PC
      * Need to test running multiple barrier clients at once or make some sort of VIP

## Secondary Desk

Detection

  * USB ID of docking station

Tasks

  * Turn off all external monitors
  * Start barrier client pointing to gaming PC

## Primary Desk

Detection

  * USB ID of monitor

Tasks

  * Enable second monitor
  * Disable barrier
  * Start Hue sync?

# Other ideas

* Hyperion lighting?
* Set scenes in home assistant
