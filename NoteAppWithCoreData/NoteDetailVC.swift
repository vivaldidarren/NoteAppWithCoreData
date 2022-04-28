//
//  ViewController.swift
//  NoteAppWithCoreData
//
//  Created by Vivaldi Darren Christophilus on 27/04/22.
//

import UIKit
import CoreData

class NoteDetailVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var saveAction: UIButton!
    
    var selectedNote: Note? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        
        titleTF.inputView = datePicker
        titleTF.text = formatDate(date: Date())
        
//        descTV.layer.borderWidth = 0.5
//        descTV.layer.cornerRadius = 10
        descTV.layer.borderColor = UIColor.systemGray3.cgColor
        
        descTV.delegate = self
        
        if(selectedNote != nil) {
            titleTF.text = selectedNote?.title
            descTV.text = selectedNote?.desc
        } else {
            descTV.text = "write your tasks here..."
            descTV.textColor = UIColor.lightGray
            descTV.returnKeyType = .done
        }
    }
    
    
    @objc func dateChange(datePicker: UIDatePicker) {
        titleTF.text = formatDate(date: datePicker.date)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "write your tasks here..." {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//        }
//        return true
//    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            descTV.text = "write your tasks here..."
            descTV.textColor = UIColor.lightGray
        }
    }

    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        if(selectedNote == nil) {
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            let newNote = Note(entity: entity!, insertInto: context)
            
            newNote.id = noteList.count as NSNumber
            newNote.title = titleTF.text
            newNote.desc = descTV.text
            
            do {
                try context.save()
                noteList.append(newNote)
                navigationController?.popViewController(animated: true)
            }
            catch {
                print("context save error")
            }
        } else {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! Note
                    if(note == selectedNote){
                        note.title = titleTF.text
                        note.desc = descTV.text
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            } catch  {
                print("fetch failed")
            }
        }
    }
    

    @IBAction func deleteAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        do {
            let results:NSArray = try context.fetch(request) as NSArray
            for result in results {
                let note = result as! Note
                if(note == selectedNote){
                    note.deletedDate = Date()
                    try context.save()
                    navigationController?.popViewController(animated: true)
                }
            }
        } catch  {
            print("fetch failed")
        }
    }
    
}

