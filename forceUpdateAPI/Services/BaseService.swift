//
//  BaseService.swift
//  RiMo
//
//  Created by Javier Calartrava on 9/6/24.
//

import Foundation

@GlobalManager
final class BaseService<T: Decodable> {
    private let apiScheme = "http"
    private let host = "localhost:8080"

    let path: String
    var httpMethod = "GET"
    var body: [String: String] = [:]
    
    init(param: String) {
        self.path = param
    }
    
    // MARK: - Open
     func getPathParam() -> String {
         path
    }

    func execute() async -> Result<T, ErrorService> {
        
        guard let url = URL(string: "\(apiScheme)://\(host)/\(path)") else {
            return .failure(.badFormedURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        addCommonAttributes()
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            return .failure(ErrorService.failedOnParsingJSON)
        }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode != 426 else {
                return .failure(ErrorService.upgradeRequired)
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(ErrorService.invalidHTTPResponse)
            }
            do {
                let dataParsed: T = try self.decoder().decode(T.self, from: data)
                return .success(dataParsed)
            } catch {
                return .failure(ErrorService.failedOnParsingJSON)
            }
        } catch {
            return .failure(ErrorService.errorResponse(error))
        }
    }
    
    // MARK: - Internal / private
    fileprivate func addCommonAttributes() {
        if let marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            body["version"] = marketingVersion
        }
    }
    
    // MARK: - Internal / private  
    private func decoder() -> JSONDecoder {
      
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
