//
//  ProteinARViewController.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 02.08.2018.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class ProteinARViewController : UIViewController, ARSCNViewDelegate {
    var model: ProteinViewSceneModel?
    var atomTooltip: AtomTooltip?

    @IBOutlet weak var sceneView: ARSCNView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let config = ARWorldTrackingConfiguration()
        config.isLightEstimationEnabled = true
        sceneView.session.run(config)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let scene = model?.scene else {
            return
        }

        atomTooltip = AtomTooltip(size: sceneView.frame.size)
        sceneView.scene = scene
        sceneView.overlaySKScene = atomTooltip?.spriteScene

        model?.proteinNode.position = SCNVector3Make(0.0, 0.0, -2.0)
        model?.proteinNode.scale = SCNVector3Make(0.05, 0.05, 0.05)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate else { return }
        sceneView.scene.lightingEnvironment.intensity = lightEstimate.ambientIntensity / 1000.0
    }

    @IBAction func materialsAction(_ sender: UIBarButtonItem) {
        model?.proteinMaterial.selectNewMaterial(inViewController: self)
    }

    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: sceneView)
            let hits = sceneView.hitTest(location, options: [.rootNode : model?.atomsNode ?? SCNNode()])
            if let tappedNode = hits.first?.node,
                let atomName = tappedNode.name {

                atomTooltip?.runAnimation(locationInView: location, atomName: atomName)
            }
        }
    }
	@IBAction func shareAction(_ sender: UIBarButtonItem) {
		shareScreenshot(sender)
	}
	
}
