//
//  GameViewController.swift
//  GeometryFighter
//
//  Created by rkwright on 12/30/20.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    setupScene()
    setupCamera()
    
    spawnShape()
  }

  override var shouldAutorotate: Bool {
    return true
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
    
    func setupView() {
      scnView = self.view as! SCNView
        
        // 1
        scnView.showsStatistics = true
        // 2
        scnView.allowsCameraControl = true
        // 3
        scnView.autoenablesDefaultLighting = true

    }

    func setupScene() {
      scnScene = SCNScene()
      scnView.scene = scnScene
        
      scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"

    }

    func setupCamera() {
      // 1
      cameraNode = SCNNode()
      // 2
      cameraNode.camera = SCNCamera()
      // 3
      cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
      // 4
      scnScene.rootNode.addChildNode(cameraNode)
    }

    func spawnShape() {
      
        var shapeNode:SCNNode
      
      switch ShapeType.random() {
        
        case ShapeType.sphere:
            let sphere = SCNSphere(radius: 1.0)
            shapeNode = SCNNode(geometry: sphere)
            sphere.materials.first?.diffuse.contents = UIColor.random()

        case ShapeType.pyramid:
            let pyra = SCNPyramid(width: 1.0, height:1.0, length:1.0)
            shapeNode = SCNNode(geometry: pyra)
            pyra.materials.first?.diffuse.contents = UIColor.random()

        case ShapeType.torus:
            let tor = SCNTorus(ringRadius: 1.0, pipeRadius:1.0)
            shapeNode = SCNNode(geometry: tor)
            tor.materials.first?.diffuse.contents = UIColor.random()

        case ShapeType.capsule:
            let caps = SCNCapsule(capRadius: 1.0, height:1.0)
            shapeNode = SCNNode(geometry: caps)
            caps.materials.first?.diffuse.contents = UIColor.random()

        case ShapeType.cylinder:
            let cyl = SCNCylinder(radius: 1.0, height:1.0)
            shapeNode = SCNNode(geometry: cyl)
            cyl.materials.first?.diffuse.contents = UIColor.random()

        case ShapeType.cone:
            let con = SCNCone(topRadius: 0.0, bottomRadius:1.0, height:1.0)
            shapeNode = SCNNode(geometry: con)
            con.materials.first?.diffuse.contents = UIColor.random()

        case ShapeType.tube:
            let tub = SCNTube(innerRadius: 0.5, outerRadius:1.0, height:1.0)
            shapeNode = SCNNode(geometry: tub)
            tub.materials.first?.diffuse.contents = UIColor.random()

        default:           // default is a ShapeType.box
            let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
            shapeNode = SCNNode(geometry: box)
            box.materials.first?.diffuse.contents = UIColor.random()
     }
            
      shapeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

        
        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)
        
        let force = SCNVector3(x: randomX, y: randomY , z: 0)
        
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        shapeNode.physicsBody?.applyForce(force, at: position, asImpulse: true)

        scnScene.rootNode.addChildNode(shapeNode)
    }

}
