//
//  TableSceneModel.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/28/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import GLKit

enum ProteinElement {
    case atom(number: Int, type: String,  coordX: Float, coordY: Float, coordZ: Float)
    case connect(from: Int, to: [Int])
}

class TableSceneVewModel {

    var proteinsList: [String] = []
    var selectedProtein: [ProteinElement] = []

    func parseReceivedData(_ data: String) {
        let lines = data.components(separatedBy: "\n")

        var minCoord = GLKVector3Make(1e20, 1e20, 1e20)
        var maxCoord = GLKVector3Make(1e-20, 1e-20, 1e-20)
        var center = GLKVector3Make(0.0, 0.0, 0.0)
        var numAtoms = 0

        selectedProtein.removeAll()

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

                let coord = GLKVector3Make(x, y, z)
                minCoord = GLKVector3Minimum(minCoord, coord)
                maxCoord = GLKVector3Maximum(maxCoord, coord)
                center = GLKVector3Add(center, coord)
                numAtoms += 1
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

        let proteinHalfDimensions = GLKVector3MultiplyScalar(GLKVector3Subtract(maxCoord, minCoord), 0.5)
        let maxProteinHalfDimension = Float.maximum(proteinHalfDimensions.x, Float.maximum(proteinHalfDimensions.y, proteinHalfDimensions.z))
        let proteinCenter = GLKVector3MultiplyScalar(center, 1.0 / Float(numAtoms))
        for (index, element) in selectedProtein.enumerated() {
            if case let .atom(atom) = element {
                let centeredAtomPosition = GLKVector3Make(atom.coordX - proteinCenter.x, atom.coordY - proteinCenter.y, atom.coordZ - proteinCenter.z)
                let normalizedAtomPosition = GLKVector3DivideScalar(centeredAtomPosition, maxProteinHalfDimension)
                let scaledAtomPosition = GLKVector3MultiplyScalar(normalizedAtomPosition, 25.0)
                selectedProtein[index] = ProteinElement.atom(number: atom.number, type: atom.type,
                                                             coordX: scaledAtomPosition.x, coordY: scaledAtomPosition.y, coordZ: scaledAtomPosition.z)
            } else {
                break
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
