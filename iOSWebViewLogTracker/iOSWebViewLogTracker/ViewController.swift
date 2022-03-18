//
//  ViewController.swift
//  iOSWebViewLogTracker
//
//  Created by Erik Großkopf on 17.03.22.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    private let webview = WebLogView(frame: .zero, configuration: WKWebViewConfiguration())
    
    private let searchBar: UITextField = {
        let searchBar = UITextField(frame: .zero)
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.spellCheckingType = .no
        searchBar.layer.cornerRadius = 8
        searchBar.layer.borderColor = UIColor.darkGray.cgColor
        searchBar.layer.borderWidth = 1
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        searchBar.leftView = paddingView
        searchBar.leftViewMode = .always
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let initialURL = URL(string: "http://localhost:8080/")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(webview)
        self.view.addSubview(searchBar)
        
        self.setupViews()
        
        self.webview.logDelegate = self
        
        // Initial request
        let myRequest = URLRequest(url: initialURL)
        self.webview.load(myRequest)
    }
    
    private func setupViews() {
        searchBar.addTarget(self, action: #selector(enterPressed), for: .editingDidEndOnExit)
        searchBar.text = initialURL.absoluteString
        
        webview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            searchBar.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            
            webview.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 8),
            webview.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webview.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            webview.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc
    func enterPressed(){
        searchBar.resignFirstResponder()
        
        guard var text = self.searchBar.text?.lowercased() else { return }
        
        if !text.starts(with: "http") {
            text = "https://" + text
        }

        guard let url = URL(string: text) else { return }

        webview.load(URLRequest(url: url))
    }
}

extension ViewController: WebViewLogDelegate {
    func log(message: WKScriptMessage, level: LogLevel, at url: URL?) {
        if let url = url?.absoluteString {
            print("LOG \(level.rawValue): '\(message.body)' - at \(url)")
        } else {
            print("LOG \(level.rawValue): '\(message.body)'")
        }
    }
    
    func jsError(message: WKScriptMessage, at url: URL?) {
        if let url = url?.absoluteString {
            print("JS ERROR: '\(message.body)' - at \(url)")
        } else {
            print("JS ERROR: '\(message.body)'")
        }
    }
}
