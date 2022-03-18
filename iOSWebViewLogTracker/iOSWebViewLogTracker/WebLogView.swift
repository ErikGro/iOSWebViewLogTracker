//
//  WebLogView.swift
//  iOSWebViewLogTracker
//
//  Created by Erik Großkopf on 17.03.22.
//

import WebKit

enum LogLevel: String, CaseIterable {
    case standard, info, warn, error, debug
}

protocol WebViewLogDelegate: AnyObject {
    func log(message: WKScriptMessage, level: LogLevel, at url: URL?)
    func jsError(message: WKScriptMessage, at url: URL?)
}

class WebLogView: WKWebView, WKScriptMessageHandler {
    weak var logDelegate: WebViewLogDelegate?
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)

        self.injectLogTrackingScript()
    }
    
    init(frame: CGRect, configuration: WKWebViewConfiguration, logDelegate: WebViewLogDelegate) {
        super.init(frame: frame, configuration: configuration)
        
        self.logDelegate = logDelegate
        self.injectLogTrackingScript()
    }
    
    private func injectLogTrackingScript() {
        let logCaptureScript =
"""
window.addEventListener('error', e => {
    window.webkit.messageHandlers.jserror.postMessage({
            error: e.message,
            fileName: e.filename,
            lineNumber: e.lineno
    });
});

function captureStandardLog(msg) {
    window.webkit.messageHandlers.standard.postMessage(msg);
}

function captureInfoLog(msg) {
    window.webkit.messageHandlers.info.postMessage(msg);
}

function captureWarnLog(msg) {
    window.webkit.messageHandlers.warn.postMessage(msg);
}

function captureErrorLog(msg) {
    window.webkit.messageHandlers.error.postMessage(msg);
}

function captureDebugLog(msg) {
    window.webkit.messageHandlers.debug.postMessage(msg);
}

console.log.bind(window.console)
window.console.log = captureStandardLog;
window.console.info = captureInfoLog;
window.console.warn = captureWarnLog;
window.console.error = captureErrorLog;
window.console.debug = captureDebugLog;
"""
        let controller = configuration.userContentController
        controller.add(self, name: "jserror")
        LogLevel.allCases.forEach { controller.add(self, name: $0.rawValue) }
        let script = WKUserScript(source: logCaptureScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(script)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case LogLevel.standard.rawValue:
            self.logDelegate?.log(message: message, level: .standard, at: self.url)
        case LogLevel.info.rawValue:
            self.logDelegate?.log(message: message, level: .info, at: self.url)
        case LogLevel.warn.rawValue:
            self.logDelegate?.log(message: message, level: .warn, at: self.url)
        case LogLevel.error.rawValue:
            self.logDelegate?.log(message: message, level: .error, at: self.url)
        case LogLevel.debug.rawValue:
            self.logDelegate?.log(message: message, level: .debug, at: self.url)
        case "jserror":
            self.logDelegate?.jsError(message: message, at: self.url)
        default:
            break
        }
    }
}
