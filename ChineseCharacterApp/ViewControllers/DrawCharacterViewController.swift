//
//  DrawCharacterViewController.swift
//  ChineseCharacterApp
//
//  A
//
//  Created by Risa Ulinski on 9/25/18.
//  Copyright © 2018 Hamilton College CS Senior Seminar. All rights reserved.
//

import UIKit

class DrawCharacterViewController: UIViewController {

    //top bar items
    @IBOutlet weak var progressBar: UIProgressView! //progress bar to display progress in the current learning session
    @IBOutlet weak var exitButton: UIButton! //button to exit current learning session
    @IBOutlet weak var optionsButton: UIButton! //TO DO: figure out what this does
    
    // Character information
    @IBOutlet weak var audioButton: UIButton! // Stretch goal-> get audio for characters
    
    @IBOutlet weak var drawingView: DrawingView! // a canvas to draw characters on
    @IBOutlet weak var backgroundCharLabel: UILabel! // for level 0 to display the curr char
    
    // Controls for the drawing view
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var module:Module? = nil
    var ls:LearningSesion? = nil
    var backgroundChar: UIImage!
    
    // When hint button is tapped, give the user the correct hint, based on their
    // level for the current character
    // TO DO: implement this
    @IBAction func hintButtonTapped(_ sender: Any) {
        //drawingView.backgroundColor = UIColor(patternImage: backgroundChar)
        displayCharInView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.backgroundCharLabel.text = ""
        }
        
        switch ls!.level {
        case 0:
            // if level is 0, display entire character
            displayCharInView()
        case 1:
            print("1")
        case 2:
            print("2")
        case 3:
            print("3")
        default:
            print("undefined level")
        }
    }
    
    // When undo is tapped, clear the screen
    // TO DO: make this clear only the most recent stroke
    @IBAction func undoButtonTapped(_ sender: Any) {
        drawingView.clearCanvas()
    }
    
    // When exit button is tapped, display popup to make sure the user wants to
    // quit the current learning session
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        let alert:UIAlertController = UIAlertController(title:"Cancel", message:"Are you sure you want to cancel?", preferredStyle: .actionSheet)
        let yesAction:UIAlertAction = UIAlertAction(title:"Yes", style: .destructive)
        { (_:UIAlertAction) in
            self.performSegue(withIdentifier: "DrawHome", sender: self)
        }
        let noAction:UIAlertAction = UIAlertAction(title:"No", style: .cancel)
        { (_:UIAlertAction) in
            print("No")
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated:true)
    }
    
    // When the character has been submitted by the user, ???
    // TO DO: implement this
    @IBAction func submitButtonTapped(_ sender: Any) {
        //Recognize()
        //drawingView.clearCanvas()
        progressBar.setProgress(Float(ls!.progress()), animated: true)
        switchChar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //backgroundChar = UIImage(named: fire ? "kanji_mizu_water" : "fire")
        ls = LearningSesion(charsToPractice: module!.chineseChars,level: 0)
        

    }
    
    var fire = false
    func switchChar() {
        backgroundChar = UIImage(named: fire ? "kanji_mizu_water" : "fire")
        fire = !fire
        //drawingView.clearCanvas()
    }
    func setupCharDisplay() {
        switch ls!.level {
        case 0:
            // if level is 0, display entire character in the background of the
            displayCharInView()
        case 1:
            print("1")
        case 2:
            print("2")
        case 3:
            print("3")
        default:
            print("error: undefined level")
        }
    }

    func displayCharInView() {
        //let char = ls!.getCurrentChar()
        var charChar: String
        charChar = "门"
        backgroundCharLabel.text = charChar
        let size: CGFloat = drawingView.frame.size.width
        backgroundCharLabel.font = backgroundCharLabel.font.withSize(size)
    }
    
    func Recognize() {
        let instanceOfRecognizer = Recognizer()
        let result = instanceOfRecognizer.recognize(source: [(2,5),(10,6),(15,5)], target:[(2,5),(15,5)], offset: 0)
        print(result.score)
    }


}
