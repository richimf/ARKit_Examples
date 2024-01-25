//
//  BoxTextNodeExample.swift
//
//  Created by Ricardo on 24/01/24.
//

import UIKit
import ARKit
import SceneKit

//
// This code detects distance from device to the detected wall.
//
final class WallDetectionViewController: SceneViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        // Create a new scene and assign it to the sceneView
        sceneView.scene = SCNScene()
        // Configure ARKit Session
        configuration.planeDetection = [.vertical]
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        // Visualize the vertical plane
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        // Rotate the plane to align vertically
        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        print("position = \(node.position)")
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        print(#function)
        // Calculate the distance to the detected plane
        if let closestAnchor = frame.anchors.min(by: { $0.transform.columns.3.distance(to: frame.camera.transform.columns.3) < $1.transform.columns.3.distance(to: frame.camera.transform.columns.3) }) {
            let distance = closestAnchor.transform.columns.3.distance(to: frame.camera.transform.columns.3)
            print("Distance to the closest plane: \(distance) meters")
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Handle session failure
//        print("Session Error: \(error.localizedDescription)")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Handle session interruption
//        print("sessionWasInterrupted")
    }

}

//Extension Method: An extension on SIMD4 is used to calculate the distance between two points in 3D space.
extension SIMD4 where Scalar == Float {
    func distance(to vector: SIMD4<Scalar>) -> Float {
        let dx = x - vector.x
        let dy = y - vector.y
        let dz = z - vector.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }
}


//
//final class WallDetectionViewController: SceneViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
//
//    var userSphere: SCNNode?
//    var sphereStopped = false
//
//    enum CollisionCategory: Int {
//        case sphere = 1
//        case wall = 2
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        sceneView.delegate = self
//        sceneView.scene.physicsWorld.contactDelegate = self
//        
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.vertical]
//        sceneView.session.run(configuration)
//        
//        addUserSphere()
//    }
//}
//extension WallDetectionViewController {
//    
//    func addUserSphere() {
//        let sphereGeometry = SCNSphere(radius: 0.1)
//        sphereGeometry.firstMaterial?.diffuse.contents = UIColor.blue
//
//        let sphereNode = SCNNode(geometry: sphereGeometry)
//        sphereNode.position = SCNVector3(0, 0, -0.5) // Initial position in front of the camera
//
//        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        sphereNode.physicsBody?.categoryBitMask = CollisionCategory.sphere.rawValue
//        sphereNode.physicsBody?.contactTestBitMask = CollisionCategory.wall.rawValue
//
//        sceneView.scene.rootNode.addChildNode(sphereNode)
//        userSphere = sphereNode
//        userSphere?.name = "userSphere"
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
//
//        let wallNode = createWallNode(anchor: planeAnchor)
//        node.addChildNode(wallNode)
//    }
//
//    func createWallNode(anchor: ARPlaneAnchor) -> SCNNode {
//        let wall = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//        wall.firstMaterial?.diffuse.contents = UIColor.red //UIColor(white: 1, alpha: 0.5) // Semi-transparent
//
//        let wallNode = SCNNode(geometry: wall)
//        wallNode.eulerAngles.x = -.pi / 2 // Rotate to match wall orientation
//        wallNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
//
//        wallNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//        wallNode.physicsBody?.categoryBitMask = CollisionCategory.wall.rawValue
//        wallNode.physicsBody?.contactTestBitMask = CollisionCategory.sphere.rawValue
//
//        return wallNode
//    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        guard let userSphere = userSphere else { return }
//        if self.sphereStopped {
//            return
//        }
//        DispatchQueue.main.async {
//            if let cameraTransform = self.sceneView.session.currentFrame?.camera.transform {
//                let cameraPosition = SCNVector3(
//                    x: cameraTransform.columns.3.x,
//                    y: cameraTransform.columns.3.y,
//                    z: cameraTransform.columns.3.z
//                )
//
//                var translation = matrix_identity_float4x4
//                // Set the distance to 2 meters from the camera
//                translation.columns.3.z = -0.5 // Distance from the camera
//                let sphereTransform = simd_mul(cameraTransform, translation)
//                let spherePosition = SCNVector3(
//                    x: sphereTransform.columns.3.x,
//                    y: sphereTransform.columns.3.y,
//                    z: sphereTransform.columns.3.z
//                )
//                
//                userSphere.position = spherePosition
//            }
//        }
//    }
//
//    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//      
//        let nodeA = contact.nodeA
//        let nodeB = contact.nodeB
//        
//        // Check if one of the nodes is the user sphere
//        if nodeA.name == "userSphere" || nodeB.name == "userSphere" {
//            DispatchQueue.main.async {
//                self.sphereStopped = true
//                // Change color of the sphere
//                let sphereNode = (nodeA.name == "userSphere" ? nodeA : nodeB)
//                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green // or any color
//                // Stop the sphere
//                sphereNode.physicsBody?.clearAllForces()
//                sphereNode.physicsBody?.velocity = SCNVector3(0, 0, 0)
//                sphereNode.physicsBody?.angularVelocity = SCNVector4(0, 0, 0, 0)
//                
//            }
//        }
//    }
//
//}
//
