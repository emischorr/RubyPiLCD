#!/usr/bin/env ruby

require 'pi_lcd'

lcd = PiLcd::Lcd.new
lcd.text "Hello"
lcd.cls
lcd.write_centered "Hello World"
lcd.next_line
lcd.text "2nd line"