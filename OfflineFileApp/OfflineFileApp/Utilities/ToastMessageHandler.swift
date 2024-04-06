//
//  ToastMessageHandler.swift
//  OfflineFileApp
//
//  Created by VC on 05/04/24.
//

import Foundation

import UIKit

extension UIViewController {
    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.size.height-100, width: self.view.frame.size.width - 40 , height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 2
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

