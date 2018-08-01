//
//  ApiManager.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/28/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import Alamofire

class ApiManager {
    
    static let shared = ApiManager()
    
    private init() {}
    
    func getModelFromAPI(_ proteinName: String, completion: @escaping (String?)->Void) {
        
        let apiRootUrl = "https://files.rcsb.org/ligands/view/"
        let url = apiRootUrl + proteinName + "_model.pdb"
        Alamofire.request(url).response { (response) in
            if let data = response.data {
                guard let text = String(data: data, encoding: .utf8) else { return }
                completion(text)
			} else {
				completion(nil)
			}
        }
    }
}
