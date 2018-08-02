//
//  ProteinViewSceneModel.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/29/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import SceneKit

enum ProteinElement {
    case atom(number: Int, type: String,  coordX: Float, coordY: Float, coordZ: Float)
    case connect(from: Int, to: [Int])
}

class ProteinViewSceneModel: ProteinMaterialObserver {

    var proteinElements: [ProteinElement] = []
    lazy var proteinMaterial: ProteinMaterial = {
        var material: ProteinMaterial?
        DispatchQueue.main.sync {
            material = (UIApplication.shared.delegate as! AppDelegate).proteinMaterial
        }
        return material ?? ProteinMaterial()
    }()
    let proteinNode = SCNNode()
    let atomsNode = SCNNode()
    let scene: SCNScene

    func parseReceivedData(_ data: String) {
        let lines = data.components(separatedBy: "\n")

        var minCoord = GLKVector3Make(1e20, 1e20, 1e20)
        var maxCoord = GLKVector3Make(1e-20, 1e-20, 1e-20)
        var center = GLKVector3Make(0.0, 0.0, 0.0)
        var numAtoms = 0

        proteinElements.removeAll()

        for line in lines {
            let splittedLine = line.components(separatedBy: " ")
            let cleanLine = removeBlankItems(splittedLine)
            if cleanLine.first == "ATOM" {
                let number = Int(cleanLine[1])!
                let type = cleanLine.last
                let x = Float(cleanLine[6])!
                let y = Float(cleanLine[7])!
                let z = Float(cleanLine[8])!
                proteinElements.append(ProteinElement.atom(number: number, type: type!, coordX: x, coordY: y, coordZ: z))

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
                proteinElements.append(ProteinElement.connect(from: connectFrom, to: connectWith))
            }
        }

        let proteinHalfDimensions = GLKVector3MultiplyScalar(GLKVector3Subtract(maxCoord, minCoord), 0.5)
        let maxProteinHalfDimension = Float.maximum(proteinHalfDimensions.x, Float.maximum(proteinHalfDimensions.y, proteinHalfDimensions.z))
        let proteinCenter = GLKVector3MultiplyScalar(center, 1.0 / Float(numAtoms))
        for (index, element) in proteinElements.enumerated() {
            if case let .atom(atom) = element {
                let centeredAtomPosition = GLKVector3Make(atom.coordX - proteinCenter.x, atom.coordY - proteinCenter.y, atom.coordZ - proteinCenter.z)
                let normalizedAtomPosition = GLKVector3DivideScalar(centeredAtomPosition, maxProteinHalfDimension)
                let scaledAtomPosition = GLKVector3MultiplyScalar(normalizedAtomPosition, 25.0)
                proteinElements[index] = ProteinElement.atom(number: atom.number, type: atom.type,
                                                             coordX: scaledAtomPosition.x, coordY: scaledAtomPosition.y, coordZ: scaledAtomPosition.z)
            } else {
                break
            }
        }
    }

    init(data: String) {
        scene = SCNScene()

        scene.lightingEnvironment.contents = "sunny.png"
        scene.lightingEnvironment.intensity = 1.0

        parseReceivedData(data)

        let defaultMaterial = proteinMaterial.material
        let linkColor = UIColor(hexString: "c8c8c8")
        let atomRadius: CGFloat = 1.5
        for proteinElement in proteinElements {
            switch proteinElement {
            case .atom( _, let type, let coordX, let coordY, let coordZ):
                let atom = SCNSphere(radius: atomRadius)
                let material = defaultMaterial.copy() as! SCNMaterial
                material.diffuse.contents = UIColor.CPK(atomType: type)
                atom.materials = [material]
                atom.firstMaterial = material
                let atomNode = SCNNode(geometry: atom)
                atomNode.name = type
                atomNode.position = SCNVector3Make(coordX, coordY, coordZ)
                atomsNode.addChildNode(atomNode)
            case .connect(let from, let to):
                if case let .atom(fromAtom) = proteinElements[from - 1] {
                    let fromVec3 = SCNVector3Make(fromAtom.coordX, fromAtom.coordY, fromAtom.coordZ)
                    for linkNum in to {
                        if case let .atom(toAtom) = proteinElements[linkNum - 1] {
                            let toVec3 = SCNVector3Make(toAtom.coordX, toAtom.coordY, toAtom.coordZ)

                            let linkNode = SCNNode.lineNode(from: fromVec3, to: toVec3, radius: atomRadius * 0.25)

                            let linkMaterial = defaultMaterial.copy() as! SCNMaterial
                            linkMaterial.diffuse.contents = linkColor
                            linkNode.geometry?.materials = [linkMaterial]
                            linkNode.geometry?.firstMaterial = linkMaterial
                            self.proteinNode.addChildNode(linkNode)
                        }
                    }
                }
            }
        }
        self.proteinNode.addChildNode(atomsNode)
        scene.rootNode.addChildNode(proteinNode)

        proteinMaterial.observer = self
    }

    func materialWasChanged(newMaterial: SCNMaterial) {
        for node in atomsNode.childNodes {
            if let atom = node.geometry {
                let material = newMaterial.copy() as! SCNMaterial
                if let atomName = node.name {
                    material.diffuse.contents = UIColor.CPK(atomType: atomName)
                }
                atom.firstMaterial = material
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
