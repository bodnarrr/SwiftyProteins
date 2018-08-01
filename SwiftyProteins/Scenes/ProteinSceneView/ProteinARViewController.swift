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

class ProteinARViewController : UIViewController {
    let model = ProteinViewSceneModel()
    var atomTooltip: AtomTooltip?

    @IBOutlet weak var sceneView: ARSCNView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let config = ARWorldTrackingConfiguration()
        config.isLightEstimationEnabled = true
        sceneView.session.run(config)
        sceneView.automaticallyUpdatesLighting = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        atomTooltip = AtomTooltip(size: sceneView.frame.size)
        sceneView.scene = model.scene
        sceneView.overlaySKScene = atomTooltip?.spriteScene

        model.proteinNode.position = SCNVector3Make(0.0, 0.0, -2.0)
        model.proteinNode.scale = SCNVector3Make(0.05, 0.05, 0.05)
    }

    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: sceneView)
            let hits = sceneView.hitTest(location, options: [.rootNode : model.atomsNode])
            if let tappedNode = hits.first?.node,
                let atomName = tappedNode.name {

                atomTooltip?.runAnimation(locationInView: location, atomName: atomName)
            }
        }
    }
}
