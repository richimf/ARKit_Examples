//
//  QRCodeDetector.swift//
//  Created by Ricardo on 17/01/24.
//

import UIKit
import ARKit

//
//   *** ARSCNViewDelegate ***
//   Metodos para mediar la sincronizacion automatica del contenido de SceneKit con una sesion de ARSession.
//
//   Este protocolo sirve para proporcionar contenido de SceneKit a objetos de ARAnchor. Objetos rastreados por la sesion ARSession.
//   Tambien para gestionar la actualizacion automatica de dicho contenido en la vista.
//
//   This protocol extends the ARSessionObserver protocol, so your session delegate can also implement those
//   methods to respond to changes in session status.


//
//   *** ARSessionDelegate ***
//   Metodos para recibir imagenes de fotogramas de video capturados y tambien el estado de seguimiento de una sesion de ARSession.
//
//   Implement this protocol if you need to work directly with ARFrame objects captured by the session or directly
//   follow changes to the session's set of tracked ARAnchor objects. Typically, you adopt this protocol when building
//   a custom view for displaying AR content—if you display content with SceneKit or SpriteKit,
//   the ARSCNViewDelegate and ARSKViewDelegate protocols provide similar information and integrate with those technologies.
//   This protocol extends the ARSessionObserver protocol, 
//   so your session delegate can also implement those methods to respond to changes in session status.
//

final class QRCodeDetectorViewController: SceneViewController, ARSCNViewDelegate, ARSessionDelegate {

    private let configuration = ARWorldTrackingConfiguration()
    private var qrRequests = [VNRequest]()
    private var detectedDataAnchor: ARAnchor?
    private var processing = false
    private let scene = SCNScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self                     // ARSCNViewDelegate
        sceneView.session.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.showsStatistics = true              // Show statistics such as fps and timing information
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true   // Estamos agregando luz de manera unidireccional sobre la escena
        startQrCodeDetection()
    }
    
    private func startQrCodeDetection() {
        let request = VNDetectBarcodesRequest(completionHandler: self.requestHandler)
        // If you want to detect QR only:
        request.symbologies = [.qr]
        self.qrRequests = [request]
    }
    
    private func requestHandler(request: VNRequest, error: Error?) {
        if let results = request.results, let result = results.first as? VNBarcodeObservation {
            //  guard let payload = result.payloadStringValue else { return }
            let rect = result.boundingBox
            let center = CGPoint(x: rect.midX, y: rect.midY)
            DispatchQueue.main.async {
                self.hitTestQrCode(center: center)
                // self.addGeometry()
                self.processing = false
            }
        } else {
            self.processing = false
        }
    }
    
    func hitTestQrCode(center: CGPoint) {
        let hitTestResults = self.sceneView.hitTest(center, types: [.featurePoint, .existingPlaneUsingExtent])
        if let hitTestResult = hitTestResults.first {
            if let detectedDataAnchor = self.detectedDataAnchor,
               let node = self.sceneView.node(for: detectedDataAnchor) {
                // node.transform = SCNMatrix4(hitTestResult.worldTransform)
                // self.sceneView.scene.rootNode.addChildNode(node)
                let worldTransform = node.simdWorldPosition // funciona muy bien.
                node.position = SCNVector3(worldTransform.x, worldTransform.y, 0)
            } else {
                self.detectedDataAnchor = ARAnchor(transform: hitTestResult.worldTransform)
                self.sceneView.session.add(anchor: self.detectedDataAnchor!)
            }
        }
    }
    
    // MARK: - ARSession Delegate
    // *** Handling Content Updates ***
    // Tells the delegate that one or more anchors have been added to the session.
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor, imageAnchor.referenceImage.name == "ARmarker" {
                // Detected ARCode position and orientation
                let arCodePosition = imageAnchor.transform
                
                // Iterate over nodes in the scene and apply transformation
                sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    // Adjust each node's position based on the ARCode's position
                    node.transform = SCNMatrix4Mult(node.transform, SCNMatrix4(arCodePosition))
                    print("Node position: \(node.position)")
                }
                // Optionally, reset or adjust your AR session configuration here
            }
        }
    }
    
    // Tells the delegate that the session has adjusted the properties of one or more anchors.
    //  func session(ARSession, didUpdate: [ARAnchor]) { }

    //  Tells the delegate that one or more anchors have been removed from the session.
    //  func session(ARSession, didRemove: [ARAnchor]) { }
    

    // *** Receiving Camera Frames ***
    // Provides a newly captured camera image and accompanying AR information to the delegate.
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if self.processing {
                    return
                }
                self.processing = true
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage,
                                                                options: [:])
                try imageRequestHandler.perform(self.qrRequests)
            } catch {
                
            }
        }
    }
    

    // MARK: - ARSCNView Delegate
    // Handling Content Updates (there are more render functions)
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if self.detectedDataAnchor?.identifier == anchor.identifier {
            let sphere = SCNSphere(radius: 0.05)
            sphere.firstMaterial?.diffuse.contents = UIColor.green
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.transform = SCNMatrix4(anchor.transform)
            return sphereNode
        }
        return nil
    }
    
    //    func addGeometry() {
    //        let node = SCNNode()
    //        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.03)
    //        node.geometry?.firstMaterial?.specular.contents = UIColor.white
    //        node.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
    //        node.position = SCNVector3(0,0,0)
    //        self.sceneView.scene.rootNode.addChildNode(node)
    //    }
    
}
