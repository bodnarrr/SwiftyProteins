//
//  ProteinViewSceneModel.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/29/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import SceneKit

class ProteinViewSceneModel {

    var proteins: [ProteinElement] = []
    let proteinNode = SCNNode()
    let atomsNode = SCNNode()

    lazy var scene: SCNScene = {
        let scene = SCNScene()
        let nrmTexture = UIImage(named: "metal_nrm.jpg")
        let rghTexture = UIImage(named: "metal_rgh.jpg")
        let metTexture = UIImage(named: "metal_met.jpg")

        let defaultMaterial = SCNMaterial()
        defaultMaterial.lightingModel = .physicallyBased
        defaultMaterial.normal.contents = nrmTexture
        defaultMaterial.roughness.contents = rghTexture
        defaultMaterial.metalness.contents = metTexture

        let linkColor = UIColor(hexString: "c8c8c8")
        let atomRadius: CGFloat = 1.5
        for proteinElement in self.proteins {
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
                if case let .atom(fromAtom) = self.proteins[from - 1] {
                    let fromVec3 = SCNVector3Make(fromAtom.coordX, fromAtom.coordY, fromAtom.coordZ)
                    for linkNum in to {
                        if case let .atom(toAtom) = self.proteins[linkNum - 1] {
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

        return scene
    }()
}
