# Tracking console.log and java script errors in WKWebViews
The source for the logger WKWebView subclass is located in `iOSWebViewLogTracker/iOSWebViewLogTracker/WebLogView.swift`.\
In order to track console.logs in the webview, you have to implement the `WebViewLogDelegate`.\
Start a simple node server in `./demoserver` to check your implementation.

## Start demoserver
```
cd demoserver
npm i
npm start
```
