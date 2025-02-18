//
//  MovieDetailsViewController.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 16/02/2025.
//

import UIKit
import SwiftUI

class MovieDetailsViewController: UIViewController {
    let uiHostingController: UIHostingController<MovieDetailsView>
    private let router: AppRouter
    
    var onToggle: (() -> Void)?
    
    init(uiHostingController: UIHostingController<MovieDetailsView>, router: AppRouter) {
        self.uiHostingController = uiHostingController
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(uiHostingController)
        view.addSubview(uiHostingController.view)
        uiHostingController.view.frame = view.bounds
        uiHostingController.didMove(toParent: self)
        
        uiHostingController.rootView.onToggle = {
            self.onToggle?()
        }
        
        navigationItem.hidesBackButton = true
        
        let backButton = UIBarButtonItem(
            title: "←",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 30, weight: .regular)], for: .normal)
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        router.goBack()
    }
}
