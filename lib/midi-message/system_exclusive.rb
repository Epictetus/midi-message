#!/usr/bin/env ruby
#
#
module MIDIMessage

  module SystemExclusive

    # convert raw MIDI data to SysEx message objects
    def self.new(*bytes)
      return nil unless bytes.first.eql?(0xF0) && bytes.last.eql?(0xF7)
      
      fixed_length_message_part = bytes.slice!(0,7)
    
      manufacturer_id = fixed_length_message_part[0]
      device_id = fixed_length_message_part[1]
      model_id = fixed_length_message_part[2]
      msg_class = case fixed_length_message_part[3]
        when 0x11 then Request
        when 0x12 then Message
      end
      address = fixed_length_message_part.slice(4,3)
      checksum = bytes.slice!((bytes.length - 1), 1)
      value = bytes
    
      node = MIDIMessenger::SysEx::Node.new(manufacturer_id, model_id, :device_id => device_id)
      msg_class.new(address, value, :checksum => checksum, :node => node)
    end
  
    # basic SysEx data that a message class will contain
    module Data
    
      attr_reader :address,
                  :checksum,
                  :device

      StartByte = 0xF0
      EndByte = 0xF7
    
      # an array of message parts.  multiple byte parts will be represented as an array of bytes
      def to_a
        array
      end
    
      # a flat array of message bytes
      def to_byte_array
        array.flatten
      end
    
      private
    
      def address_to_i
        address.inject { |a,b| a + b }
      end
    
      def value_to_i
        value.kind_of?(Array) ? value.inject { |a,b| a + b } : value
      end
    
      def initialize_sysex(address, options = {})
        @node = options[:node]
        @checksum = options[:checksum]
        @address = address
      end

      def array
        # this may need to be cached when properties are updated
        # might be worth benchmarking
        @checksum = (128 - (address_to_i + value_to_i).divmod(128)[1])
        [
          StartByte,
          @node.manufacturer,
          (@device_id || @node.device_id),
          @node.model_id,
          status_byte,
          address,
          value,
          @checksum,
          EndByte
        ]
      end
    
    end
  
    # A SysEx command message
    #
    class Command
    
      include Data
    
      attr_reader :data

      StatusByte = 0x12
    
      def initialize(address, data, options = {})
        @data = data
        initialize_sysex(address, options)
      end
    
      def value
        @data
      end
    
      def data=(val)
        @data = val
        update_byte_array
      end
    
    end

    #
    # The SystemExclusive::Node represents a hardware synthesizer or other MIDI device that a message
    # is being sent to or received from.
    #
    class Node
    
      attr_accessor :device_id # (Not to be confused with any kind of Device class in this library)
      attr_reader :manufacturer, :model_id
    
      def initialize(manufacturer, model_id, options = {})
        @device_id = options[:device_id]
        @model_id = model_id
        @manufacturer = manufacturer
      end
    
      def message(*a)
        a << { :node => self }
        Command.new(*a)
      end
    
    end
  
    # A SysEx request message
    #
    class Request
    
      include Data
    
      attr_accessor :size
      alias_method :value, :size

      StatusByte = 0x11
    
      def initialize(address, size, options = {})
        @size = size
        initialize_sysex(address, options = {})
      end
    
    end
  
  end

end