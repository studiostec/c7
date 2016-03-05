//
//  WebViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import WebKit
import Reachability

import RxSwift

class WebViewController: UIViewController, WKNavigationDelegate, Storyboardable {

    static internal let storyboardID = "WebViewController"

    private let bag = DisposeBag()
    private let webView = WKWebView()
    private let loadingIndicator = UIView()
    
    private var viewModel: WebViewModel!
    
    // MARK: create
    
    static func createWith(storyboard: UIStoryboard,
        url: NSURL) -> WebViewController {
            
        let vc = storyboard.instantiateViewControllerWithIdentifier(storyboardID) as! WebViewController
        vc.viewModel = WebViewModel(url: url)
        return vc
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //observe the progress
        viewModel.active = true
        
        //webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        //loadInitialURL()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //remove observer
//        webView.stopLoading()
//        webView.removeObserver(self, forKeyPath: "estimatedProgress")
//        
//        loadingIndicator.removeFromSuperview()
    }
    
    // MARK: setup UI
    
    func setupUI() {
        webView.frame = view.bounds
        webView.frame.size.height -= ((UIApplication.sharedApplication().windows.first!).rootViewController! as! UITabBarController).tabBar.frame.size.height
        webView.navigationDelegate = self
        view.insertSubview(webView, belowSubview: loadingIndicator)
        
        //setup loading indicator
        loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.15)
        loadingIndicator.userInteractionEnabled = false
        loadingIndicator.hidden = true
        navigationController?.navigationBar.addSubview(loadingIndicator)
    }

    // MARK: bind UI
    
    func bindUI() {
        
    }
    
    // MARK: private
    
    func loadInitialURL() {
        //TODO: use reachability service
        
//        //not connected message
//        let reach = Reachability(hostName: initialURL!.host)
//        if !reach.isReachable() {
//            //show the message
//            view.addSubview(MessageView(text: "It certainly looks like you are not connected to the Internet right now..."))
//            
//            //show a reload button
//            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "loadInitialURL")
//            
//            return
//        }

        MessageView.removeViewFrom(view)
        navigationItem.rightBarButtonItem = nil
        
        //load the target url
//        let request = NSURLRequest(URL: initialURL!)
//        webView.loadRequest(request)
//        setLoadingIndicatorAnimating(true)
    }
    
    func setLoadingIndicatorAnimating(animating: Bool) {
        loadingIndicator.hidden = !animating
        if animating {
            loadingIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: navigationController!.navigationBar.bounds.size.height)
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            
            if loadingIndicator.hidden {
                loadingIndicator.hidden = false
            }
            
            self.title = webView.title ?? webView.URL?.absoluteString
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
                self.loadingIndicator.frame = CGRect(
                    x: 0, y: 0,
                    width: self.navigationController!.navigationBar.bounds.size.width * CGFloat(self.webView.estimatedProgress),
                    height: self.navigationController!.navigationBar.bounds.size.height)

                }, completion: {_ in
                    if self.webView.estimatedProgress > 0.95 {
                        mainQueue {
                            //hide the loading indicator
                            UIView.animateWithDuration(0.2, animations: {
                                self.loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.15)
                            }, completion: {_ in
                                self.setLoadingIndicatorAnimating(false)
                                self.loadingIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.15)
                            })
                            
                        }
                    }
            })
            
        }
    }
    
}
