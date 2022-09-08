//
//  GetRequest.swift
//  OnTheMap
//
//  Created by minhdat on 06/09/2022.
//

import Foundation
class GetUserRequest {
    typealias ResponseType = UserProfile
    var endpoint: URL { URL(string: API.base + "/users/" + token)!}
    let token: String

    init(token: String) {
        self.token = token
    }
}

class GetStudentRequest {
    typealias ResponseType = StudentsLocation
    var endpoint: URL { URL(string: API.base + "/StudentLocation?limit=100&order=-updatedAt")!}
    var apiType: String { "Parse" }
}
