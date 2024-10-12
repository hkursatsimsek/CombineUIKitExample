//
//  PostTableViewCell.swift
//  CombineUIKitExample
//
//  Created by Kürşat Şimşek on 13.10.2024.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "postCell"

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.boldSystemFont(ofSize: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var bodyLabel: UILabel = {
        let view = UILabel()
        
        view.font = UIFont.systemFont(ofSize: 14)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with post: Post){
        titleLabel.text = post.title
        bodyLabel.text = post.body
    }
}
