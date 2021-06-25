//
//  ViewController.swift
//  ForFetch
//
//  Created by nabi jung on 6/24/21.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        callSeatGeekAPI()
        
        // Do any additional setup after loading the view.
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
                                 height: view.frame.height - searchBar.frame.height)
    }
    
    func callSeatGeekAPI(){
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "SeatGeekCell") as! SeatGeekTableViewCell
        cell.titleLabel.text = "Venu"
        cell.venuImage.image = UIImage.init(systemName: "scribble")
        return cell
    }


}

