//
//  DrawCharacterViewController.swift
//  ChineseCharacterApp
//
//  Created by Risa Ulinski on 9/25/18.
//  Copyright © 2018 Hamilton College CS Senior Seminar. All rights reserved.
//

import UIKit

class DrawCharacterViewController: UIViewController {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var Recognizer: Recognizer!
    var backgroundChar: UIImage!
    
    
    @IBAction func hintButtonTapped(_ sender: Any) {
        drawingView.backgroundColor = UIColor(patternImage: backgroundChar)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.drawingView.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        drawingView.clearCanvas()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        let char_data =  ["M 463 291 Q 469 90 450 74 Q 444 70 361 87 Q 349 90 350 82 Q 351 76 361 69 Q 434 8 458 -27 Q 471 -43 486 -30 Q 520 1 519 70 Q 513 125 512 270 Q 513 304 524 329 Q 533 347 517 359 Q 492 380 464 390 Q 446 396 439 389 Q 433 382 443 368 Q 465 331 463 291 Z","M 319 255 Q 291 204 253 161 Q 232 137 242 101 Q 246 85 268 93 Q 320 121 336 199 Q 343 227 341 252 Q 337 259 332 262 Q 325 261 319 255 Z","M 559 192 Q 583 156 607 115 Q 614 102 626 99 Q 633 98 640 105 Q 647 115 648 139 Q 649 161 624 186 Q 566 237 551 234 Q 547 233 545 223 Q 545 213 559 192 Z","M 639 246 Q 684 194 735 118 Q 747 99 760 92 Q 767 91 776 98 Q 789 108 783 150 Q 779 202 644 274 Q 637 280 633 269 Q 632 256 639 246 Z"]
        for stroke in char_data {
            drawingView.drawChar(stroke)}
        //Recognize()
        //drawingView.clearCanvas()
//        switchChar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundChar = UIImage(named: fire ? "kanji_mizu_water" : "fire")
        // Do any additional setup after loading the view.
    }
    
    var fire = false
    func switchChar() {
        backgroundChar = UIImage(named: fire ? "kanji_mizu_water" : "fire")
        fire = !fire
        //drawingView.clearCanvas()
    }
     func Recognize() {
//        let instanceOfRecognizer = Recognizer()
        let result = Recognizer.recognize(source: [(2,5),(10,6),(15,5)], target:[(2,5),(15,5)], offset: 0)
        print(result.score)
    }


}
