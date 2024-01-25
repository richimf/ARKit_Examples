//
//  SceneViewController.swift
//
//  Created by Ricardo on 25/01/24.
//

import UIKit
import ARKit

class SceneViewController: UIViewController {
    
    lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        self.view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20.0).isActive = true
        return sceneView
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Close", for: .normal)
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10.0).isActive = true
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        return button
    }()
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
    }
}
