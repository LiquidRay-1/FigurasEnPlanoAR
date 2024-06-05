//
//  ViewController.swift
//  figuras_planoHorizontal
//
//  Created by Liquid on 4/6/24.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var plano: UILabel!
    
    @IBOutlet weak var itemCollectionView: UICollectionView!
    let configuration = ARWorldTrackingConfiguration()
    
    let itemsArray: [String] = ["basketball", "football", "medusa", "therock"]
    
    var selectedItem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.itemCollectionView.delegate = self
        self.itemCollectionView.dataSource = self
        self.registerGestureRecognizer()
        self.sceneView.delegate = self
    }
    
    func registerGestureRecognizer(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
            print("Hay superficie horizontal")
        }else{
            print("No hay superficies")
        }
    }
    
    @objc func rotate(sender: UILongPressGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation, options: nil)
        
        if !hitTest.isEmpty {
            let result = hitTest.first!
            let node = result.node
            
            if sender.state == .began {
                let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
                node.runAction(rotation)
            } else if sender.state == .ended {
                print("quitando el dedo")
                node.removeAllActions()
            }
        }
    }

    
    @objc func pinch(sender: UIPinchGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty{
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            print(sender.scale)
            node.runAction(pinchAction)
            
            sender.scale = 1.0
        }
    }
    
    func addItem(hitTestResult: ARHitTestResult){
        if let selectedItem = self.selectedItem{
            let scene = SCNScene(named: "art.scnassets/\(selectedItem).scn")
            let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))
            let transform = hitTestResult.worldTransform
            let terceraColumna = transform.columns.3
            node?.position = SCNVector3(terceraColumna.x, terceraColumna.y, terceraColumna.z)
            self.sceneView.scene.rootNode.addChildNode(node!)
            node?.scale = SCNVector3(0.2, 0.2, 0.2)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.plano.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                self.plano.isHidden = true
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
        cell.nameLabel.text = self.itemsArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! itemCell
        cell.backgroundColor = UIColor.green
        self.selectedItem = cell.nameLabel.text
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
}
