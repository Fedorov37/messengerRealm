//
//  GroupContactsTableViewCell.swift
//  messenger
//
//  Created by Администратор on 30.05.2022.
//

import UIKit

class GroupContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
