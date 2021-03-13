//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var items: Results<Item>?
    let realm = try! Realm()
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: RCategory? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory!.name
        if let colorHex = selectedCategory?.color {
            navigationController?.navigationBar.backgroundColor = UIColor.init(hexString: colorHex)
            navigationController?.navigationBar.tintColor = ContrastColorOf(backgroundColor: UIColor(hexString: colorHex)!, returnFlat: true)
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: UIColor(hexString: colorHex)!, returnFlat: true)]
            searchBar.barTintColor = UIColor.init(hexString: colorHex)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Using core data
        //items[indexPath.row].done = !items[indexPath.row].done
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print("Error updating done status \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            let categoryColour = UIColor.init(hexString: selectedCategory!.color )
            
            if let colour = categoryColour?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colour, returnFlat: true)
            }
            
            //value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        textField.placeholder = "Create new item"

        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen once the user hits Add
            //Using Core Data
//            let newItem = TodoItem(context: self.context)
//            newItem.text = textField.text!
//            newItem.done = false
//            newItem.parentCategory = self.selectedCategory
//            self.items.append(newItem)
            
            if let category = self.selectedCategory {
                do {
                    try self.realm.write({
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        category.items.append(newItem)
                    })
                } catch {
                    print("Error saving items: \(error)")
                }
            }
            self.tableView.reloadData()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Saving items using core data
//    func saveItems() {
//        do {
//            try context.save()
//        } catch {
//            print("Error saving item, \(error)")
//        }
//        tableView.reloadData()
//    }
    
    //MARK: - Load items functionality for Core Data
    
//    func loadItems(with request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), using predicate: NSPredicate? = nil) {
//        let predicateForCategory = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, predicateForCategory])
//        } else {
//            request.predicate = predicateForCategory
//        }
//
//        do {
//            items = try context.fetch(request)
//        } catch {
//            print("error: \(error)")
//        }
//        tableView.reloadData()
//    }
    
    //MARK: - Load items functionality for Realm
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete items using swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToBeDeleted = items?[indexPath.row] {
            do {
                //Using Core Data
                //try context.save()
                try realm.write({
                    realm.delete(itemToBeDeleted)
                })
            } catch {
                print("Error in saving categories: \(error)")
            }
        }
        //tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
}

//MARK: - Search bar
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
        //Using Core Data
//        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
//        let predicateForSearch = NSPredicate(format: "text CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
//        loadItems(with: request, using: predicateForSearch)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
