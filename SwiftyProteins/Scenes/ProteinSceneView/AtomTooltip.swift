//
//  AtomTooltip.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 01.08.2018.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import SpriteKit

class AtomTooltip {
    let spriteScene: SKScene
    let circle = SKShapeNode(circleOfRadius: 20)
    let atomLabel = SKLabelNode(fontNamed: "Arial-BoldMT")

    init(size: CGSize) {
        spriteScene = SKScene(size: size)

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
    }

    func runAnimation(locationInView: CGPoint, atomName: String) {
        circle.removeAllActions()

        atomLabel.text = atomName
        circle.fillColor = UIColor.CPK(atomType: atomName).mid(color: .white)

        let initialLocation = spriteScene.convertPoint(fromView: locationInView)
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
