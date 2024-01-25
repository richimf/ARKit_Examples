//
//  ImageMarkers.swift
//
//  Created by Ricardo on 24/01/24.
//

import UIKit
import ARKit

final class ImageMarkersViewController: SceneViewController, ARSCNViewDelegate {
        
    var configuration = ARImageTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        configuration.worldAlignment = .gravity
        getImageMarkers()
        sceneView.session.run(configuration)
    }
    
    // For error "image must have non-zero positive width",
    // este error se corrige seleccionando la imagen y en el inspector cambiar el width de 0 a algun valor.
    func getImageMarkers() {
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "ARMarkers", bundle: Bundle.main) {
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = trackingImages.count
            print("Images found \(trackingImages.count)")
        }
    }
        
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let imageName = imageAnchor.referenceImage.name
        let newNode = createNodeForImage(named: imageName)
        DispatchQueue.main.async {
            node.addChildNode(newNode)
        }
    }
    
    func createNodeForImage(named imageName: String?) -> SCNNode {
        let node = SCNNode()

        switch imageName {
        case "pi":
            // Create a sphere for Image1
            let sphereGeometry = SCNSphere(radius: 0.1)
            sphereGeometry.firstMaterial?.diffuse.contents = UIColor.red
            node.geometry = sphereGeometry
            node.position = SCNVector3(0, 0.1, 0) // Sobre la superficie

        case "patrick":
            let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.01)
            boxGeometry.firstMaterial?.diffuse.contents = UIColor.systemPink
            node.geometry = boxGeometry
            node.position = SCNVector3(0, 0.1, 0) // Sobre la superficie

        default:
            // Handle other images or default case
            break
        }
        return node
    }

}


