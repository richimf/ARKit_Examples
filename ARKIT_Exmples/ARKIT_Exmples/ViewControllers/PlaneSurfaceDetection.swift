//
//  Model3DinViewController.swift
//
//  Created by Ricardo on 18/01/24.
//

import UIKit
import ARKit

// In ViewController.swift file first we need to detect the horizontal planes using ARSCNViewDelegate delegate.
final class PlaneSurfaceDetectionWith3Dmodel: SceneViewController {
    //
    //    ARWorldTrackingConfiguration is a class that enables developers to track the device’s position and orientation in the world.
    //    It provides a set of properties that can be used to customize the tracking experience. For example,
    //    you can enable plane detection to detect horizontal surfaces in the environment,
    //    or enable light estimation to enable realistic lighting of virtual objects.
    //
    private let configuration = ARWorldTrackingConfiguration()
    //
    //    Using ARWorldTrackingConfiguration in Swift is straightforward.
    //    First, you need to create an ARWorldTrackingConfiguration object and set its properties.
    //    Then, you call the run() method on your ARSession to start the tracking.
    //    let configuration = ARWorldTrackingConfiguration()
    //    configuration.planeDetection = .horizontal
    //
    //    let arSession = ARSession()
    //    arSession.run(configuration)
    //
    //
    private let scene = SCNScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true  // estamos agregando luz de manera unidireccional sobre la escena

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        configuration.planeDetection = [.horizontal, .vertical]

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let tappedLocation = recognizer.location(in: sceneView)
        let hitResult = sceneView.session.raycast(sceneView.raycastQuery(from: tappedLocation,
                                                                         allowing: .estimatedPlane,
                                                                         alignment: .horizontal)!)
        if !hitResult.isEmpty{
            self.add3DObject(result: hitResult.first!)
        }
    }
    
    // sceneName: "art.scnassets/arrow.scn"
    // childNodeName: "GroguToy"
    //
    func add3DObject(result: ARRaycastResult,
                     sceneName: String = "art.scnassets/Grogu.scn",
                     childNodeName: String = "GroguToy") {
        guard let sceneObject = SCNScene(named: sceneName) else { print("no se cargo scn.")
            return }
        guard let childNode = sceneObject.rootNode.childNode(withName: childNodeName, recursively: true) else {
            print("error")
            return }
        childNode.position = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z)
        childNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        self.scene.rootNode.addChildNode(childNode)
    }
}

// In ViewController.swift file first we need to detect the horizontal planes using ARSCNViewDelegate delegate.
extension PlaneSurfaceDetectionWith3Dmodel: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Add a node when a new plane is detected")
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        self.createPlane(planeAnchor: planeAnchor, node: node)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else{return }
        print(planeAnchor.center)
        print(planeAnchor.extent)
        self.updatePlane(planeAnchor: planeAnchor, node: node)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        node.enumerateChildNodes { childNode, _ in
            childNode.removeFromParentNode()
        }
    }
    
    func createPlane(planeAnchor: ARPlaneAnchor,node: SCNNode){
        let planeGeomentry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        planeGeomentry.materials.first?.diffuse.contents = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 0.6022350993)
        planeGeomentry.materials.first?.isDoubleSided = true
        let planeNode = SCNNode(geometry: planeGeomentry)
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0.0, z: planeAnchor.center.z)
        planeNode.eulerAngles = SCNVector3(x: Float(Double.pi) / 2, y: 0, z: 0)
        node.addChildNode(planeNode)
    }
    
    func updatePlane(planeAnchor: ARPlaneAnchor, node: SCNNode){
        if let planeNode = node.childNodes.first{
            if let planeGeomentry = node.childNodes.first?.geometry as? SCNPlane{
                planeGeomentry.width = CGFloat(planeAnchor.extent.x)
                planeGeomentry.height = CGFloat(planeAnchor.extent.z)
                planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0.0, z: planeAnchor.center.z)
            }
        }
    }
}

//func restartSession() {
//        // cuando pausas la sesion, terminas de hacer tracking de tu posicion.
//        self.sceneView.session.pause()
//        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
//            node.removeFromParentNode()
//        }
//        // una vez removido los nodos, reseteamos la configuracion.
//        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//    }
//
