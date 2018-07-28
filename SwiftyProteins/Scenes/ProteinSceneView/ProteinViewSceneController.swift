//
//  ProteinViewSceneController.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 28.07.2018.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import SceneKit

class ProteinViewSceneController : UIViewController {

    @IBOutlet weak var sceneView: SCNView!

    var cameraNode = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SCNScene()
        sceneView?.scene = scene

        let boxGeometry = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 1.0)
        let boxNode = SCNNode(geometry: boxGeometry)

        scene.rootNode.addChildNode(lightNode())
        cameraNode = setupCamera()
        scene.rootNode.addChildNode(cameraNode)

        scene.rootNode.addChildNode(boxNode)

        sceneView.allowsCameraControl = true
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
        cameraNode.position = SCNVector3Make(0, 0, 25)

        return cameraNode
    }
}
