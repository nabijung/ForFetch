//
//  SeatGeekTableViewCell.swift
//  ForFetch
//
//  Created by nabi jung on 6/25/21.
//

import UIKit

class SeatGeekTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var venuImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        venuImage.layer.cornerRadius = venuImage.frame.height/4
        
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        locationLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        dateLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        timeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        
        locationLabel.textColor = .lightGray
        dateLabel.textColor = .lightGray
        timeLabel.textColor = .lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
}
