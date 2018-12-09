//
//  ModuleDetailsViewController.swift
//
//  Called from the modulesVie, this view displays the details of a module
//  including the following:
//    - name
//    - a list of the characters in the module.
//  Also allows the user to begin a practice session for the characters
//  in the module at a level selected in the practice level view
//  or see the details of a character by selecting it from the table
//
//  ChineseCharacterApp
//  Created by Risa Ulinski on 10/3/18.
//  Copyright © 2018 Hamilton College CS Senior Seminar. All rights reserved.
//

import UIKit
import CoreData

class ModuleDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //top bar items
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topBarLabel: UILabel!
    @IBOutlet weak var moreOptionsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    //Labels
    @IBOutlet weak var moduleNameLabel: UILabel!
    
    //Start Practice Session Buttons
    @IBOutlet weak var practiceAllCharactersButton: UIButton!
    
    //Table to display characters in module
    @IBOutlet weak var moduleCharactersTableView: UITableView!
    let cellReuseIdentifier = "charCell"
    
    var module:Module? = nil //the module to display
    
    //Practice Level View
    @IBOutlet weak var practiceLevelView: UIView!
    
    //Practice Level buttons
    @IBOutlet weak var levelOne: UIButton!
    @IBOutlet weak var levelTwo: UIButton!
    @IBOutlet weak var levelThree: UIButton!
    
    var level = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display module's name in view
        moduleNameLabel.text = (module != nil) ?  module!.name : ""
        
        practiceLevelView.isHidden = true
    }
    
    //Create a row in the table view for each character in the module
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let chars = self.module?.chineseChars {
           return chars.count
        }
        return 0    }
    
    // Display the practice level popup
    @IBAction func practiceLevelPopup(_ sender: Any) {
        practiceLevelView.isHidden = false
    }
    
    @IBAction func levelOneClicked(_ sender: Any) {
        level = 1
        self.performSegue(withIdentifier: "ModuleDraw", sender: self)
    }
    
    @IBAction func levelTwoClicked(_ sender: Any) {
        level = 2
        self.performSegue(withIdentifier: "ModuleDraw", sender: self)
    }
    
    @IBAction func levelThreeClicked(_ sender: Any) {
        level = 3
        self.performSegue(withIdentifier: "ModuleDraw", sender: self)
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a new cell with the reuse identifier of our prototype cell
        // as our custom table cell class
        let cell = tableView.dequeueReusableCell(withIdentifier:"charCell") as! CharacterInModuleTableViewCell
        
        // Set the text labels to the chinese, english and pinyin respectively
        cell.chineseCharLabel.text = module?.chineseChars[indexPath.row].char
        cell.englishLabel.text = module?.chineseChars[indexPath.row].definition
        cell.pinyinLabel.text = module?.chineseChars[indexPath.row].pinyin.joined()
        //cell.pinyinLabel.text = "DON'T KNOW YET"
        cell.clipsToBounds = true
        
        // Return our new cell for display
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You tapped cell number \(indexPath.section).")
    }
    
    // If view transitions to the characterDetailsView (ie a table cell is selected),
    // get character from the selected row and send it to the new view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destination = segue.destination as? CharacterDetailsViewController {
            destination.currModule = module!
            let selectedrow = moduleCharactersTableView.indexPathForSelectedRow!.row
            destination.currChar = module?.chineseChars[selectedrow]
        }
        else if let destination = segue.destination as? DrawCharacterViewController {
            destination.module = module
            destination.level = level
        }
        else if sender as? UIButton == deleteButton {
            deleteMessage(module: module!)
        }
    }

    func deleteMessage(module : Module) {
        let alert:UIAlertController = UIAlertController(title:"", message:"Are you sure you want to delete this module?", preferredStyle: .alert)
        let yesAction:UIAlertAction = UIAlertAction(title:"Yes", style: .destructive)
        { (_:UIAlertAction) in
            self.deleteModule(module: module)
        }
        let noAction:UIAlertAction = UIAlertAction(title:"No", style: .cancel)
        { (_:UIAlertAction) in
            print("No")
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated:true)
    }
    
    func deleteModule(module : Module) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ModuleContent")
        fetchRequest.predicate = NSPredicate(format: "name = %@", module.name)
        
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                context.delete(object as! NSManagedObject)
            }
        }
        do {
            try context.save()
        }catch{
            print("DID NOT SAVE")
        }
        self.performSegue(withIdentifier: "ModulesView", sender: self)
    }
}
