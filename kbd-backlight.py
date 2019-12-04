#!/usr/bin/env python3

import dbus

bus = dbus.SystemBus()
kbd_backlight_proxy = bus.get_object('org.freedesktop.UPower',
                                     '/org/freedesktop/UPower/KbdBacklight')
kbd_backlight = dbus.Interface(kbd_backlight_proxy,
                               'org.freedesktop.UPower.KbdBacklight')
current = kbd_backlight.GetBrightness()
maximum = kbd_backlight.GetMaxBrightness()
