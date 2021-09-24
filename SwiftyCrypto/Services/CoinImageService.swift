//
//  CoinImageService.swift
//  CoinImageServic
//
//  Created by Łukasz Stachnik on 09/09/2021.
//

import Foundation
import SwiftUI
import Combine

class CoinImageService  : ErrorPublishedProtocol {
    
    @Published var image : UIImage? = nil
    @Published var isLoading : Bool = false
    @Published private(set) var isError : Bool = false
    @Published private(set) var error : Error? = nil
    
    
    var errorPublisher: Published<Error?> { _error }
    var isErrorPublisher: Published<Bool> { _isError }
    
    private let fileManager = LocalFileManager.instance
    private var imageSubscription : AnyCancellable?
    private let coin : Coin
    let folderName = "coin_images"
    private let imageName: String
    
    //MARK: Depedencies
    let networkingManager : DataProvider
    
    
    init(networkingManager : DataProvider, coin: Coin) {
        self.networkingManager = networkingManager
        self.coin = coin
        self.imageName = coin.id
        getCoinImage()
    }
    
    private func getCoinImage() {
        if let savedImage = fileManager.getImage(imageName: imageName, folderName: folderName) {
            image = savedImage
        } else {
            self.isLoading = true
            downloadCoinImage()
        }
    }
    
    private func downloadCoinImage() {
        guard let url = URL(string: coin.image ) else { return }
        
        imageSubscription = networkingManager.fetch(url: url)
            .tryMap({ (data) -> UIImage? in
                return UIImage(data: data)
            })
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.showError(error: error)
                }
            }, receiveValue: { [weak self] (returnedImage) in
                
                guard let self = self, let downloadedImage = returnedImage else { return }
                
                self.isLoading = false
                self.image = returnedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(image: downloadedImage, imageName: self.imageName, folderName: self.folderName)
            })
    }
    
    func showError(error: Error) {
        self.isError = true
        self.error = error
    }
    
}
