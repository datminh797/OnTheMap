//
//  PostRequest.swift
//  OnTheMap
//
//  Created by minhdat on 06/09/2022.
//

import Foundation
class PostLoginRequest {
    typealias ResponseType = LoginResponse
    var endpoint: URL { URL(string: API.base + "/session")!}
    
    let userName: String
    let password: String
    
    var queryParameters: String {
        return "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
    }
    
    init(userName: String = "", password: String = "") {
        self.userName = userName
        self.password = password
    }
}


class PostStudentRequest {
    typealias ResponseTypeAdd = PostLocationResponse
    typealias ResponseTypeUpdate = UpdateLocationResponse
    var endpointAdd: URL { URL(string: API.base + "/StudentLocation")!}
    var endpointUpdate: URL { URL(string: API.base + "/StudentLocation" + objectId)!}
    var information: StudentInformation
    
    var queryParameters: String {
        return "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
    }
    var apiType: String { "Parse" }
    let objectId: String
    init(information: StudentInformation, objectId: String = "") {
        self.information = information
        self.objectId = objectId
    }
}
