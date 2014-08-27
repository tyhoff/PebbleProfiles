## Pebble Profiles
1. If the iPhone is unlocked, suppress Pebble notifications. 
2. If the iPhone is locked, then send the notifications to Pebble.
3. Choose which applications send notifications to the Pebble.

> To receieve notifications from an application, notifications must be enabled in Settings->Notification Center AND in Pebble Profiles Settings.

Designed for Pebble, but should work with all Bluetooth 4.0 devices.

### Screenshots
![](http://i.imgur.com/ke9WOSr.png)
![](http://i.imgur.com/WmbYfsk.png)

### How I made it
- Decompiled using $class-dump ./BTLEServer > BTLEServer.h
	- class-dump can be here at http://stevenygard.com/projects/class-dump/ */
	- Run it on an x86 or 64-bit PC/MAC, not phone */

### What I discovered
BTLEServer is an executable located at `/usr/bin/btleserver` and it is in charge of the Bluetooth 4.0 communications.

BTServer is an executable located at `/usr/bin/btserver` and it is (probably) in charge of the Bluetooth <4.0 communications.


### Other Stuff
__This tweak is not affiliated with Pebble Technology in any way. It is a personal project and remains so.__