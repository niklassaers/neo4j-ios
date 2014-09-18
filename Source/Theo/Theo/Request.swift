//
//  Request.swift
//  Cory D. Wiles
//
//  Created by Cory D. Wiles on 9/11/14.
//  Copyright (c) 2014 Theo. All rights reserved.
//

import Foundation

typealias RequestSuccessBlock = (data: NSData?, response: NSURLResponse) -> Void
typealias RequestErrorBlock   = (error: NSError, response: NSURLResponse) -> Void

let GSTNetworkErrorDomain: String = "com.graphstory.network.error"

public struct AllowedHTTPMethods {
  
  static var GET: String  = "GET"
  static var PUT: String  = "PUT"
  static var POST: String = "POST"
}

class Request: NSObject, NSURLSessionDelegate {
  
  lazy var httpSession: Session = {
    
    Session.SessionParams.delegate = self
    Session.SessionParams.queue = NSOperationQueue.mainQueue()
    
    return Session.sharedInstance;
  }()
  
  lazy var sessionConfiguration: NSURLSessionConfiguration = {
    return self.httpSession.configuration.sessionConfiguration
  }()
  
  lazy var sessionHTTPAdditionalHeaders: [NSObject:AnyObject]? = {
    return self.sessionConfiguration.HTTPAdditionalHeaders
  }()
  
  let sessionURL: NSURL
  
  private var httpRequest: NSURLRequest
  
  required init(url: NSURL?, additionalHeaders:[String:String]?) {
    
    self.sessionURL  = url!
    self.httpRequest = NSURLRequest(URL: self.sessionURL)
    
    super.init()
    
    if additionalHeaders != nil {

      var newHeaders: [String:String] = [:]

      if let sessionConfigurationHeaders = self.sessionHTTPAdditionalHeaders as? [String:String] {
      
        for (origininalHeader, originalValue) in sessionConfigurationHeaders {
          newHeaders[origininalHeader] = originalValue
        }
        
        for (header, value) in additionalHeaders! {
          newHeaders[header] = value
        }
      }
      
      self.sessionConfiguration.HTTPAdditionalHeaders = newHeaders as [NSObject:AnyObject]?
      
    } else {
      
      self.sessionURL = url!
    }
  }
  
  convenience override init() {
    self.init(url: nil, additionalHeaders: nil)
  }
  
  // MARK: Public Methods
  
  /// Method makes a basic HTTP get request
  ///
  /// :param: RequestSuccessBlock successBlock
  /// :param: RequestErrorBlock errorBlock
  /// :returns: Void
  func getResource(successBlock: RequestSuccessBlock?, errorBlock: RequestErrorBlock?) -> Void {
    
    var request: NSURLRequest = {
      
      let mutableRequest: NSMutableURLRequest = self.httpRequest.mutableCopy() as NSMutableURLRequest
      
      mutableRequest.HTTPMethod = AllowedHTTPMethods.GET
      
      return mutableRequest.copy() as NSURLRequest
      }()
    
    self.httpRequest = request
    
    let task : NSURLSessionDataTask = self.httpSession.session.dataTaskWithRequest(request, completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
      
      var dataResp: NSData? = data
      let httpResponse: NSHTTPURLResponse = response as NSHTTPURLResponse
      let statusCode: Int = httpResponse.statusCode
      let containsStatusCode:Bool = Request.acceptableStatusCodes().containsIndex(statusCode)
      
      if (!containsStatusCode) {
        dataResp = nil
      }
      
      if (successBlock != nil) {
        successBlock!(data: dataResp, response: httpResponse)
      }
      
      if (errorBlock != nil) {
        
        if (error != nil) {
          errorBlock!(error: error, response: httpResponse)
        }
        
        if (!containsStatusCode) {
          println("response \(response)")
          let localizedErrorString: String = "There was an error processing the request"
          let errorDictionary: [String:String] = ["NSLocalizedDescriptionKey" : localizedErrorString, "GSResponseCode" : "\(statusCode)"]
          let requestResponseError: NSError = {
            return NSError(domain: GSTNetworkErrorDomain, code: NSURLErrorUnknown, userInfo: errorDictionary)
            }()
          
          errorBlock!(error: requestResponseError, response: httpResponse)
        }
      }
    })
    
    task.resume()
  }
  
  /// Defines and range of acceptable HTTP response codes. 200 thru 300 inclusive
  /// :returns: NSIndexSet
  class func acceptableStatusCodes() -> NSIndexSet {
    
    let nsRange = NSMakeRange(200, 100)
    
    return NSIndexSet(indexesInRange: nsRange)
  }
}
