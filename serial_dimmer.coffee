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
child_process = require 'child_process'

set_dimmer_value = (port_name) ->
  console.log "\n Opening the #{port_name} serial port"
  port = serial_port.SerialPort
  p = new port( port_name, { baudrate: 9600 } )
  p.on 'close', (data) ->
    console.log ' Closing the Arduino Serial Port'
  p.on 'open', ->
    properties = 
      {
        name: 'LED Level', 
        validator: /\d/,
        warning: 'Port must be a number',
        message: 'Enter a number between 0 and 255'
      }
    prompt.get properties, (err, result) ->
      p.write result
      p.close()
  p.on 'data', (data) ->
    console.log 'Data In: ' + data
  p.on 'error', (err) ->
    console.log '    ' + err.message

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
if process.platform != 'darwin'
  serial_port.list (err, ports) ->
    ports.forEach (port) ->
      port_info =  "[#{port_num}] #{port.comName} - #{port.pnpId} - #{port.manufacturer}"
      serial_ports.push {
        name: port.comName,
        display: port_info
      }
      port_num += 1
    select_port(serial_ports)
else
  child_process.exec 'ls /dev/tty.*', (err, stdout, stderr) ->
    console.log err unless err == null
    console.log stderr if stderr != ""
    stdout.split("\n").slice(0,-1).forEach (port) ->
      port_info = port
      serial_ports.push {
        name: port_info,
        display: "[#{port_num}] #{port_info}"
      }
      port_num += 1
    select_port(serial_ports)


