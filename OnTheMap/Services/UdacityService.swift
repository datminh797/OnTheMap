//
//  UdacityService.swift
//  OnTheMap
//
//  Created by minhdat on 06/09/2022.
//

import Foundation

enum API {
    static let base = "https://onthemap-api.udacity.com/v1"
    static let authUrl = "https://auth.udacity.com/sign-up"
}

struct Auth {
    var sessionId: String?
    var key: String?
    var firstName: String?
    var lastName: String?
    var objectId: String?
}

class UdacityService: NSObject {
    static let base = "https://onthemap-api.udacity.com/v1"
    var userName: String?
    var password: String?
    var auth: Auth?
    
    override init() {
        super.init()
    }
 
    class func shared() -> UdacityService {
        struct Singleton {
            static var shared = UdacityService()
        }
        return Singleton.shared
    }
    
    func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let request = PostLoginRequest(userName: email, password: password)
        NetworkController.postRequest(url: request.endpoint, apiType: Constants.UdacityKey, responseType: LoginResponse.self, body: request.queryParameters, httpMethod: "POST") { (response, error) in
            if let response = response {
                self.auth = Auth(sessionId: response.session?.id, key: response.account?.key, firstName: "", lastName: "", objectId: "")
                self.getLoggedInUserProfile(completion: { (success, error) in
                    completion(success, nil)
                })
            } else {
                completion(false, nil)
            }
        }
    }
    
    func getLoggedInUserProfile(completion: @escaping (Bool, Error?) -> Void) {
        let request = GetUserRequest(token: self.auth?.key ?? "")
        NetworkController.getRequest(url: request.endpoint, apiKind: Constants.UdacityKey, responseType: GetUserRequest.ResponseType.self) { (response, error) in
            if let response = response {
                self.auth?.firstName = response.firstName
                self.auth?.lastName = response.lastName
                completion(true, nil)
            } else {
                print("Failed to get user's")
                completion(false, error)
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        let logoutRequest = PostLoginRequest()
        var request = URLRequest(url: logoutRequest.endpoint)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error logging out.")
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            self.auth?.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    func getStudentLocations(completion: @escaping ([StudentInformation]?, Error?) -> Void) {
        let request = GetStudentRequest()
        NetworkController.getRequest(url: request.endpoint, apiKind: request.apiType, responseType: GetStudentRequest.ResponseType.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    func addStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let request = PostStudentRequest(information: information)
        NetworkController.postRequest(url: request.endpointAdd, apiType: request.apiType, responseType: PostStudentRequest.ResponseTypeAdd.self, body: request.queryParameters, httpMethod: "POST") { (response, error) in
            if let response = response, response.createdAt != nil {
                self.auth?.objectId = response.objectId ?? ""
                completion(true, nil)
            }
            completion(false, error)
        }
    }
    
    func updateStudentAddress(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let request = PostStudentRequest(information: information, objectId: self.auth?.objectId ?? "")
        NetworkController.postRequest(url: request.endpointUpdate, apiType: request.apiType, responseType: PostStudentRequest.ResponseTypeUpdate.self, body: request.queryParameters, httpMethod: "PUT") { (response, error) in
            if let response = response, response.updatedAt != nil {
                completion(true, nil)
            }
            completion(false, error)
        }
    }

}
