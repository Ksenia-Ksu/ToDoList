
import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var items = [Item]()
    
    var selectedCategory : Category? {
        
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: Constants.TextForAlerts.addItem, message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Constants.TextForAlerts.addItemPlaceholder
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: Constants.TextForAlerts.addItemAction, style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.items.append(newItem)
            self.saveItems()
        }
        
        let cancelAction = UIAlertAction(title: Constants.TextForAlerts.cancel, style: .cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.itemCellIdentifier, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        content.text = item.title
        
        if item.done {
            content.textProperties.color = .lightGray
        } else {
            content.textProperties.color = .black
        }
        
        cell.contentConfiguration = content
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        items[indexPath.row].done = !items[indexPath.row].done
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Saving and loading of items
    
    func saveItems() {
        
        do {
            try context.save()
        } catch  {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - Swipe actions - delete and edit

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = items[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: Constants.TextForSwipes.delete) { _, _, _ in
            
            self.context.delete(item)
            self.items.remove(at: indexPath.row)
            self.saveItems()
        }
        
        let editAction = UIContextualAction(style: .normal, title: Constants.TextForSwipes.edit) { _, _, _ in
            
            let alert = UIAlertController(title: Constants.TextForSwipes.editItem, message: "", preferredStyle: .alert)
            
            var textField = UITextField()
            
            alert.addTextField { (alertTextField)  in
                textField = alertTextField
                textField.text = item.title
                
            }
            
            let updateAction = UIAlertAction(title: Constants.TextForAlerts.save, style: .default) { action in
           
                self.items[indexPath.row].title = textField.text
                self.saveItems()
                
            }
            
            let cancelAction = UIAlertAction(title: Constants.TextForAlerts.cancel, style: .cancel)
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return swipeActions
    }
}





//MARK: - SearchBar Delegate Methods
extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
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




