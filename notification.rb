require './os'

if Os.linux?
  require 'libnotify'
else 
  require 'terminal-notifier'
end

class Notification

  def self.show_notification(title, message)
    if Os.linux?
      Libnotify.show(
          :body    => message,
          :summary => title,
          :timeout => 1.5
      )
    elsif Os.mac?
      TerminalNotifier.notify(
        message,
        :title   => title
      )
    else
      raise NotImplemented
    end
  end
end

Notification.show_notification('dsdsds', 'dsdsds')
