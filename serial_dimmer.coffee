# 
# My Dimmer
#
# A sample coffeescript that lists the serial ports and allows the user to 
# select one. It then allows the user to send a dimmer value betweeen 0 and 
# 255 to the arduino board.
#
# Created by Ed Botzum

serial_port = require 'serialport'
prompt = require 'prompt'

set_dimmer_value = (port_name) ->
  console.log "\n Setting dimmer value for #{port_name}"
  # TODO Prompt the user for a number and send it to the arduino.

select_port = (ports) ->
  console.log 'Available Serial Ports:'
  ports.forEach (port) ->
    console.log '  ' + port['display']

  properties = 
    {
      name: 'port', 
      validator: /\d/,
      warning: 'Port must be a number',
      message: 'Arduino Port'
    }

  prompt.start()
  prompt.get properties, (err, result) ->
    set_dimmer_value ports[result.port]['name']

# get the available ports
serial_ports = []
port_num = 0
serial_port.list (err, ports) ->
  ports.forEach (port) ->
    port_info =  "[#{port_num}] #{port.comName} - #{port.pnpId} - #{port.manufacturer}"
    serial_ports.push {
      name: port.comName,
      display: port_info
    }
    port_num += 1
   select_port(serial_ports)

