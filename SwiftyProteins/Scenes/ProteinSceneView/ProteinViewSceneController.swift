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

    var model: ProteinViewSceneModel?
    var atomTooltip: AtomTooltip?

    @IBOutlet weak var sceneView: SCNView!

    var cameraNode = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()

        atomTooltip = AtomTooltip(size: sceneView.frame.size)
        sceneView.scene = model?.scene
        sceneView.overlaySKScene = atomTooltip?.spriteScene

        model?.scene.background.contents = "sunnyBlurred.png"

        cameraNode = setupCamera()
        model?.scene.rootNode.addChildNode(cameraNode)

        sceneView.allowsCameraControl = true
    }

    @IBAction func sceneTapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: sceneView)
            let hits = sceneView.hitTest(location, options: [.rootNode : model?.atomsNode ?? SCNNode()])
            if let tappedNode = hits.first?.node,
                let atomName = tappedNode.name {

                atomTooltip?.runAnimation(locationInView: location, atomName: atomName)
            }
        }
    }

    @IBAction func materialsAction(_ sender: Any) {
        model?.proteinMaterial.selectNewMaterial(inViewController: self)
    }

    func setupCamera() -> SCNNode {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 50)
        cameraNode.camera?.automaticallyAdjustsZRange = true

        return cameraNode
    }
}
