//
//  WebPreviewVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 26/6/21.
//

import UIKit
import WebKit

class WebPreviewVC: BaseVC {
    
    private(set) var publicURL: URL
    private var webView = WKWebView()
    
    // MARK: Initialization
    init(with url: URL) {
        self.publicURL = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.addExclusiveConstraints(superview: view, top: (view.safeAreaLayoutGuide.topAnchor, 0), bottom: (view.bottomAnchor, 0), left: (view.leadingAnchor, 0), right: (view.trailingAnchor, 0))
        
        webView.load(URLRequest(url: publicURL))
    }
}
