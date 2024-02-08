//
//  Utilities.swift
//  Instagram
//
//  Created by Ajin on 03/02/24.
//

import Foundation
import UIKit

func createAlert(for context: UIViewController, with title: String, having messgae: String){
    let alert = UIAlertController(title: title, message: messgae, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
        context.dismiss(animated: true)
    }))
    context.present(alert, animated: true)
}

func createActivityIndicator(for context: UIViewController) -> UIActivityIndicatorView{
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    activityIndicator.center = context.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = .medium
    context.view.addSubview(activityIndicator)
    return activityIndicator
}
