//
//  VCCommunication.swift
//  EmbddedInVCSdk
//
//  Created by Sowjanya on 07/07/22.
//

import Foundation
import Alamofire

public protocol CommunicateVCDelegate : AnyObject {
    func getIFrameUrl(urlData:String)
}
public class CommunicateVC:NSObject {
    var baseUrlId : String?
    var projectIdVal = ""
    var hostEmailId = ""
    var myUrl = ""
    public weak var tokenDelegate: CommunicateVCDelegate?
    public override init() {
        super.init()
    }
    public func createToken(baseUrl:String, projectId:String, hostEmail:String)  {
        baseUrlId = baseUrl
        projectIdVal = projectId
        hostEmailId = hostEmail
        
        let url  = "\(baseUrl + "applicationresetkey")"
        let body = ["projectId": projectId]

        Alamofire.request(url, method: .post,parameters: body, encoding: JSONEncoding.default)
            .responseJSON { [self] response in
                switch (response.result) {
                case .success: print("success")
                    guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any ] else { return }
                    if let _ = json["status"] as? Bool, let data = json["data"] as? [String:Any], let token = data["authToken"] as? String {
                        print(json)
                        
                        verifyToken(token: token)
                        
                    }
                    
                case .failure : print("failure")
                    
                }
            }
        
    }
   
    func verifyToken(token:String) {
        var url:String!
        url = "\(baseUrlId ?? "" + "tokenVerification")"
        let body = ["projectId": projectIdVal, "token": token]
        Alamofire.request(url, method: .post,parameters: body, encoding: JSONEncoding.default)
            .responseJSON { [self] response in
                switch (response.result) {
                case .success: print("success")
                    guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any ] else { return }
                    print(json)
                    if let _ = json["status"] as? Bool {
                        createSession(token: token)
                    }

                case .failure : print("failure")
                }
            }
    }
    
    func createSession(token:String) {
        var url:String!
        url = "\(baseUrlId ?? "" + "createSession")"
        let obj = ["meetingName": "session",
                   "meetingId": "ba24334d-la3j-sdede-a2343-b12345",
                   "hostEmail":hostEmailId,
                   "partcipantLimit":10,
                   "duration":100
                   
        ] as [String : Any]
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970 * 1000.0.rounded()

        let millisDateOfBirth = Int(timeInSeconds)

        let body = ["projectId": projectIdVal, "token": token,"sessionName": "session","entryTime": millisDateOfBirth,"meetingDetails":obj] as [String : Any]
        
         print("millisDateOfBirth",millisDateOfBirth)
            
        Alamofire.request(url, method: .post,parameters: body, encoding: JSONEncoding.default)
            .responseJSON { [self] response in
                switch (response.result) {
                case .success: print("success")
                    guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any ] else { return }
                    print(json)
                    if let _ = json["status"] as? Bool, let data = json["data"] as? [String:Any], let sessionId = data["sessionId"] as? String {
                        getWebUrl(sessionId: sessionId, token:token)
                    }

                case .failure : print("failure")
                }
            }
    }
    func getWebUrl(sessionId:String, token:String){
        var url:String!
        url = "\(baseUrlId ?? "" + "getTemplateDataById?projectId=\(projectIdVal)")"
        Alamofire.request(url, method: .get,parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { [self] response in
                switch (response.result) {
                case .success: print("success")
                    guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any ] else { return }
                    print(json)
                    if let _ = json["status"] as? Bool, let data = json["data"] as? [String:Any], let subDomain = data["subDomain"] as? String{
                        generateUrl(sessionId:sessionId, subDomain:subDomain, token:token)
                    }

                case .failure : print("failure")
                }
            }
    }
    func generateUrl(sessionId:String,subDomain:String,token:String) {
        

        let utf8str = hostEmailId.data(using: .utf8)

        if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            print("Encoded: \(base64Encoded)")

            if let base64Decoded = Data(base64Encoded: base64Encoded, options: Data.Base64DecodingOptions(rawValue: 0))
            .map({ String(data: $0, encoding: .utf8) }) {
                // Convert back to a string
                print("Decoded: \(base64Decoded ?? "")")
            }
           // roomUrlString = "https://\(subDomain).invc.vc/\(sessionId)?token=\(token)&projectId=62c2d064468f48722e5b4af8&uid=\(base64Encoded)"
            
          let  roomUrlString = "https://apps.invc.vc/\(sessionId)?token=\(token)&projectId=62c2d064468f48722e5b4af8&uid=\(base64Encoded)"
            tokenDelegate?.getIFrameUrl(urlData: roomUrlString)
        }
        
       
       
    }
   

}
