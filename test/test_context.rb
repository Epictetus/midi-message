#!/usr/bin/env ruby

require 'helper'

class ContextTest < Test::Unit::TestCase

  include MIDIMessage
  include TestHelper
   
  def test_note_off
    with(:channel => 0, :velocity => 64) do |context|
      msg = context.note_off(55)
      
      assert_equal(0, msg.channel)
      assert_equal(55, msg.note)
      assert_equal(64, msg.velocity)
      assert_equal([128, 55, 64], msg.to_a)
      assert_equal("803740", msg.to_bytestr)
    end
  end
  
  def test_note_on
    with(:channel => 0, :velocity => 64) do |context|
      msg = context.note_on(55)
      
      assert_equal(0, msg.channel)
      assert_equal(55, msg.note)
      assert_equal(64, msg.velocity)
      assert_equal([144, 55, 64], msg.to_a)
      assert_equal("903740", msg.to_bytestr)
    end  
  end  
  
  def test_control_change
    with(:channel => 2) do |context|
      msg = context.control_change(0x20, 0x30)
    
      assert_equal(msg.channel, 2)
      assert_equal(0x20, msg.index)
      assert_equal(0x30, msg.value)
      assert_equal([0xB2, 0x20, 0x30], msg.to_a)
      assert_equal("B22030", msg.to_bytestr)
    end    
  end
  
  def test_polyphonic_aftertouch
    with(:channel => 1) do |context|
    msg = context.polyphonic_aftertouch(0x40, 0x40)
      assert_equal(1, msg.channel)
      assert_equal(0x40, msg.note)
      assert_equal(0x40, msg.value)
      assert_equal([0xA1, 0x40, 0x40], msg.to_a)
      assert_equal("A14040", msg.to_bytestr)
    end      
  end  
  
  def test_program_change
    with(:channel => 3) do |context|
      msg = context.program_change(0x40)
      assert_equal(3, msg.channel)
      assert_equal(0x40, msg.program)
      assert_equal([0xC3, 0x40], msg.to_a)
      assert_equal("C340", msg.to_bytestr)
    end
  end
  
  def test_channel_aftertouch
    with(:channel => 3) do |context|
      msg = context.ChannelAftertouch(0x50)
      assert_equal(3, msg.channel)
      assert_equal(0x50, msg.value)
      assert_equal([0xD3, 0x50], msg.to_a)
      assert_equal("D350", msg.to_bytestr)
    end  
  end  
    
  def test_pitch_bend
    with(:channel => 0) do |context|
      msg = context.PitchBend(0x50, 0xA0)
      assert_equal(0, msg.channel)
      assert_equal(0x50, msg.low)
      assert_equal(0xA0, msg.high)
      assert_equal([0xE0, 0x50, 0xA0], msg.to_a)
      assert_equal("E050A0", msg.to_bytestr)
    end      
  end       
   
end