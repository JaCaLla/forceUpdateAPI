//
//  CharacterService.swift
//  RiMo
//
//  Created by Javier Calartrava on 9/6/24.
//
//@MainActor
@globalActor
actor GlobalManager {
    static var shared = GlobalManager()
}

struct VersionResponseDTO: Codable {
    let data: String
    let currentVersion: String
    let minimumVersion: String
    let forceUpdate: Bool
}

@GlobalManager
final class SampleService {

    let baseService = BaseService<VersionResponseDTO>(param: "sample")
    
    func sample() async -> Result<VersionResponseDTO, ErrorService> {
        baseService.httpMethod = "POST"
        return await baseService.execute()
    }
}
