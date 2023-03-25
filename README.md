# Driver Dash 2023

_Jason Klein '26, Ari Kapelyan '25, Kalehiwot Dessalgne '25, Drew Wilenzick '26_

A very quick solution to a driver dashboard for competition in less than two weeks (!) The core components of the dashboard are (1) live statistics from the DAQ that allow it to communicate current speed and power consumption to the driver and (2) the ability to archive all sorts of data like GPS for later analysis. So that's all that we're going to try to do here.

Below is the JSON communication scheme (developed in coordination with Ari) used for communicating between the DAQ and the phone.

## Setup

_Since this is a native iOS app, it requires a Mac with XCode to build!_

1. Make sure that you have [cocoapods](https://guides.cocoapods.org/using/getting-started.html#installation) installed.
2. Navigate into the directory containing `Podfile` and run `pod install` from the terminal.
3. Run `open driver-dash-2023.xcworkspace` (not `.xcodeproj`)!

## Testing

_The server aspect of the app can only be tested when the app is run from a physical phone; it will not work in the Apple Simulator app!_

Assuming that the phone is connected to WiFi, you can find the phone's IP address by going to `Settings > WiFi > (i) next to connected network name > IP Address`, and the app will print to the console the port that the server will be running on (which should be `8080` because I hardcoded it). An IP address might look like `10.48.141.41`. Wherever I use this in the following snippets, replace the actual IP address of the phone.

To test that the HTTP server is up and running, open the app on the phone and run `curl 10.48.141.41:8080/ping` on a terminal on a computer connected to the same WiFi network. If all goes well, it should reply with "pong".

To test that the WebSockets can update the dashboard values, open the JavaScript console in a browser and type

```js
ws = new WebSocket("ws://10.48.141.41:8080/websocket");
ws.send(JSON.stringify({ type: "speed", data: 10 }));
```

where the content of `JSON.stringify()` matches the format of what the DAQ will be sending to the WebSocket. This should update the dashboard value to show a speed of `10.00`!
