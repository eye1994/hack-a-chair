# tt,tm,tb,bl,br

	# tt

	# tm

	# tb
 #  bl   br

require 'serialport'
require 'active_support'
require 'pry'
require 'mongoid'
require 'em-websocket'
require_relative 'utils'
require_relative 'reading'
require_relative 'notification'
require_relative 'message'

PERMITTED_RANGE = 10
ANGLE = 165..190
NOTIFICATION_PERIOD = 10

Mongoid.load!("mongoid.yml", :development)

port_str = '/dev/rfcomm0' 
baud_rate = 57600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
last_notification_time = Time.now
errors = {}

begin
  while true do
    while (data = sp.gets) do
      begin
        sensor_data = data.split(',')
      rescue ArgumentError
        next
      end
      time_now = Time.now

      top_back = sensor_data[0].to_i
      middle_back = sensor_data[1].to_i      
      bottom_back = sensor_data[2].to_i
      left_seat = sensor_data[3].to_i
      right_seat = sensor_data[4].to_i
      angle = sensor_data[5].to_i

      reading = {top_back: top_back, middle_back: middle_back, bottom_back: bottom_back, left_seat: left_seat, right_seat: right_seat, angle: angle}

      Reading.create(reading)
      back_errors = Utils.get_back_errors(top_back, middle_back, bottom_back)

      if back_errors.key(true)
        errors.merge!(back_errors)
      end

      seat_errors = Utils.get_seat_errors(left_seat, right_seat)
      if seat_errors.key(true)
        errors.merge!(seat_errors)
      end

      unless ANGLE.include? angle
        puts "angle error! #{angle}"
      end

      score = Utils.get_overall_score(sensor_data)

      if score >= 1 
        sit_time ||= time_now
        if (time_now - sit_time).to_i > 10
          stand_time = nil
          # Sitting
        end

        if (time_now - sit_time).to_i > 30
          # Sitting for 50 min
          take_a_break_time ||= time_now
          if (time_now - take_a_break_time).to_i > 30
            Notification.show_notification('Take 10', 'You\'ve been sitting for 50 minutes')
            take_a_break_time = time_now
          end
        end
      else
        stand_time ||= time_now
        if (time_now - stand_time).to_i > 10
          sit_time = nil
          # Standing
        end
      end
      if (time_now - last_notification_time).to_i > NOTIFICATION_PERIOD
        unless errors.empty?
          message = Message.posture_message(errors)
          Notification.show_notification('Error!', message)
          last_notification_time = time_now
        end
      end
    end
  end
rescue SystemExit, Interrupt
  sp.close
rescue Exception => e
  puts e.backtrace
  raise e
  sp.close
end