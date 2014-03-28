require "pi_lcd/version"
require 'pi_piper'

module PiLcd

  class Lcd
    PIN_RS = 23 # RegisterSelect true => char / flase => cmd
    PIN_EN = 24 # Enable

    PIN_D4 = 7
    PIN_D5 = 8
    PIN_D6 = 9
    PIN_D7 = 10

    MILLISECOND = 0.001
    CHAR_REGISTER = 1
    CMD_REGISTER = 0
    
    LINE_1 = 0x80 # LCD RAM address for the 1st line
    LINE_2 = 0xC0 # LCD RAM address for the 2nd line
    LINE_3 = 0x94 # LCD RAM address for the 3rd line
    LINE_4 = 0xD4 # LCD RAM address for the 4th line

    def initialize(size = 20)
      @pinRS = PiPiper::Pin.new(:pin => PIN_RS, :direction => :out)
      @pinEnable = PiPiper::Pin.new(:pin => PIN_EN, :direction => :out)

      @pinD4 = PiPiper::Pin.new(:pin => PIN_D4, :direction => :out)
      @pinD5 = PiPiper::Pin.new(:pin => PIN_D5, :direction => :out)
      @pinD6 = PiPiper::Pin.new(:pin => PIN_D6, :direction => :out)
      @pinD7 = PiPiper::Pin.new(:pin => PIN_D7, :direction => :out)

      init_display
      
      @columns = size
      @rows = 4
      @current_line = 1
      @char_count = 0
    end

    def init_display
      write_byte 0x33, CMD_REGISTER # function set (8bit)
      write_byte 0x32, CMD_REGISTER # function set (8bit)
      write_byte 0x28, CMD_REGISTER # function set (4bit)
      write_byte 0x0C, CMD_REGISTER # display on
      write_byte 0x06, CMD_REGISTER # entry mode set
      write_byte 0x01, CMD_REGISTER # cls
    end
    
    def init_display2
      sleep 15*MILLISECOND
      write_byte 0x30, CMD_REGISTER # function set (8bit)
      sleep 5*MILLISECOND
      write_byte 0x30, CMD_REGISTER # function set (8bit)
      sleep MILLISECOND
      write_byte 0x30, CMD_REGISTER # function set (8bit)
      write_byte 0x20, CMD_REGISTER # function set (4bit)
      write_byte 0x24, CMD_REGISTER # function set
      off
      cls
      write_byte 0b00000110, CMD_REGISTER
      on
    end

    def pulse_enable
      sleep MILLISECOND
      @pinEnable.on
      sleep MILLISECOND
      @pinEnable.off
      sleep MILLISECOND
    end

    def screen(text)
      cls
      text.scan(/.{1,#{@columns}}/).each { |line|
        write_string line
        next_line
      }
    end
    
    def write_centered(text, padstr=' ')
      return_line
      write_string text.center(@columns, padstr)
    end
    alias :centered :write_centered

    def write_right(text, padstr=' ')
      return_line
      write_string text.rjust(@columns, padstr)
    end
    alias :right :write_right

    def write_block(text, size, align)
      case align
      when "right"
        write_string text[0..size].rjust(size)
      when "center"
        write_string text[0..size].center(size)
      else # probably right
        write_string text[0..size].ljust(size)
      end
    end
    alias :block :write_block

    def write_string(text)
      text.to_s.each_char {|char|
        next_line if @char_count == @columns

        # byte = char.bytes.first.to_s(2)
        # while byte.length < 8
        #   byte = "0" + byte
        # end
        # bits = []
        # byte.each_char {|char| bits << char.to_i}

        # char.bytes.map_send(:to_s, 2).map_send(:rjust, 8, "0").map(&:to_i).each { |bits|
        #   write_byte(bits, CHAR_REGISTER)
        # }

        char.bytes.each { |bits|
          write_byte bits, CHAR_REGISTER
        }

        @char_count += 1
      }
    end
    alias :text :write_string
    
    def set_line(line_no)
      write_byte self.class.const_get('LINE_'+line_no.to_s), CMD_REGISTER
      @char_count = 0
      @current_line = line_no.to_i
    end

    def next_line
      @current_line == @rows ? @current_line=1 : @current_line+=1
      set_line @current_line
    end

    def write_byte(bits, register)
      bits = Array.new(8) {|i| bits[-i+7]} if bits.is_a? Fixnum
      
      if bits.is_a? Array
        # puts "bits: #{bits.to_s}"
        sleep MILLISECOND
        # high bits
        @pinRS.update_value register # set mode
        @pinD7.update_value bits[0]
        @pinD6.update_value bits[1]
        @pinD5.update_value bits[2]
        @pinD4.update_value bits[3]
        pulse_enable
        # low bits
        @pinRS.update_value register # set mode
        @pinD7.update_value bits[4]
        @pinD6.update_value bits[5]
        @pinD5.update_value bits[6]
        @pinD4.update_value bits[7]
        pulse_enable
      else
        raise ArgumentError, 'Argument is no Array or Fixnum'
      end
    end

    def cls
      write_byte 0b00000001, CMD_REGISTER
      @char_count = 0
      @current_line = 1
    end

    def return_home
      write_byte 0b00000010, CMD_REGISTER
      @char_count = 0
    end

    def return_line
      set_line @current_line
    end

    def on
      write_byte 0b00001100, CMD_REGISTER
    end

    def off
      write_byte 0b00001000, CMD_REGISTER
    end
  end

end

# module Enumerable
#   def map_send(*args)
#     map { |x| x.send(*args) }
#   end
# end
