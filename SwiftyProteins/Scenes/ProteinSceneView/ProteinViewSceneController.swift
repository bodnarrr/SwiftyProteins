//
//  ProteinViewSceneController.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 28.07.2018.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import CoreGraphics

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

    func coreImageColor() -> CIColor {
        return CIColor(color: self)
    }

    func mid(color: UIColor) -> UIColor {
        let lhs = self.coreImageColor()
        let rhs = color.coreImageColor()
        return UIColor(red: (lhs.red + rhs.red) / 2,
                       green: (lhs.green + rhs.green) / 2,
                       blue: (lhs.blue + rhs.blue) / 2,
                       alpha: (lhs.alpha + rhs.alpha) / 2)
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
    let atomsNode = SCNNode()

    var spriteScene: SKScene = SKScene.init()
    let circle = SKShapeNode(circleOfRadius: 20)
    let atomLabel = SKLabelNode(fontNamed: "Arial-BoldMT")

    override func viewDidLoad() {
        super.viewDidLoad()

        spriteScene = SKScene(size: sceneView.bounds.size)

        circle.position = CGPoint(x: spriteScene.frame.midX, y: spriteScene.frame.midY)
        circle.strokeColor = .clear
        circle.fillColor = .blue
        circle.glowWidth = 10.0
        circle.lineWidth = 5.0
        circle.isAntialiased = true
        circle.yScale = 0.0
        circle.xScale = 0.0

        atomLabel.text = "C"
        atomLabel.horizontalAlignmentMode = .center
        atomLabel.verticalAlignmentMode = .center
        atomLabel.fontSize = 20
        atomLabel.fontColor = UIColor.black

        circle.addChild(atomLabel)
        spriteScene.addChild(circle)

        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.overlaySKScene = spriteScene

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
        let proteinNode = SCNNode()
        for proteinElement in model.protein {
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
                    if case let .atom(fromAtom) = model.protein[from - 1] {
                        let fromVec3 = SCNVector3Make(fromAtom.coordX, fromAtom.coordY, fromAtom.coordZ)
                        for linkNum in to {
                            if case let .atom(toAtom) = model.protein[linkNum - 1] {
                                let toVec3 = SCNVector3Make(toAtom.coordX, toAtom.coordY, toAtom.coordZ)

                                let linkNode = SCNNode.lineNode(from: fromVec3, to: toVec3, radius: atomRadius * 0.25)

                                let linkMaterial = defaultMaterial.copy() as! SCNMaterial
                                linkMaterial.diffuse.contents = linkColor
                                linkNode.geometry?.materials = [linkMaterial]
                                linkNode.geometry?.firstMaterial = linkMaterial
                                proteinNode.addChildNode(linkNode)
                            }
                        }
                    }
            }
        }
        proteinNode.addChildNode(atomsNode)

        scene.lightingEnvironment.contents = "sunny.png"
        scene.lightingEnvironment.intensity = 1.0
        scene.background.contents = "sunny.png"

        cameraNode = setupCamera()
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(proteinNode)

        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
    }

    @IBAction func sceneTapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: sceneView)
            let hits = sceneView.hitTest(location, options: [.rootNode : atomsNode])
            if let tappedNode = hits.first?.node,
                let atomName = tappedNode.name {
                print("Tapped on \(atomName)")

                circle.removeAllActions()

                atomLabel.text = atomName
                circle.fillColor = UIColor.CPK(atomType: atomName).mid(color: .white)

                let initialLocation = spriteScene.convertPoint(fromView: location)
                circle.position = initialLocation
                circle.xScale = 0.0
                circle.yScale = 0.0
                circle.isHidden = false
                let newCirclePosition = CGPoint(x: initialLocation.x, y: initialLocation.y + 30)

                let moveAction = SKAction.move(to: newCirclePosition, duration: 1.0)
                let fadeInAction = SKAction.fadeIn(withDuration: 0.25)
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.25)
                let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
                let popGroup = SKAction.group([moveAction, fadeInAction, scaleAction])
                let animationSequence = SKAction.sequence([popGroup, fadeOutAction])

                circle.run(animationSequence)
            }
        }
    }

    func setupCamera() -> SCNNode {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 50)
        cameraNode.camera?.automaticallyAdjustsZRange = true

        return cameraNode
    }
}
