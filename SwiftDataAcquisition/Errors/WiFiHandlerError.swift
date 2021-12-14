//
//  WiFiHandlerError.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/12/2021.
//

import Foundation

enum WiFiHanlderError: Error {
    case wifiNetworkNotFound
    case wifiNetworkNotSet
    case wifiNetworkPasswordWrong
    case wifiNetworkPasswordNotSet
    case deviceIPnotFound
    case devicePasswordWrong
}
