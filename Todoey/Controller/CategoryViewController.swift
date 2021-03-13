//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Alexandra Negru on 21/02/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoriesArray: Results<RCategory>?
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoriesArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categoriesArray?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No categories added yet"
        cell.backgroundColor = UIColor.init(hexString: category?.color ?? UIColor.randomFlat().hexValue())
        
        
        return cell
    }
    
    //MARK: - Data manipulation
    
    func save(category: RCategory) {
        do {
            //Using Core Data
            //try context.save()
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error in saving categories: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categoriesArray = realm.objects(RCategory.self)
        
        //Using Core Data
        //let request: NSFetchRequest<Category> = Category.fetchRequest()
//        do {
//            categoriesArray = try context.fetch(request)
//        } catch {
//            print("Error in loading categories: \(error)")
//        }
        tableView.reloadData()
    }
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryToBeDeleted = self.categoriesArray?[indexPath.row] {
            do {
                //Using Core Data
                //try context.save()
                try self.realm.write({
                    self.realm.delete(categoryToBeDeleted)
                })
            } catch {
                print("Error in saving categories: \(error)")
            }
        }
        //tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
    
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoriesArray?[indexPath.row]
        }
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen once the user hits Add
            //Using Core Data
            //let newCategory = Category(context: self.context)
            
            let newCategory = RCategory()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}
