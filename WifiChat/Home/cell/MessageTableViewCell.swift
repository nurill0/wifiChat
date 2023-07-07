//
//  MessageTableViewCell.swift
//  WifiChat
//
//  Created by Nurillo Domlajonov on 08/06/23.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    //MARK: public variables
    public var cellId = "messageCell"
    
    //MARK: lazy variables
    lazy var containerV: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    lazy var deviceNameLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Device name"
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 15, weight: .thin)
        lbl.numberOfLines = 0
        lbl.textColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        lbl.clipsToBounds = true
        
        return lbl
    }()

    lazy var messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Bir nimalarda"
        lbl.textAlignment = .natural
        lbl.font = .systemFont(ofSize: 18)
        lbl.numberOfLines = 0
        lbl.layer.cornerRadius = 5
        lbl.clipsToBounds = true
        
        return lbl
    }()
    
    lazy var timeLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "00;00"
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 13, weight: .thin)
        lbl.numberOfLines = 0
        lbl.clipsToBounds = true
        
        return lbl
    }()
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        configureUI()
    }

}



//MARK: UI
extension MessageTableViewCell {
    
    
    fileprivate func configureUI(){
        self.contentView.backgroundColor = #colorLiteral(red: 0.8799401522, green: 0.9148583412, blue: 0.9700120091, alpha: 1)
        self.contentView.addSubview(containerV)
        NSLayoutConstraint.activate([
            containerV.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            containerV.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
            containerV.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15),
            containerV.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -15)
        ])
        
        containerV.addSubview(timeLbl)
        NSLayoutConstraint.activate([
            timeLbl.topAnchor.constraint(equalTo: self.containerV.topAnchor, constant: 8),
            timeLbl.rightAnchor.constraint(equalTo: self.containerV.rightAnchor, constant: -8)
        ])
        
        containerV.addSubview(deviceNameLbl)
        NSLayoutConstraint.activate([
            deviceNameLbl.topAnchor.constraint(equalTo: self.containerV.topAnchor, constant: 8),
            deviceNameLbl.leftAnchor.constraint(equalTo: self.containerV.leftAnchor, constant: 8),
            deviceNameLbl.rightAnchor.constraint(equalTo: self.timeLbl.leftAnchor, constant: -5)
        ])
        
        containerV.addSubview(messageLbl)
        NSLayoutConstraint.activate([
            messageLbl.topAnchor.constraint(equalTo: self.deviceNameLbl.bottomAnchor, constant: 8),
            messageLbl.bottomAnchor.constraint(equalTo: self.containerV.bottomAnchor, constant: -8),
            messageLbl.leftAnchor.constraint(equalTo: self.containerV.leftAnchor, constant: 8),
            messageLbl.rightAnchor.constraint(equalTo: self.containerV.rightAnchor, constant: -8)
        ])
    }
    
    
}
