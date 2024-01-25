//
//  ImageMarkerRemote.swift
//
//  Created by Ricardo on 24/01/24.
//

import UIKit
import ARKit

class ImageMarkerRemoteViewController: SceneViewController, ARSCNViewDelegate {
    
    var configuration = ARImageTrackingConfiguration()
    
    private let imageURL = "https://...png"
    private let imageIdentifier = "DynamicImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.delegate = self
        setupARSessionWithDownloadedImage()
    }
    
    func setupARSessionWithDownloadedImage() {
        guard let imageUrl = URL(string: imageURL)
        else { return }
        
        downloadImage(from: imageUrl) { downloadedImage in
            guard let cgImage = downloadedImage?.cgImage else { return }
            let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.2) // Set the physical width in meters
            referenceImage.name = self.imageIdentifier // Name the image for later reference
            //            let configuration = ARWorldTrackingConfiguration()
            //            configuration.detectionImages = [referenceImage]
            let configuration = ARImageTrackingConfiguration()
            configuration.trackingImages = [referenceImage]
            print("imagenes \(configuration.trackingImages.count)")
            configuration.worldAlignment = .gravity
            self.sceneView.session.run(configuration)
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
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
        case self.imageIdentifier:
            let sphereGeometry = SCNSphere(radius: 0.1)
            sphereGeometry.firstMaterial?.diffuse.contents = UIColor.red
            node.geometry = sphereGeometry
            node.position = SCNVector3(0, 0.1, 0) // Sobre la superficie
        default:
            // Handle other images or default case
            break
        }
        return node
    }
    
}


