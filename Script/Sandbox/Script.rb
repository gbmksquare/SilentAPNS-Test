# This script is from Houston (https://github.com/nomad/houston)

require 'houston'

# Environment variables are automatically read, or can be overridden by any specified options. You can also
# conveniently use `Houston::Client.development` or `Houston::Client.production`.
APN = Houston::Client.development
APN.certificate = File.read("/Users/gbm/Downloads/DevApns.pem")

# An example of the token sent back when a device registers for notifications
token = "<4ac4748b 2bc454e2 8b0c552e 185acc5e b922ddb8 9a6a156a 5b5cf907 b7b0c17a>"

# Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
notification = Houston::Notification.new(device: token)
notification.alert = ""

# Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
notification.badge = 1
notification.sound = ""
notification.content_available = true
notification.custom_data = {identifier: "test"}

# And... sent! That's all it takes.
APN.push(notification)
puts "Error: #{notification.error}." if notification.error