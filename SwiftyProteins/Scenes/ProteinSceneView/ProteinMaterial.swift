//
//  ProteinMaterial.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 2018-08-02.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

protocol ProteinMaterialObserver: class {
    func materialWasChanged(newMaterial: SCNMaterial)
}

class ProteinMaterial {
    let materials: [SCNMaterial]
    let alert = UIAlertController(title: "Choose Material", message: nil, preferredStyle: .actionSheet)
    var material: SCNMaterial

    weak var observer: ProteinMaterialObserver?

    init() {
        let plasticMaterial = SCNMaterial()
        plasticMaterial.name = "Plastic"
        plasticMaterial.lightingModel = .physicallyBased
        plasticMaterial.normal.contents = "Plastic03_nrm.jpg"
        plasticMaterial.roughness.contents = "Plastic03_rgh.jpg"

        let leatherMaterial = SCNMaterial()
        leatherMaterial.name = "Leather"
        leatherMaterial.lightingModel = .physicallyBased
        leatherMaterial.normal.contents = "Leather05_nrm.jpg"
        leatherMaterial.roughness.contents = "Leather05_rgh.jpg"

        let metalMaterial = SCNMaterial()
        metalMaterial.name = "Metal"
        metalMaterial.lightingModel = .physicallyBased
        metalMaterial.normal.contents = "metal_nrm.jpg"
        metalMaterial.roughness.contents = "metal_rgh.jpg"
        metalMaterial.metalness.contents = "metal_met.jpg"

        materials = [plasticMaterial, leatherMaterial, metalMaterial]
        material = plasticMaterial

        let materialActionHandler = { [unowned self] (action: UIAlertAction) in
            if let newBaseMaterial = self.materials.first(where: { material -> Bool in return action.title == material.name}) {
                if let observer = self.observer {
                    observer.materialWasChanged(newMaterial: newBaseMaterial)
                }
                self.material = newBaseMaterial
            }
        }
        for mat in materials {
            alert.addAction(UIAlertAction(title: mat.name, style: .default, handler: materialActionHandler))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    func selectNewMaterial(inViewController: UIViewController) {
        inViewController.present(alert, animated: true, completion: nil)
    }
}
