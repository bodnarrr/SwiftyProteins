//
//  TableSceneModel.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/28/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation

class TableSceneVewModel {
    var proteinsList: [String] = []
    var filteredProteinList: [String] = []
    
    func copyAllToFiltered() {
        filteredProteinList = proteinsList
    }
    
    func filterProteins(_ searchText: String) {
        filteredProteinList = proteinsList.filter { protein -> Bool in
            protein.lowercased().contains(searchText.lowercased())
        }
    }
}
