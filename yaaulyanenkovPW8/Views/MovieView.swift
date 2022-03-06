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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    private func configureUI() {
        poster.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(poster)
        addSubview(title)
        
        
        poster.pin(to: self, [.top, .left, .right])
        poster.setHeight(to: 200)
        title.pinTop(to: poster, 10)
        title.pin(to: self, [.left, .right])
        title.setHeight(to: 20)
        title.textAlignment = .center
    }
    
    public func configure(movie: Movie) {
        title.text = movie.title
        poster.image = movie.poster
    }
}
