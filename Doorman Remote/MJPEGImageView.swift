//
//  MJPEGImageView.swift
//  Garage
//
//  Created by Andi Andreas on 7/13/16.
//  Copyright © 2016 Deplex. All rights reserved.
//

import UIKit

class MJPEGImageView: UIImageView, URLSessionDataDelegate {
    var onLoad:((Void) -> Void)?
    var firstLoad: Bool = true
    var endMarker: Data = NSData(bytes: [0xFF, 0xD9] as [UInt8], length: 2) as Data
    var receivedData: NSMutableData!
    var task: URLSessionDataTask!
    
    func stream(request: URLRequest) {
        receivedData = NSMutableData()
        let session = URLSession(configuration: URLSessionConfiguration.default(), delegate: self, delegateQueue: nil)
        task = session.dataTask(with: request)
        task.resume()
        self.contentMode = .scaleToFill
    }
    
    func stop() {
        task?.cancel()
        firstLoad = true
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        let endRange:NSRange = receivedData.range(of: endMarker, options: [], in: NSMakeRange(0, receivedData.length))
        let endLocation = endRange.location + endRange.length
        if receivedData.length >= endLocation {
           let imageData = receivedData.subdata(with: NSMakeRange(0, endLocation))
            let receivedImage = UIImage(data: imageData)
            DispatchQueue.main.async(execute: {
                self.image = receivedImage
                if (self.firstLoad) {
                    self.onLoad?()
                    self.firstLoad = false
                }
            })
            receivedData = NSMutableData(data: receivedData.subdata(with: NSMakeRange(endLocation, receivedData.length - endLocation)))
        }
    }
    
    deinit {
        stop()
    }
}
