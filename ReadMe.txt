Program: LocateMe
Author: Robert Harder
Email: rob@iharder.net
Website: http://iharder.sourceforge.net

DESCRIPTION

Returns your computer's location using Apple's built-in geolocation services.


INSTALLATION

Copy the LocateMe file to a directory in your $PATH such as /usr/bin or possibly /usr/local/bin.


USAGE: 

LocateMe -h gives the following:

USAGE: LocateMe [options]
Version: 0.2
Outputs your current location using Apple's geolocation services.
  -h          This help message
  -g          Generate a Google Map URL
  -l          Generate long, multiline format
  -f format   Generate a custom output with the following placeholders
     {LAT}    Latitude as a floating point number
     {LON}    Longitude as a floating point number
     {ALT}    Altitude in meters as a floating point number
     {SPD}    Speed in meters per second as a floating point number
     {DIR}    Direction in degrees from true north as a floating point number
     {HAC}    Horizontal accuracy in meters as a floating point number
     {VAC}    Vertical accuracy in meters as a floating point number
     {TIME}   Timestamp (with date) of the location fix
     {HOST}   Computer hostname

Examples:

 Command: LocateMe -f "lat={LAT},lon={LON}"
 Output : lat=12.34567,lon=98.76543

 Command: LocateMe -f "<lat>{LON}</lat><lon>{LON}</lon><alt>{ALT}</alt>"
 Output : <lat>12.34567</lat><lon>98.76543</lon><alt>123</alt>


LICENSE:

This code is released into the Public Domain. Enjoy.
