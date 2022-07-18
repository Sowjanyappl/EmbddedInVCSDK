//
//  VCCommunication.swift
//  EmbddedInVCSdk
//
//  Created by Sowjanya on 07/07/22.
//

import Foundation
import Alamofire

public protocol CommunicateVCDelegate : AnyObject {
    func getIFrameUrl(urlData:String, isSuccess:Bool)
}
public class CommunicateVC:NSObject {
    var baseUrl = "https://api.inapi.vc/publicuser/"
    var projectIdVal = ""
    var hostEmailId = ""
    var appKey = ""
    var meetingObj : [String : Any] = [:]
    
    public weak var tokenDelegate: CommunicateVCDelegate?
    public override init() {
        super.init()
    }
    public func createToken(projectId:String, hostEmail:String, appKey:String,meetingObj:[String:Any])  {
        projectIdVal = projectId
        hostEmailId = hostEmail
        
        let url  = "\(baseUrl + "getTokenbyId?projectId=\(projectId)")"
//        let body = ["projectId": projectId]
        let headers = ["Authorization": "Bearer \(appKey)"]

        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [self] response in
                switch (response.result) {
                case .success:
                    guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any ] else { return }
                    if let _ = json["status"] as? Bool, let data = json["data"] as? [String:Any], let token = data["token"] as? String {
                        
                        createSession(token: token, meetingObj:meetingObj)
                        
                    }
                    else {
                        tokenDelegate?.getIFrameUrl(urlData: "", isSuccess: false)

                    }
                    
                case .failure :
                    tokenDelegate?.getIFrameUrl(urlData: "", isSuccess: false)

                    
                }
            }
        
    }

    
    func createSession(token:String,meetingObj:[String:Any]) {
        var url:String!
        url = "\(baseUrl + "createSession")"
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970 * 1000.0.rounded()

        let millisDateOfBirth = Int(timeInSeconds)

        let body = ["projectId": projectIdVal, "token": token,"sessionName": "session","entryTime": millisDateOfBirth,"meetingDetails":meetingObj] as [String : Any]
        
            
        Alamofire.request(url, method: .post,parameters: body, encoding: JSONEncoding.default)
            .responseJSON { [self] response in
                switch (response.result) {
                case .success:
                    guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any ] else { return }
                    
                    if let _ = json["status"] as? Bool, let data = json["data"] as? [String:Any], let sessionId = data["sessionId"] as? String {
                        getWebUrl(sessionId: sessionId, token:token)
                    }

                case .failure :
                    tokenDelegate?.getIFrameUrl(urlData: "", isSuccess: false)

                    
                }
            }
    }
    func getWebUrl(sessionId:String, token:String){
        var url:String!
        url = "\(baseUrl + "getTemplateDataById?projectId=\(projectIdVal)")"
        Alamofire.request(url, method: .get,parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { [self] response in
                switch (response.result) {
                case .success:
                    
                    guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any ] else { return }
                    
                    if let _ = json["status"] as? Bool, let data = json["data"] as? [String:Any], let subDomain = data["subDomain"] as? String{
                        generateUrl(sessionId:sessionId, subDomain:subDomain, token:token)
                    }

                case .failure :
                    tokenDelegate?.getIFrameUrl(urlData: "", isSuccess: false)

                    
                }
            }
    }
    func generateUrl(sessionId:String,subDomain:String,token:String) {
        

        let utf8str = hostEmailId.data(using: .utf8)

        if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            

            if let base64Decoded = Data(base64Encoded: base64Encoded, options: Data.Base64DecodingOptions(rawValue: 0))
            .map({ String(data: $0, encoding: .utf8) }) {
                // Convert back to a string
            }
           // roomUrlString = "https://\(subDomain).invc.vc/\(sessionId)?token=\(token)&projectId=62c2d064468f48722e5b4af8&uid=\(base64Encoded)"
            
          let  roomUrlString = "https://apps.invc.vc/\(sessionId)?token=\(token)&projectId=62c2d064468f48722e5b4af8&uid=\(base64Encoded)"
            tokenDelegate?.getIFrameUrl(urlData: roomUrlString, isSuccess: true)
        }
        
       
       
    }
   

}
