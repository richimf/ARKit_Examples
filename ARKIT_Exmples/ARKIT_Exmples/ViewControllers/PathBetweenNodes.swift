//
//  PathBetweenNodes.swift
//
//  Created by Ricardo on 24/01/24.
//

import UIKit
import ARKit
import SceneKit

final class PathBetweenNodesViewController: SceneViewController, ARSCNViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Create a new scene
        let scene = SCNScene()

        
        let node = createSphereNode(color: .green)
        node.position = SCNVector3(0, 0, -0.5) // Position the first node 0.5 meters in front of the camera
        scene.rootNode.addChildNode(node)
        let node2 = createSphereNode(color: .red)
        node2.position = SCNVector3(0, 0, 0.5) // Position the second node 0.5 meters behind the first node
        scene.rootNode.addChildNode(node2)

        // Set the scene to the view
        sceneView.scene = scene
        // Create and run a session configuration for ARKit
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        // CREATE PATH BETWEEN NODES
        createPath(from: node, to: node2, in: scene)
    }
    
    private func createPath(from node1: SCNNode, to node2: SCNNode, in scene: SCNScene) {
        let distance = node1.distance(receiver: node2)
        print("Distance \(distance)")
//        let lineGeometry = SCNGeometry.line(from: node1.position, to: node2.position)
//        let lineNode = SCNNode(geometry: lineGeometry)
//        scene.rootNode.addChildNode(lineNode)
        manualGetDistance(from: node1, to: node2)
        let path = SCNGeometry.cylinderLine(from: node1.position, to: node2.position, segments: 5)
//        scene.rootNode.addChildNode(path)
        let node1positoin = node1.position.y
        let text = add(text: "hola", position: SCNVector3(0, 0, 0))
        node1.addChildNode(text)
        scene.rootNode.addChildNode(path)
    }
    
    private func manualGetDistance(from node1: SCNNode, to node2: SCNNode) {
        let node1Pos = SCNVector3ToGLKVector3(node1.presentation.worldPosition)
        let node2Pos = SCNVector3ToGLKVector3(node2.presentation.worldPosition)
        let distance = GLKVector3Distance(node1Pos, node2Pos)
        print("Distance \(distance)")
    }
    
    private func add(text: String, position: SCNVector3) -> SCNNode {
        // Create a text label
        let textGeometry = SCNText(string: text, extrusionDepth: 0.0) //hace el efecto 3D en el texto
        textGeometry.font = UIFont.systemFont(ofSize: 0.2) // Set the font size
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.yellow
        textGeometry.materials = [textMaterial]
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = position // Position the text label above the first sphere
        return textNode
    }

    private func createSphereNode(color: UIColor = .blue) -> SCNNode {
        // Create a geometry for the node (in this case, a simple sphere)
        let sphere = SCNSphere(radius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = color
        sphere.materials = [material]
        // Create a node with the geometry
        return SCNNode(geometry: sphere)
    }
}
