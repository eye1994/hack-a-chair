require './os'
class Notification

  def send(title, message, link = nil, picture= nil)
    if Os.mac?
      exec(build_mac_notification(title, message, link, picture))
    elsif Os.linux?
      exec(build_ubuntu_notification(title, message, picture))
    elsif Os.windows?
      exec(build_win_notification(title, message))
    end
  end

  def build_mac_notification(title, message, link = nil, picture = nil)
    command = "terminal-notifier -title #{title} -message #{message} "
    if link
      command += "-open #{link} "
    end
    if picture
      command += "-contentImage #{picture}"
    end
  end

  def build_ubuntu_notification(title, message, picture = nil)
    command = "notify-send #{title} #{message} "
    if picture
      command += "--icon #{picture}"
    end
  end

  def build_win_notification(title, message)
    command = "notify-send.exe #{title} #{message} "
  end

end

#absolute url for images
#for ubuntu local image mandatory, does not work well for remote pictures
#images don't work in win, at least not for now

a = Notification.new
# a.send('Hack-A-Chair', 'Whatever', 'http://google.com', 'http://alturl.com/wjdmg')
# a.send('Hack-A-Chair', 'Whatever', 'http://google.com', '/home/lavinia/projects/hack-a-chair/test.ico')
# a.send('Hack-A-Chair', 'Whatever')