//
//  FilePreviewViewController.swift
//  OfflineFileApp
//
//  Created by VC on 05/04/24.
//

import UIKit
import WebKit

class FilePreviewViewController: UIViewController {
    
    //MARK: - IBOutlet's
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var imgPreviewView: UIImageView!
    @IBOutlet weak var docPreviewView: UIView!
    
    //MARK: - Variable Declarations
    
    var selectedFile: File?
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMethods()
    }
    
    //MARK: - Functions
    
    func setupMethods(){
        self.navigationItem.hidesBackButton = true
        if let file = selectedFile{
            headerLbl.text = file.name
            if file.type == "Image"{
                self.imgPreviewView.isHidden = false
                self.docPreviewView.isHidden = true
                self.imgPreviewView.image = UIImage(data: file.imageData)
            }else if file.type == "Zip" || file.type == "Others"{
                self.imgPreviewView.isHidden = true
                self.docPreviewView.isHidden = true
                self.showToast(message: "Unable to preview, Unsupported fie format")
            }
            else{
                self.imgPreviewView.isHidden = true
                self.docPreviewView.isHidden = false
                //using string
                if let documentURL = URL(string: file.path) {
                    let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.docPreviewView.bounds.width, height: self.docPreviewView.bounds.height))
                    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    webView.load(URLRequest(url: documentURL))
                    self.docPreviewView.addSubview(webView)
                }
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func didClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
