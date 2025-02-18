//
//  Router.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import SwiftUI
import UIKit

protocol RouterProtocol {
    func navigate(to route: Route)
}

enum Route {
    case moviesList
    case movieDetails(movieId: Int, (() -> Void)?)
}

final class AppRouter: RouterProtocol {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigate(to route: Route) {
        switch route {
        case .moviesList:
            let apiClient = APIClient(baseURL: URL(string: "https://api.themoviedb.org/3")!)
            let viewModel = MovieListViewModel(apiClient: apiClient)
            let vc = MovieListViewController(viewModel: viewModel, router: self)
            navigationController.pushViewController(vc, animated: true)
        case .movieDetails(let movieId, let onToggle):
            let apiClient = APIClient(baseURL: URL(string: "https://api.themoviedb.org/3")!)
            let viewModel = MovieDetailsViewModel(movieId: movieId, apiClient: apiClient)
            let uiHostingController = UIHostingController(rootView: MovieDetailsView(viewModel: viewModel))
            let vc = MovieDetailsViewController(uiHostingController: uiHostingController, router: self)
            vc.onToggle = onToggle
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func goBack() {
        navigationController.popViewController(animated: true)
    }
}
