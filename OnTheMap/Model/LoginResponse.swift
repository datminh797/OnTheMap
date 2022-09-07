//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by minhdat on 06/09/2022.
//

import Foundation

struct LoginResponse: Codable {
    let account: Account?
    let session: Session?
}

struct Account: Codable {
    let registered: Bool?
    let key: String?
}

struct Session: Codable {
    let id: String?
    let expiration: String?
}



