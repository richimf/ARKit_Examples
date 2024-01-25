//
//  LightSpot.swift
//
//  Created by Ricardo on 24/01/24.
//

import ARKit
import SceneKit

class LightSpotViewController: SceneViewController, ARSCNViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let lightSpotNode = createLightSpotNode(at: planeAnchor.center)
        node.addChildNode(lightSpotNode)
    }

    func createLightSpotNode(at position: vector_float3) -> SCNNode {
        // Create a semi-transparent white sphere
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 1.0)
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(position.x, position.y, position.z)

        // Add a light to the sphere
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1000 // Adjust intensity as needed
        light.temperature = 6500 // Adjust for desired color

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, 0.5, 0) // Position the light above the sphere
        sphereNode.addChildNode(lightNode)

        return sphereNode
    }
}
