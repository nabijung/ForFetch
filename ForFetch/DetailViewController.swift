//
//  DetailViewController.swift
//  ForFetch
//
//  Created by nabi jung on 6/28/21.
//

import Foundation
import UIKit
import CoreData
import SDWebImage

class DetailViewController: UIViewController {
    
    public var event: Event?
    public var isFavorite = Bool() { didSet {
        if isFavorite == true {
            heartButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            heartButton.tintColor = .systemPink
        } else {
            heartButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
            heartButton.tintColor = .gray
        }
    }}
    
    var favorites: [NSManagedObject] = []
    
    weak var delegate: refreshDelegate?
    
    let heartButton: UIButton = {
       let button = UIButton()
        button.addTarget(self, action: #selector(heartButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        label.numberOfLines = 3
        return label
    }()
    
    let previewImage: UIImageView = {
       let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeAndDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        return label
    }()
    
    let locationLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        label.textColor = .lightGray
        return label
    }()
    
    override func viewDidLoad() {
        setUpUI()
    }
    
    @objc func heartButtonPressed(_ button: UIButton){
        if isFavorite {
            guard let event = event else {
                return
            }
            unHeart(event: event)
        } else {
            guard let id = event?.id else {
                return
            }
            let string_id = String(id)
            heart(eventid: string_id)
        }
        
    }
    
    func unHeart(event: Event) {
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
          
        let context = appDelegate.persistentContainer.viewContext
    
        for entity in favorites {
            if Int(entity.value(forKeyPath: "event_id") as! String) == event.id {
                context.delete(entity)
            }
        }
        saveContext(context: context)
        isFavorite = !isFavorite
        
        
    }
    
    func heart(eventid: String) {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity =
                NSEntityDescription.entity(forEntityName: "Favorites",
                                           in: context) else {
            return
        }
        
        let savedEventObject = NSManagedObject(entity: entity,
                                               insertInto: context)
        
        savedEventObject.setValue(eventid, forKeyPath: "event_id")
        saveContext(context: context)
        
        isFavorite = !isFavorite
    }
    
    func saveContext(context: NSManagedObjectContext){
        do {
            try context.save()
            delegate?.refresh()
        } catch let error as NSError {
            presentAlertController(message: error.localizedDescription, view: self)
        }
    }
    
    func setUpUI() {
            
        view.addSubview(heartButton)
        view.addSubview(titleLabel)
        view.addSubview(previewImage)
        view.addSubview(timeAndDateLabel)
        view.addSubview(locationLabel)
        
        heartButton.frame = CGRect(x: view.frame.width - 70,
                                   y: 20,
                                   width: 40,
                                   height: 30)
        
        titleLabel.frame = CGRect(x: 20,
                                  y: heartButton.frame.maxY + 20,
                                  width: view.frame.width - 40 ,
                                  height: 100)
        titleLabel.text = event?.title
        
        let rect = CGRect(x: 20,
                          y: titleLabel.frame.maxY + 20,
                          width: view.frame.width - 40,
                          height: 1)
        let barView = UIView(frame: rect)
        barView.backgroundColor = .lightGray
        view.addSubview(barView)
        
        
        previewImage.frame = CGRect(x: 20,
                                    y: barView.frame.maxY + 20,
                                    width: view.frame.width - 40,
                                    height: 200)
        previewImage.sd_setImage(with: URL(string: event?.imageURL ?? ""))
        
        timeAndDateLabel.frame = CGRect(x: 20,
                                        y: previewImage.frame.maxY + 20,
                                        width: view.frame.width - 40,
                                        height: 20)
        if let date = event?.datetime?.getDate(),
           let time = event?.datetime?.getTime() {
            timeAndDateLabel.text = "\(date) \(time)"
        }
        
        locationLabel.frame = CGRect(x: 20,
                                     y: timeAndDateLabel.frame.maxY + 5,
                                     width: view.frame.width - 40,
                                     height: 15)
        if let city = event?.city,
           let state = event?.state {
            locationLabel.text = "\(city), \(state)"
        }
        
        guard event?.isFavorite != nil else {
            heartButton.isHidden = true
            return
        }
        isFavorite = event!.isFavorite
    }
}

protocol refreshDelegate: AnyObject {
    func refresh()
}

