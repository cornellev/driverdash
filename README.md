# Driver Dash 2023

_Jason Klein '26, Ari Kapelyan '25, Kalehiwot Dessalgne '25, Drew Wilenzick '26_

A very quick solution to a driver dashboard for competition in less than two weeks (!) The core components of the dashboard are (1) live statistics from the DAQ that allow it to communicate current speed and power consumption to the driver and (2) the ability to archive all sorts of data like GPS for later analysis. So that's all that we're going to try to do here.

Upon receiving properly-formatted TCP requests, the phone will make corresponding updates to the stats on the dashboard and will save the requests and their timestamps onto the device. Saved requests are stored in a format looking like

```jsonc
{
  "2023-03-26 23:22:02.709000": {
    "rpm": 300,
    "voltage": 24.1,
    "safety": 1
  },
  "2023-03-26 23:22:02.711000": {
    "rpm": 300,
    "voltage": 24.1,
    "safety": 1
  }
  // ...
}
```

You can find the saved files by opening the Files app on the phone and navigating to `On My iPhone > DriverDash`. There you should find two files, one called `back-daq.json` and one called `front-daq.json`. Note that, while the extension is `.json`, these aren't actually valid JSON files. the last comma needs to be replaced with a `}` in order for them to be valid JSON.

## Setup

_Since this is a native iOS app, it requires a Mac with XCode to build!_

1. Make sure that you have [cocoapods](https://guides.cocoapods.org/using/getting-started.html#installation) installed.
2. Navigate into the directory containing `Podfile` and run `pod install` from the terminal.
3. Run `open driver-dash-2023.xcworkspace` (not `.xcodeproj`)!

## Testing

_The server aspect of the app can only be tested when the app is run from a physical phone; it will not work in the Apple Simulator app!_

Assuming that the phone is connected to WiFi, you can find the phone's IP address by going to `Settings > WiFi > (i) next to connected network name > IP Address`, and the app will print to the console the port that the server will be running on (which should be `8080` because I hardcoded it). An IP address might look like `10.48.141.41`. When connected over cellular, the IP address is sometimes also aliased to `cev-telemetry-iphone.local`, which is quite convenient (`172.20.10.1` is also a good one to try). If that doesn't work, make sure that your laptop and the phone are connected to the same network and then run `arp -a` in a terminal. This will give you a bunch of IPs to try.

Due to constraints imposed by the ESP32s, we have switched from HTTP/WebSockets to raw TCP requests. The server on the phone is now a simple TCP server listening for requests in a `while true {}` loop on a different thread. Test the TCP server by setting the phone's current IP address for `IP_ADDRESS = ` in `test.py` and then running it. If all goes well, the dashboard should update with some new values and there should be new content in the `.json` files.
