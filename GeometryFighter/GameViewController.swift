//
//  GameViewController.swift
//  GeometryFighter
//
//  Created by rkwright on 12/30/20.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var scnView     : SCNView!
    var scnScene    : SCNScene!
    var cameraNode  : SCNNode!
    var spawnTime   : TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        
       // createTrail(color: <#T##UIColor#>, geometry: <#T##SCNGeometry#>)
        //spawnShape()
        emitParticles()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        scnView = self.view as? SCNView
        
        scnView.showsStatistics = true
        
        scnView.allowsCameraControl = true
        
        scnView.autoenablesDefaultLighting = true
        
        scnView.delegate = self
        
        scnView.isPlaying = true
        
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"
    }
    
    /*
      * Set up a simple perspective camera
     */
    func setupCamera() {
        cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    /*
      * Generate a random shape and add it to the scene.  We'll clean up later.
     */
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
    
    /*
     * As each node falls off the "screen" simply delete it.
     */
    func cleanScene() {
        // 1
        for node in scnScene.rootNode.childNodes {
            // 2
            if node.presentation.position.y < -2 {
                // 3
                node.removeFromParentNode()
            }
        }
    }
    
    /*
     *
     */
    func emitParticles() {
        scnView = self.view as? SCNView
        
        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 5000
        particleSystem.particleLifeSpan = 1
        particleSystem.warmupDuration = 1
        particleSystem.emissionDuration = 100.0
        particleSystem.loops = false
        particleSystem.particleColor = .yellow
        particleSystem.birthDirection = .random
        particleSystem.speedFactor = 7
        particleSystem.emittingDirection = SCNVector3(0,1,1)
        particleSystem.emitterShape = .some(SCNSphere(radius: 15.0))
        particleSystem.spreadingAngle = 90
        particleSystem.particleImage = "star"
        
        let particlesNode = SCNNode()
        //particlesNode.scale = SCNVector3(2,2,2)
        particlesNode.addParticleSystem(particleSystem)
        
        scnView.scene!.rootNode.addChildNode(particlesNode)
    }
    
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let scene = SCNScene(named: "GeometryFighter.scnassets/Scenes/Trail.scn")
        let node:SCNNode = (scene?.rootNode.childNode(withName: "Trail", recursively: true)!)!
        let particleSystem:SCNParticleSystem = (node.particleSystems?.first)!
        particleSystem.particleColor = color
        particleSystem.emitterShape = geometry
        return particleSystem
    }

}

/*
 * Extension protocol so we can handle the render loop calls
 */
extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if time > spawnTime {
            
            cleanScene()
            spawnShape()
            
            spawnTime = time + TimeInterval(Float.random(min: 0.2, max: 1.5))
        }
        
    }
}

