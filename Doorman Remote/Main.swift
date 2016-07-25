//
//  Main.swift
//  Garage
//
//  Created by Andi Andreas on 7/12/16.
//  Copyright © 2016 Deplex. All rights reserved.
//

////  Streaming components made possible with much assistance from Jeff McFadden (http://jeff.mcfadden.io/articles/handling-motion-jpeg-streams-on-ios/ )

import UIKit
import LocalAuthentication

class Main: UIViewController {
    
    var metrics: [String: AnyObject] = [:]
    let manager = Manager()
    
    @IBOutlet weak var deniedAttemptsLabel: UILabel!
    @IBOutlet weak var lastOpenedLabel: UILabel!
    @IBOutlet weak var cam: MJPEGImageView!
    @IBOutlet weak var blur: UIVisualEffectView!
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        cam.onLoad = {
            UIView.animate(withDuration: 0.5) {
                self.blur.alpha = 0
            }
        }
        cam.stream(request: manager.prepareRequest(path: "/cam")!)
        let door = (metrics["lastOpenedDoor"] as! String).capitalized
        let user = metrics["lastOpenedBy"]!
        let timestamp = Double(metrics["lastOpenedAt"]!.stringValue)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, hh:mm"
        let time = formatter.string(from: Date(timeIntervalSince1970: timestamp))
        let deniedAttempts = metrics["deniedAttempts"]!
        lastOpenedLabel.text = "\(door) door opened by \(user) on \(time)"
        deniedAttemptsLabel.text = "\(deniedAttempts) denied authentication attempt(s)."
    }
    
    @IBAction func toggleRequested(_ sender: UIBarButtonItem) {
        let context = LAContext()
        if (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics
            , error: nil)) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Toggle Door", reply: { (success, error) in
                if (success) {
                    let request = self.manager.prepareRequest(path: "/toggle/\(sender.title!.lowercased())")
                    let task = URLSession.shared().dataTask(with: request!)
                    task.resume()
                }
            })
        }
    }
    
    func leaving() {
        cam.stop()
    }
}
