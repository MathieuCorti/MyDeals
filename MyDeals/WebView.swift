//
//  WebView.swift
//  MyDeals
//
//  Created by Mathieu Corti on 8/22/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import UIKit
import WebKit

protocol SelectLinkDelegate: class {
    func didSelectImage(_ link: String)
    func didSelectDeal(_ link: String)
}

class WebView: UIViewController, UISearchBarDelegate, UIWebViewDelegate {
    
    var identifier : String = String()
    var link : String = "https://www.google.com.au"
    var searchEngine : String = "https://www.google.com.au/search?q="
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingBar: UIProgressView!
    
    weak var delegate: SelectLinkDelegate?
    
    var loading : Bool = false
    var loadingTimer : Timer = Timer()
    var webViewLoads : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // 1/2 Fix provided by @Joe for search bar color bug
        // https://stackoverflow.com/questions/40208982/mismatched-colors-on-uinavigationbar-and-uisearchbar
        //

        //To remove border and background colour on searchBar
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        //To apply border and background colour on searchBar
        searchBar.barTintColor = UIColor(red:0.99, green:0.17, blue:0.32, alpha:1.0)
        searchBar.layer.borderColor = UIColor(red:0.99, green:0.17, blue:0.32, alpha:1.0).cgColor

        // Fix grey bar
        automaticallyAdjustsScrollViewInsets = false;
        
        searchBar.delegate = self
        webView.delegate = self
        
        if identifier == "searchImage" {
            
            let useLink = UIBarButtonItem(title: "Use this image", style: .plain, target: self, action: #selector(useThisImage))
            navigationItem.rightBarButtonItem = useLink

        } else if identifier == "searchDeal" {

            let useDeal = UIBarButtonItem(title: "Use this deal", style: .plain, target: self, action: #selector(useThisDeal))
            navigationItem.rightBarButtonItem = useDeal
        }
        
        openTarget(targetUrl: link)
        
    }
    
    func useThisImage() {

        if let currentURL = webView.request?.url?.absoluteString {
            delegate?.didSelectImage(currentURL)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func useThisDeal() {
        
        if let currentURL = webView.request?.url?.absoluteString {
            delegate?.didSelectDeal(currentURL)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goBackward(_ sender: UIBarButtonItem) {
        webView.goBack()
    }

    @IBAction func goForward(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func stopLoading(_ sender: UIBarButtonItem) {
        webView.stopLoading()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        webViewLoads += 1

        if !loading {
        
            loadingBar.isHidden = false
            loadingBar.progress = 0
            loading = true
            loadingTimer = Timer.scheduledTimer(timeInterval: 0.10, target: self,
                                                selector: #selector(self.loadingTimerCallback),
                                                userInfo: nil, repeats: true)
        }
    }
    
    func loadingTimerCallback() {
        
        if !loading {

            if loadingBar.progress >= 1 {
              
                loadingBar.isHidden = true
                loadingTimer.invalidate()
        
            } else {
                loadingBar.progress += 0.2
            }

        } else {
            
            if loadingBar.progress >= 0.98 {

                loadingBar.progress = 0.98

            } else {
                
                loadingBar.progress += 0.02
            }

        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {

        webViewLoads -= 1
        if (webViewLoads <= 0) {
            loading = false
            webViewLoads = 0
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webViewLoads -= 1
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // Reset text
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()

        if var searchText = searchBar.text {
         
            searchText = searchText.replacingOccurrences(of: " ", with: "+")
            openTarget(targetUrl: searchEngine + searchText, quit: false)
        }
        
    }
    
    func openTarget(targetUrl: String, quit: Bool = true) {
        
        if let target = URL(string: targetUrl), UIApplication.shared.canOpenURL(target as URL) {
            
            let targetUrlRequest = URLRequest(url: target)
            webView.loadRequest(targetUrlRequest)
            
        } else if quit == true {
            
            _ = navigationController?.popViewController(animated: true)
            let alert = UIAlertController(title: "Failed open.", message: "The link is invalid.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
