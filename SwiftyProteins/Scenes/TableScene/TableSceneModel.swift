//
//  TableSceneModel.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/28/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation

enum ProteinElement {
	case atom(number: Int, type: String,  coordX: Float, coordY: Float, coordZ: Float)
	case connect(from: Int, to: [Int])
}

class TableSceneVewModel {
	
	var proteinsList: [String] = []
	var selectedProtein: [ProteinElement] = []
	
	func parseReceivedData(_ data: String) {
		let lines = data.components(separatedBy: "\n")
		for line in lines {
			let splittedLine = line.components(separatedBy: " ")
			let cleanLine = removeBlankItems(splittedLine)
			if cleanLine.first == "ATOM" {
				let number = Int(cleanLine[1])!
				let type = cleanLine.last
				let x = Float(cleanLine[6])!
				let y = Float(cleanLine[7])!
				let z = Float(cleanLine[8])!
				selectedProtein.append(ProteinElement.atom(number: number, type: type!, coordX: x, coordY: y, coordZ: z))
			} else if cleanLine.first == "CONECT" {
				let connectFrom = Int(cleanLine[1])!
				var connectWith: [Int] = []
				for i in 2..<cleanLine.count {
					let atomNumber = Int(cleanLine[i])!
					connectWith.append(atomNumber)
				}
				selectedProtein.append(ProteinElement.connect(from: connectFrom, to: connectWith))
			}
		}
	}
	
	private func removeBlankItems(_ array: [String]) -> [String] {
		
		var resultingArray: [String] = []
		for i in 0..<array.count {
			if array[i].count != 0 {
				resultingArray.append(array[i])
			}
		}
		return resultingArray
	}
}
