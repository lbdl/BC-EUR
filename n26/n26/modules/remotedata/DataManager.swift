//
//  DataManager.swift
//  AirTasker
//
//  Created by Timothy Storey on 22/02/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import UIKit
import Foundation

protocol DataControllerPrototcol {
    func fetchLocations()
    func fetchLocationData(for locationId: Int64)
    func fetchAvatarData(for profileId: Int64, forImageView imgView: UIImageView) -> UIImage?
}

enum SessionType {
    case backgroundSession
    case sharedSession
    case emphemeralSession
}

enum HttpMethods: String {
    case get = "GET"
}

enum EndPoint: String {
    case location
    case locations
    case avatar
}

/// The data manager is intended to be passed between view controllers as a data handler
/// for remote data access and local data persistence.
/// It is only implemented for default sessions although it is intended to be extended
/// for background tasks.
///
/// This implementation also makes no considerations of authentication etc although
/// the data manager should handle all of this as per the servers requirements internally
/// and in an opaque manner as far as the consumers of the manager are concerned
///
/// A view controller should not need to know anything about it other
/// than to call the methods it needs as defined in the DataController protocol.
///
/// Data fetched is stored in CoreData. The views should be updated via a fetched results controller.

class DataManager: NSObject, DataControllerPrototcol {
    let persistenceManager: PersistenceControllerProtocol
    let dataSession: URLSessionProtocol
    let locationsHandler: AnyMapper<Mapped<[LocationRaw]>>
    let localleHandler: AnyMapper<Mapped<LocalleRaw>>
    
    private let scheme: String = "https"
    private let host: String = "s3-ap-southeast-2.amazonaws.com"
    
    /// - Returns: an instance of DataManager
    ///
    /// - parameters:
    ///     - storeManager: an object conforming to the PerssistenceController protocol that handles persisting data
    ///     - networkManager: an object conforming to the URLSessionProtocol that fetches data
    ///     - configuration: a enumeration defining the tyle of sessiopersistenceManagern, in this case default
    ///     - locationParser: a object conforming to the JSONMapper protocol passed as Type Erased object as we use associated types in the protocol
    ///     - localleParser: a object conforming to the JSONMapper protocol passed as Type Erased object as we use associated types in the protocol
    required init(storeManager: PersistenceControllerProtocol, urlSession: URLSessionProtocol, configuration: SessionType = .sharedSession, locationParser: AnyMapper<Mapped<[LocationRaw]>>, localleParser: AnyMapper<Mapped<LocalleRaw>>) {
       persistenceManager = storeManager
        dataSession = urlSession
        locationsHandler = locationParser
        localleHandler = localleParser
    }
    
    /// Fetches all locations stored in the remote DB really this method should throw
    /// and pass the error up the chain for both data fetch errors and parse/persist errors.
    /// Furthermore it should handle server codes other than straight success, namely 300, 400, 500 and the like
    /// however it doesn't, its naive and trusting **AKA** "I'm being lazy"
    /// - Returns: void
    func fetchLocations()  {
        guard let url = buildURL(forEndPoint: .locations, forResourceID: nil) else { return }
        guard let request = makeRequest(fromUrl: url) else { return }
        let task = dataSession.dataTask(with: request) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            if error == nil  {
                guard let urlResponse = response as? HTTPURLResponse else { return }
                if  200...299 ~= urlResponse.statusCode {
                    guard let rawdata = data else { return }
                    strongSelf.locationsHandler.parse(rawValue: rawdata)
                    guard let val = strongSelf.locationsHandler.mappedValue else { return }
                    switch val {
                    case .MappingError:
                        //handle the parsing error
                        print ("mapping error \(val.associatedValue())")
                    case .Value:
                        strongSelf.locationsHandler.persist(rawJson: val)
                    }
                }
            } else {
                //handle the network error
            }
        }
        task.resume()
    }
    
    /// Fetches specific localle data stored in the remote DB. Should really throw as above
    /// however for the sake of brevity it doesn't
    /// - Returns: void
    ///
    /// - parameters:
    ///     - locationID: the id of the required localle obtained from the location object
    func fetchLocationData(for locationId: Int64) {
        guard let url = buildURL(forEndPoint: .location, forResourceID: locationId) else { return }
        guard let request = makeRequest(fromUrl: url) else { return }
        let task = dataSession.dataTask(with: request) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            if error == nil {
                guard let urlResponse = response as? HTTPURLResponse else {return}
                if  200...299 ~= urlResponse.statusCode {
                    guard let rawdata = data else { return }
                    strongSelf.localleHandler.parse(rawValue: rawdata)
                    guard let val = strongSelf.localleHandler.mappedValue else { return }
                    switch val {
                    case .MappingError:
                        //handle the parsing error
                        print ("mapping error \(val.associatedValue())")
                    case .Value:
                        strongSelf.localleHandler.persist(rawJson: val)
                    }
                }
            } else {
                //handle the network error
            }
        }
        task.resume()
    }
    
    func fetchAvatarData(for profileId: Int64, forImageView imgView: UIImageView) -> UIImage? {
        var image: UIImage?
        guard let url = buildURL(forEndPoint: .avatar, withType: ".jpg", forResourceID: profileId) else { return nil }
        guard let request = makeRequest(fromUrl: url) else { return nil }
        let task = dataSession.dataTask(with: request) { (data, response, error) in
            if error == nil {
                guard let urlResponse = response as? HTTPURLResponse else { return }
                if  200...299 ~= urlResponse.statusCode {
                    guard let rawdata = data else { return }
                    guard let tmp = UIImage(data: rawdata) else { return }
                    image = tmp
                    DispatchQueue.main.async(execute: { () -> Void in
                        imgView.image = tmp
                    })
                }
            }
        }
        task.resume()
        return image
    }
    
    private func buildURL(forEndPoint endPoint: EndPoint, withType resType: String = ".json", forResourceID resID: Int64?) -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        
        switch endPoint {
        case .location:
                urlComponents.path = "/ios-code-test/v2/location/" + String(resID!) + resType
        case .locations:
                urlComponents.path = "/ios-code-test/v2/locations" + resType
        case .avatar:
                urlComponents.path = "/ios-code-test/v2/img/" + String(resID!) + resType
        }
        
        return urlComponents.url
    }
    
    
    private func makeLocationsURL() -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = scheme;
        urlComponents.host = host;
        urlComponents.path = "/locations.json";
        
        return urlComponents.url
    }
    
    private func makeRequest(fromUrl url: URL, forMethod method: HttpMethods = HttpMethods.get) -> URLRequest? {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue
        return request as URLRequest
    }
    
    private func makeLocationURL(forId id: Int64) -> URL? {
        return nil
    }
    
}
