##Pebble Profiles

### What is it
If the iPhone is unlocked, suppress Pebble notifications. 
If the iPhone is locked, then send the notifications to Pebble.

Choose which applications should be able to send the ANCS devices notifications.

> To receieve notifications from an application, notifications must be enabled in Settings->Notification Center AND in Pebble Profiles Settings.

Should work with all Bluetooth 4.0 devices.


### How I made it
- Decompiled using $class-dump ./BTLEServer > BTLEServer.h
	- class-dump can be here at http://stevenygard.com/projects/class-dump/ */
	- Run it on an x86 or 64-bit PC/MAC, not phone */

### What I discovered
BTLEServer is an executable located at `/usr/bin/btleserver` and it is in charge of the Bluetooth 4.0 communications.

BTServer is an executable located at `/usr/bin/btserver` and it is (probably) in charge of the Bluetooth <4.0 communications.

