# Driver Dash 2023: Setup

**IP Addresses.** The DAQ and LORD Pi communicate with the phone by connecting to the phone's hotspot and then accessing servers open at different ports (`8080` and `8081`) at the phone's IP address. While all of the code worked okay here in Ithaca, it's possible that the phone may have a new IP address when connected to cellular at competition because it's using different cell towers or something (the fact that I haven't taken Computer Networking really shows). You can tell when this happens because (a) LORD and DAQ won't connect when they are booted up and (b) running the app in debug mode while connected to a laptop with Xcode (i.e. hitting the Xcode run button) will print errors to the console and not say that it's listening on certain addresses.

To fix this, connect to the phone's hotspot on a computer, enter the terminal, and run `arp -a`. This will give a list of all the IP addresses on the current network (which is the phone's hotspot). Connect the phone to the computer, open this Xcode project, and, for each IP address resulting from the `arp -a` command, change the value of the `ip` variable in `DriverDash.swift` and rebuild/upload until it doesn't error. Once you have a working IP address, you'll want to update the one on the Pi (ssh into it and then change it in the file `/home/cev/test_gnss_data_new.py`) and the one on the Arduino. Call Jason or Ari with questions on how to do this part.

## LORD Setup

- make sure that the pi has power
- make sure that the phone hotspot is enabled
- wait for the LORD indicator to turn green

note that there's a bug and the LORD indicator light won't turn red on disconnect if it had previously turned green. Swipe up on the app and rerun to fix.

## DAQ Setup

- make sure that the phone hotspot is enabled
- restart the app (swipe up and re-open)
- press the reset button if the indicator hasn't yet turned green
