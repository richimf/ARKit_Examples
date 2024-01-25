//
//  SCNVector3+Ext.swift
//
//  Created by Ricardo on 24/01/24.
//

import Foundation
import ARKit

/*/ Extension - SCNVector3
 This extends SCNVector3. This is used to find the distance from one SCNVector3 to anther SCNVector3.
 */
extension SCNVector3 {
    /*/ distance(receiver: SCNVector3) -> Float
     returns the distance from one SCNVector3 to another SCNVector3
     
     @param: SCNVector3 - the position of the other SCNVector3
     
     @return: Float - the distance between the two SCNVector3
     */
    func distance(receiver: SCNVector3) -> Float {
        let xd = self.x - receiver.x
        let yd = self.y - receiver.y
        let zd = self.z - receiver.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        if distance < 0 {
            return distance * -1
        } else {
            return distance
        }
    }
    
    
    
    
}

/*/ Extension - SCNNode
 This extends SCNNode. This is used to find the distance from one SCNNode to another SCNNode.
 */
extension SCNNode {
    /*/ distance(receiver: SCNNode) -> Float
     returns the distance from one SCNNode to another SCNNode
     
     @param: SCNNode - the position of the other SCNNode
     
     @return: Float - the distance between the two SCNNode
     */
    func distance(receiver: SCNNode) -> Float {
        let node1Pos = self.position
        let node2Pos = receiver.position
        let xd = node2Pos.x - node1Pos.x
        let yd = node2Pos.y - node1Pos.y
        let zd = node2Pos.z - node1Pos.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        if distance < 0 {
            return distance * -1
        } else {
            return distance
        }
    }
}

/*/ Extension - SCNGeometry
 This extends SCNGeometry. This is used to create a line from one SCNVector3 to another SCNVector3, and return that line as a node.
 */
extension SCNGeometry {
    /*/ cylinderLine(from: SCNVector3, to: SCNVector3, segments: Int) -> SCNNode
     returns a SCNNode which represents a line from one SCNVector3 to another SCNVector3
     
     @param: from - the position of the other SCNNode
     @param: to - the position of the other SCNNode
     @param: segments - the number of segments
     
     @return: SCNNode - the SCNNode containning the line
     */
    class func cylinderLine(from: SCNVector3, to: SCNVector3, segments: Int) -> SCNNode{
        let x1 = from.x
        let x2 = to.x
        
        let y1 = from.y
        let y2 = to.y
        
        let z1 = from.z
        let z2 = to.z
        
        let distance = sqrtf((x2 - x1) * (x2 - x1) +
            (y2 - y1) * (y2 - y1) +
            (z2 - z1) * (z2 - z1))
        
        //Creates a SCNCylinder with the height of it being the distance from the two SCNVector3
        let cylinder = SCNCylinder(radius: 0.005, height: CGFloat(distance))
        
        cylinder.radialSegmentCount = segments
        cylinder.firstMaterial?.diffuse.contents = UIColor.white
        
        let lineNode = SCNNode(geometry: cylinder)
        
        //Sets the position of the lineNode's center to the inbetween of the first SCNVector3 and second SCNVector3. This accounts fo the proper size of the line segment when added to the source node (marker node).
        lineNode.position = SCNVector3(((from.x + to.x)/2),
                                       ((from.y + to.y)/2),
                                       ((from.z + to.z)/2))
        
        //Handles the orientation of the line
        lineNode.eulerAngles = SCNVector3(Float.pi/2,
                                          acos((to.z - from.z)/distance),
                                          atan2(to.y - from.y, to.x - from.x))
        
        return lineNode
    }
}
extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [UInt32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
