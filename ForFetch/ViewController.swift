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

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callSeatGeekAPI(query: "")
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
                //handle error
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
                for event in events!{
                    for entity in favorites {
                        if Int(entity.value(forKey: "event_id") as! String) == event.id,
                           entity.value(forKey: "event_dateTime") as? String == event.datetime {
                            event.isFavorite = true
                            print("\(event.title!) is a fav")
                            tableview.reloadData()
                        } else {
                            event.isFavorite = false
                            print("\(event.title!) is a NOT fav")
                            tableview.reloadData()
                        }
                    }
                }
            }
          } catch let error as NSError {
            print(error.localizedDescription)
          }
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //put code here
        callSeatGeekAPI(query: searchText)
    }
    
    //add that search bar x button pressed
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard events != nil else {
            return 0
        }
        return events!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "SeatGeekCell") as! SeatGeekTableViewCell
        guard events != nil, let event = events?[indexPath.row] else {
            
            return cell
        }
        cell.titleLabel.text = event.title
        cell.locationLabel.text = "\(event.city), \(event.state)"
        cell.venuImage.sd_setImage(with: URL(string: events![indexPath.row].imageURL), placeholderImage: UIImage(named: "placeholder.png"))
        
        
        if let date = event.datetime?.getDate(), let time = event.datetime?.getTime() {
            cell.dateLabel.text = date
            cell.timeLabel.text = time
        }
        
        if event.isFavorite {
            cell.heartIcon.isHidden = false
        } else {
            cell.heartIcon.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailView", sender: events?[indexPath.row])
        tableview.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailView" {
            let vc = segue.destination as? DetailViewController
            vc?.event = sender as? Event
            vc?.favorites = favorites
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



