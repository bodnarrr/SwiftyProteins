//
//  ProteinViewSceneController.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 28.07.2018.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    static func lineNode(from: SCNVector3, to: SCNVector3, radius: CGFloat = 0.25) -> SCNNode {
        let vector = to - from
        let height = vector.length()
        let cylinder = SCNCylinder(radius: radius, height: CGFloat(height))
        cylinder.radialSegmentCount = 4
        let node = SCNNode(geometry: cylinder)
        node.position = (to + from) / 2
        node.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
        return node
    }
}

extension UIColor {
    static func random() -> UIColor {
        let red = CGFloat(arc4random() % 255) / 255.0
        let green = CGFloat(arc4random() % 255) / 255.0
        let blue = CGFloat(arc4random() % 255) / 255.0
        return UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1.0)
    }

    convenience init(hexString: String, alpha: CGFloat = 1.0) {

        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)

        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    static let CPKColors = [
        "C" : UIColor.black,
        "O" : UIColor(hexString: "f00000"),
        "H" : UIColor.white,
        "N" : UIColor(hexString: "8f8fff"),
        "S" : UIColor(hexString: "ffc832"),
        "P" : UIColor(hexString: "ffa500"),
        "Cl" : UIColor.green,
        "F" : UIColor.green
    ]

    static func CPK(atomType: String) -> UIColor {
        if let color = CPKColors[atomType] {
            return color
        }
        return UIColor(hexString: "ff1493")
    }
}

extension SCNVector3 {
    static func lineEulerAngles(vector: SCNVector3) -> SCNVector3 {
        let height = vector.length()
        let lxz = sqrtf(vector.x * vector.x + vector.z * vector.z)
        let pitchB = vector.y < 0 ? Float.pi - asinf(lxz/height) : asinf(lxz/height)
        let pitch = vector.z == 0 ? pitchB : sign(vector.z) * pitchB

        var yaw: Float = 0
        if vector.x != 0 || vector.z != 0 {
            let inner = vector.x / (height * sinf(pitch))
            if inner > 1 || inner < -1 {
                yaw = Float.pi / 2
            } else {
                yaw = asinf(inner)
            }
        }
        return SCNVector3(CGFloat(pitch), CGFloat(yaw), 0)
    }
}

class ProteinViewSceneController : UIViewController {
	
	let model = ProteinViewSceneModel()

    @IBOutlet weak var sceneView: SCNView!

    var cameraNode = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SCNScene()
        sceneView.scene = scene

        let atomMaterial = SCNMaterial()
        atomMaterial.lightingModel = .physicallyBased
        atomMaterial.normal.contents = UIImage(named: "metal_nrm.jpg")
        atomMaterial.roughness.contents = UIImage(named: "metal_rgh.jpg")
        atomMaterial.displacement.contents = UIImage(named: "metal_disp.jpg")
        atomMaterial.metalness.contents = UIImage(named: "metal_met.jpg")

        let linkColor = UIColor(hexString: "c8c8c8")
        let atomRadius: CGFloat = 1.5
        let proteinNode = SCNNode()
        for proteinElement in model.protein {
            switch proteinElement {
                case .atom(let number, let type, let coordX, let coordY, let coordZ):
                    let atom = SCNSphere(radius: atomRadius)
                    let material = atomMaterial.copy() as! SCNMaterial
                    material.diffuse.contents = UIColor.CPK(atomType: type)
                    atom.materials = [material]
                    atom.firstMaterial = material
                    let atomNode = SCNNode(geometry: atom)
                    atomNode.position = SCNVector3Make(coordX, coordY, coordZ)
                    proteinNode.addChildNode(atomNode)
                case .connect(let from, let to):
                    if case let .atom(fromAtom) = model.protein[from - 1] {
                        let fromVec3 = SCNVector3Make(fromAtom.coordX, fromAtom.coordY, fromAtom.coordZ)
                        for linkNum in to {
                            if case let .atom(toAtom) = model.protein[linkNum - 1] {
                                let toVec3 = SCNVector3Make(toAtom.coordX, toAtom.coordY, toAtom.coordZ)

                                let linkNode = SCNNode.lineNode(from: fromVec3, to: toVec3, radius: atomRadius * 0.25)
                                linkNode.geometry?.materials.first?.diffuse.contents = linkColor
                                linkNode.geometry?.materials.first?.lightingModel = .physicallyBased
                                proteinNode.addChildNode(linkNode)
                            }
                        }
                    }
            }
        }

        scene.lightingEnvironment.contents = "sunny.png"
        scene.lightingEnvironment.intensity = 1.0
        scene.background.contents = "sunny.png"

        cameraNode = setupCamera()
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(proteinNode)

        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
    }

    func lightNode() -> SCNNode {
        let lightNode = SCNNode()

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor(white: 0.1, alpha: 1.0)
        lightNode.addChildNode(ambientLightNode)

        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = .omni
        omniLightNode.light?.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        lightNode.addChildNode(omniLightNode)

        return lightNode
    }

    func setupCamera() -> SCNNode {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 50)
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.automaticallyAdjustsZRange = true

        return cameraNode
    }
}
