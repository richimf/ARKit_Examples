//
//  ViewController.swift
//
//  Created by Ricardo on 10/01/24.
//

import UIKit

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func gotoPlaneSurfaceDetectionWith3Dmodel(sender: UIButton) {
        gotoViewController(PlaneSurfaceDetectionWith3Dmodel())
    }
    
    @IBAction func gotoQRScanner(sender: UIButton) {
        gotoViewController(QRCodeDetectorViewController())
    }
    
    @IBAction func gotoSCNNodeExample(sender: UIButton) {
        gotoViewController(SimpleNodeExampleViewController())
    }
    
    @IBAction func gotoPathExample(sender: UIButton) {
        gotoViewController(PathBetweenNodesViewController())
    }
    
    @IBAction func gotoWallDetectionExample(sender: UIButton) {
        gotoViewController(WallDetectionViewController())
    }
    
    @IBAction func gotoLightSpotExample(sender: UIButton) {
        gotoViewController(LightSpotViewController())
    }
    
    @IBAction func gotoImageMarkers(sender: UIButton) {
        gotoViewController(ImageMarkersViewController())
    }
    
    @IBAction func gotoImageMarkersDownloaded(sender: UIButton) {
        gotoViewController(ImageMarkerRemoteViewController())
    }
    
    private func gotoViewController(_ vc: UIViewController) {
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

