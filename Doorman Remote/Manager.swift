//
//  Manager.swift
//
//  Created by Andi Andreas on 7/15/16.
//  Copyright © 2016 Deplex. All rights reserved.
//
//
import UIKit

class Manager {

    static let sharedInstance = Manager()
    let get = { (key: String) in
        return UserDefaults.standard().string(forKey: key)
    }

    func prepareRequest(path: String) -> URLRequest? {
        if let server = get("server"), user = get("user"), key = get("key") {
            let url = URL(string: server + path)
            var request = URLRequest(url: url!)
            request.addValue(user, forHTTPHeaderField: "User")
            request.addValue(key, forHTTPHeaderField: "Key")
            return request
        }
        else {
            return nil
        }
    }

    func reloadAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Reload", message: message, preferredStyle: .alert)
        let quit = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(quit)
        return alert
    }

    func configureAlert(completionHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "Credentials", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Server Address"
            textField.text = UserDefaults.standard().string(forKey: "server")
        }
        alert.addTextField { (textField) in
            textField.placeholder = "User"
            textField.text = UserDefaults.standard().string(forKey: "user")
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Key"
            textField.isSecureTextEntry = true
            textField.text = UserDefaults.standard().string(forKey: "key")
        }
        let quit = UIAlertAction(title: "Cancel", style: .destructive, handler: completionHandler)
        let save = UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
            let fields = alert.textFields!
            UserDefaults.standard().set(fields[0].text, forKey: "server")
            UserDefaults.standard().set(fields[1].text, forKey: "user")
            UserDefaults.standard().set(fields[2].text, forKey: "key")
            completionHandler!(UIAlertAction)
        })
        alert.addAction(quit)
        alert.addAction(save)
        return alert
    }
}
