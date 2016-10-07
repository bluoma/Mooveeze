//
//  JsonDownloader.swift
//  notables
//
//  Created by Bill on 10/3/16.
//  Copyright © 2016 BillLuoma. All rights reserved.
//

import Foundation

protocol JsonDownloaderDelegate: class {
    
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: Any?, response: HTTPURLResponse, error: NSError?)
    
}

class JsonDownloader {
    
    
    weak var delegate: JsonDownloaderDelegate? = nil
    
    func doDownload(urlString: String) -> URLSessionDataTask?
    {
        
        guard let url = URL(string: urlString) else {
            dlog("bad url: \(urlString)")
            return nil
        }
        
        dlog("in url: \(urlString)")

        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            var returnedError: NSError? = nil
            var json: Any? = nil
            var statusCode: Int = 0;
            var contentType: String = ""
            var httpResp: HTTPURLResponse! = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "1.1", headerFields: nil)
            
            
            if (response != nil) {
                httpResp = response as! HTTPURLResponse
                
                if (httpResp.allHeaderFields["Content-Type"] != nil) {
                    contentType = httpResp.allHeaderFields["Content-Type"] as! String
                }
                statusCode = httpResp.statusCode
                dlog("responseUrl: \(httpResp.url)")
                dlog("responseCode: \(statusCode)")
                
                for (hkey, hval) in httpResp.allHeaderFields {
                    
                    let skey: String = hkey as! String
                    let sval: String = hval as! String

                    dlog("header: \(skey)::\(sval)")
                }
            }
            
            if error != nil {
                dlog("error: \(error)")
                returnedError = error as? NSError
            }
            else if data != nil {
                if (contentType.contains("json")) {
                    do {
                        // Convert NSData to Dictionary where keys are of type String, and values are of any type
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                        
                    }
                    catch let jerr as NSError {
                        print("Error: \(jerr.domain)")
                        returnedError = jerr
                    }
                }
                else {
                    let errString = "contentType is not json: \(contentType)"
                    dlog(errString)
                    let err: NSError = NSError(domain: "mooveeze", code: -400, userInfo: nil)
                    returnedError = err
                }
            }
            else {
                dlog("both data and error are nil")
                returnedError = nil
            }
            
            DispatchQueue.main.async {
                self.delegate?.jsonDownloaderDidFinish(downloader: self, json: json, response: httpResp, error: returnedError)
            }
            
        })
        
        dataTask.resume()
        
        return dataTask
        
    }
    
    
}