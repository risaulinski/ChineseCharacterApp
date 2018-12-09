//
//  CharacterDetailsViewController.swift
//  ChineseCharacterApp
//
//  Created by Risa Ulinski on 10/16/18.
//  Copyright © 2018 Hamilton College CS Senior Seminar. All rights reserved.
//

import UIKit
import CoreData

class CharacterDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //@IBOutlet weak var chineseCharLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var pinyinLabel: UILabel!
    @IBOutlet weak var charDisplayLabel: UILabel!
    @IBOutlet weak var shapeView: ShapeView!
    @IBOutlet weak var strokeCollectionView: UICollectionView!
    
    var currModule:Module? = nil
    var currChar:ChineseChar? = nil
    var imageView = UIImageView(image: UIImage(named: "hintPoint"))    // used to diplay hint dots

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //chineseCharLabel.text = currChar?.char
        englishLabel.text = currChar?.definition
        pinyinLabel.text = currChar!.pinyin.count > 0 ? currChar?.pinyin[0] : "none"
        charDisplayLabel.text = currChar?.char
        strokeCollectionView.delegate = self
        strokeCollectionView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        charDisplayLabel.font = charDisplayLabel.font.withSize(charDisplayLabel.frame.size.height*0.9)
    }
    
    // If going back to the module details view, send the current module
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destination = segue.destination as? ModuleDetailsViewController {
            destination.module = currModule
        }
    }
    
    
    //------------------------------ FUNCTIONS FOR STROKE COLLECTION VIEW -----------------------------//
    
    // for each stroke the user drew, create a box in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currChar!.strokes.count

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.height
        let itemHeight = collectionView.bounds.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    // Set up the collection view cell at indexpath to show the correct stroke
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "strokeCell", for: indexPath) as! StrokeCollectionViewCell
        // Check to make sure there is a char
        guard let char = currChar else {
            return cell
        }
        let rowNumber : Int = indexPath.row
        let scaleFactor = cell.frame.width/shapeView.frame.width
        drawStroke(shapeView: cell.strokeShapeView, rowNumber, highlighted: true, scaleFactor: scaleFactor)
        
        cell.strokeView.layer.borderWidth = 1
        cell.strokeView.layer.borderColor = UIColor.black.cgColor
        
        cell.strokeLabel.font = cell.strokeLabel.font.withSize(cell.frame.height*0.9)
        cell.strokeLabel.text = String(char.char)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.imageView.isDescendant(of: shapeView) {
            self.imageView.removeFromSuperview()
        }
        let rowNumber = indexPath.row
        guard let char = currChar
            else {
                return
        }
        shapeView.clearCanvas()
        drawStroke(shapeView: shapeView, rowNumber, highlighted: true)
  
        // Draw correct start point
        if rowNumber < char.strokes.count {
            let dim = self.shapeView.frame.width
            let matcher = Matcher()
            let points = matcher.get_hints(char.strokes, destDimensions: (north: 0, south: Double(dim), east: 0, west: Double(dim)))[rowNumber]
            self.drawPointOnCanvas(x: Double(points.x), y:  Double(points.y), view: shapeView, point: imageView)
        }
        
    }
    
    func drawStroke(shapeView: ShapeView, _ num: Int, highlighted: Bool = false, scaleFactor: CGFloat = 1) {
        let char = currChar!
        if num < char.strokes.count {
            let dim = shapeView.frame.width
            let lineWidth = CGFloat(dim/14 - 10)
            shapeView.drawChar(stroke:char.strokes[num], scale: SVGConverter().make_canvas_dimension_converter(from: (0,500,500,0), to: (0,Double(dim),Double(dim),0)), width: lineWidth)
        }
    }
    
    // Draws a red bullseye with size 1/16th of the drawing view at a given point
    func drawPointOnCanvas(x:Double,y:Double,view:UIView, point: UIImageView) {
        let pointRadius = Double(view.frame.height / 16)
        point.frame = CGRect(x: x - pointRadius/2, y: y - pointRadius/2, width: (pointRadius), height: (pointRadius))
        view.addSubview(imageView)
    }
    
    func displayGrid() {
        shapeView.backgroundColor = UIColor(patternImage: UIImage(named: "chineseGrid.png")!)
        shapeView.contentMode =  UIView.ContentMode.scaleAspectFill
        UIGraphicsBeginImageContext(shapeView.frame.size);
        var image = UIImage(named: "chineseGrid")
        image?.draw(in: shapeView.bounds)
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        shapeView.backgroundColor = UIColor(patternImage: image!)
    }
    
    

}


