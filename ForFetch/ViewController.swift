//
//  ViewController.swift
//  ForFetch
//
//  Created by nabi jung on 6/24/21.
//

import UIKit
import SDWebImage
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchTextFieldDelegate {
    
    var tableview: UITableView = {
        let table = UITableView()
        table.backgroundColor = .gray
        table.register(UINib(nibName: "SeatGeekTableViewCell", bundle: nil), forCellReuseIdentifier: "SeatGeekCell")
        return table
    }()
    
    var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.showsCancelButton = true
        bar.placeholder = "Search events"
        return bar
    }()
    
    var events: [Event]?
    
    var favorites: [NSManagedObject] = []
    var favoriteIDs: [Int] = [] 

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        callSeatGeekAPI(query: "A")
    }
    
    func setUpUI(){
        view.addSubview(searchBar)
        view.addSubview(tableview)
        
        searchBar.delegate = self
        
        tableview.delegate = self
        tableview.dataSource = self
        
        searchBar.frame = CGRect(x: view.safeAreaInsets.left,
                                 y: view.safeAreaInsets.top+20,
                                 width: view.frame.width,
                                 height: 50)
        tableview.frame = CGRect(x: view.safeAreaInsets.left,
                                 y: searchBar.frame.maxY,
                                 width: view.frame.maxX,
                                 height: view.frame.height - searchBar.frame.height-20)
    }
    
    func callSeatGeekAPI(query: String){
        Service.sharedInstance.callAPI(query: query, completion: { hasError, events in
            if !hasError {
                self.events = events
                self.getFavorites()
            } else {
                self.presentAlertController(message: "Could not call SeatGeek, please check your network connection and try again.", view: self)
            }
        })
        
    }
    
    func getFavorites(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
              return
          }
          
          let context =
            appDelegate.persistentContainer.viewContext
        
          let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Favorites")
   
          do {
            favorites = try context.fetch(fetchRequest)
            
            guard events != nil else {
                return
            }
            
            if favorites.isEmpty {
                for event in events! {
                    event.isFavorite = false
                    tableview.reloadData()
                }
            } else {
                var idArray: [Int] = []
                for entity in favorites {
                    guard let id = Int(entity.value(forKeyPath: "event_id") as! String) else{
                        return
                    }
                    idArray.append(id)
                    favoriteIDs = idArray
                    tableview.reloadData()
                }
            }
          } catch let error as NSError {
            presentAlertController(message: error.localizedDescription, view: self)
          }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //put code here
        if searchText == "" {
            callSeatGeekAPI(query: "A")
        } else {
            callSeatGeekAPI(query: searchText)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard events != nil else {
            return 0
        }
        return events!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "SeatGeekCell") as! SeatGeekTableViewCell
        guard events != nil,
              events?.count != 0,
              let event = events?[indexPath.row],
              let eventid = event.id else {
            
            return cell
        }
        cell.titleLabel.text = event.title
        cell.locationLabel.text = "\(event.city), \(event.state)"
        cell.venuImage.sd_setImage(with: URL(string: events![indexPath.row].imageURL), placeholderImage: UIImage(named: "placeholder.png"))
        
        
        if let date = event.datetime?.getDate(), let time = event.datetime?.getTime() {
            cell.dateLabel.text = date
            cell.timeLabel.text = time
        }
        
        if favoriteIDs.contains(eventid) {
            cell.heartIcon.isHidden = false
            event.isFavorite = true
        } else {
            event.isFavorite = false
            cell.heartIcon.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailView", sender: events?[indexPath.row])
        tableview.deselectRow(at: indexPath, animated: true)
        self.searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailView" {
            let vc = segue.destination as? DetailViewController
            vc?.event = sender as? Event
            vc?.favorites = favorites
            vc?.delegate = self
        }
    }
}

extension String {
    
    func getDate() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        if let localDate = formatter.date(from: self) {
            let convertDateFormatter = DateFormatter()
            convertDateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            
            return convertDateFormatter.string(from: localDate)
        } else {
            return "Date n/A"
        }
    }
    
    func getTime() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        if let localTime = formatter.date(from: self) {
            let convertDateFormatter = DateFormatter()
            convertDateFormatter.dateFormat = "HH:mm a"
            
            return convertDateFormatter.string(from: localTime)
        } else {
            return "Time n/A"        }
    }
}

extension ViewController: refreshDelegate {
    func refresh() {
        if searchBar.text != nil {
            callSeatGeekAPI(query: searchBar.text!)
        } else {
            callSeatGeekAPI(query: "")
        }
    }
}

extension UIViewController {
    func presentAlertController(message: String, view: UIViewController){
        let alertcontroller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertcontroller.addAction(action)
        view.present(alertcontroller, animated: true, completion: nil)
    }
    
}



