module ApplicationCable
  class State
    def initialize subject, channel, path = nil
      @channel = channel
      @subject = subject
      @path = path
    end


    def transmit action, data
      message = {path: @path, action: action}.compact
      if @subject
        @channel.broadcast_to @subject, message.merge(data: data)
      else
        @channel.transmit message.merge(data: data)
      end
    end

    def set value
      transmit :set, value
    end

    def assign value
      transmit :assign, value
    end

    def upsert value, key = 'id'
      transmit :upsert, key: key, value: value
    end

    def delete value
      transmit :delete, value
    end

    def method_missing method, data
      transmit method, data
    end
  end

  class ScopedChannel
    def initialize channel, subject
      @channel = channel
      @subject = subject
    end

    def state(*path)
      State.new(@subject, @channel, path.join('.'))
    end
  end

  class Channel < ActionCable::Channel::Base
    public :transmit

    def self.[](subject)
      ScopedChannel.new(self, subject)
    end

    def state(*path)
      State.new(nil, self, path.join('.'))
    end
  end
end
