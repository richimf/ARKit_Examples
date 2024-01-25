//
//  NodeExampleViewController.swift
//
//  Created by Ricardo on 24/01/24.
//

import UIKit
import ARKit
import SceneKit

final class SimpleNodeExampleViewController: SceneViewController, ARSCNViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        // Create a new scene
        let scene = SCNScene()
        // Create a geometry for the node (in this case, a simple sphere)
        let sphere = SCNSphere(radius: 0.1) // 0.1 means 10cm
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        sphere.materials = [material]

        // Create a node with the geometry
        let node = SCNNode(geometry: sphere)
        // Position the node in the AR scene
        node.position = SCNVector3(0, 0, -0.5) // 0.5 means half meter
        // Add the node to the scene
        scene.rootNode.addChildNode(node)

        // Set the scene to the view
        sceneView.scene = scene
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.showsStatistics = true

        // Create and run a session configuration for ARKit
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
}
