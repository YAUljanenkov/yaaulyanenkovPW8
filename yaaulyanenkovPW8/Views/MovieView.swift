//
//  MovieView.swift
//  yaaulyanenkovPW8
//
//  Created by Ярослав Ульяненков on 06.03.2022.
//

import UIKit

class MovieView: UITableViewCell {
    static let identifier = "MovieCell"
    private let poster = UIImageView()
    private let title = UILabel()
    
    init() {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        configureUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    private func configureUI() {
        poster.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(poster)
        addSubview(title)
        
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: topAnchor),
            poster.leadingAnchor.constraint(equalTo: leadingAnchor),
            poster.trailingAnchor.constraint(equalTo: trailingAnchor),
            poster.heightAnchor.constraint(equalToConstant: 200),
            
            title.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: 10),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            title.heightAnchor.constraint(equalToConstant: 20),
        ])
        self.setHeight(to: 230)
        title.textAlignment = .center
    }
    
    public func configure(movie: Movie) {
        title.text = movie.title
        poster.image = movie.poster
    }
}
