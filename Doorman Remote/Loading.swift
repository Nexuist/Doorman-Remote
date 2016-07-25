//
//  Loading.swift
//  Garage
//
//  Created by Andi Andreas on 7/13/16.
//  Copyright © 2016 Deplex. All rights reserved.
//

import UIKit

class Loading: UIViewController {
    
    let manager = Manager.sharedInstance
    var show: ((UIAlertController) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show = { (alert: UIAlertController) in
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }
        // prepareRequest will return nil if credentials don't exist
        if let request = manager.prepareRequest(path: "/") {
            let task = URLSession.shared().dataTask(with: request, completionHandler: metadata)
            task.resume()
        }
        else {
            setCredentials()
        }
    }
    
    func setCredentials() {
        let alert = manager.configureAlert(completionHandler: { (UIAlertAction) in
            self.show(self.manager.reloadAlert(message: "Please exit and open the app again."))
        })
        self.show(alert)
    }
    
    func metadata(data: Data?, response: URLResponse?, error: NSError?) {
        if (error == nil && ((response as? HTTPURLResponse)?.statusCode == 200)) {
            DispatchQueue.main.async(execute: {
                do {
                    let metrics = try JSONSerialization.jsonObject(with: data!, options: [])
                    self.performSegue(withIdentifier: "continue", sender: metrics)
                 } catch {
                    self.show(self.manager.reloadAlert(message: "Couldn't parse metrics, please reload the app."))
                }
            })
        }
        else if ((response as? HTTPURLResponse)?.statusCode == 401) {
            setCredentials()
        }
        else {
            print("Data: \(data)")
            print("Response: \(response)")
            print("Error: \(response)")
            self.show(self.manager.reloadAlert(message: "Couldn't connect to server!"))
        }
    }
    
    @IBAction func configureRequested() {
        self.show(self.manager.configureAlert(completionHandler: nil))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! Main
        dest.metrics = sender! as! [String : AnyObject]
    }

}
