//
//  BasicTypes.swift
//  FollowerDM
//
//  Created by Jeffrey Bergier on 18/07/2018.
//  Copyright © 2018 Jeffrey Bergier. All rights reserved.
//

import UIKit

/// For Asynchronous programming the Apple Approved `throws` syntax doesn't really work
/// Instead we'll use Result type so we know how to deal with success and failure of our network requests
enum Result<T, E> {
    case success(T), failure(E)
}

extension UIImage {
    /// Downloads an image from the internet asynchronously
    /// Always calls the completion handler on the main thread
    class func image(atRemoteURL url: URL, completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                // if there's an error, bail immediately
                if let error = error {
                    completion(.failure(.cocoaError(error)))
                    return
                }
                // make sure we got a success response from the server
                guard let response = response as? HTTPURLResponse, response.acceptableResponse else {
                    completion(.failure(.unacceptableServerResponse))
                    return
                }
                // convert the data
                guard let data = data, let image = UIImage(data: data) else {
                    completion(.failure(.dataNotConvertibleToImage))
                    return
                }
                // success!
                completion(.success(image))
            }
        }
        task.resume()
    }
}

enum ImageDownloadError: Error {
    case dataNotConvertibleToImage, unacceptableServerResponse, cocoaError(Error)
}

enum JSONDownloadError: Error {
    case cocoaError(Error), unacceptableServerResponse, dataNotConvertibleToJSONObject, desiredInformationMissingFromJSON
}

extension HTTPURLResponse {
    var acceptableResponse: Bool {
        return self.statusCode >= 200 && self.statusCode < 400
    }
}

class ForcedPopoverPresentedNavigationController: UINavigationController, UIPopoverPresentationControllerDelegate {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.commonInit()
    }

    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.commonInit()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }    

    private func commonInit() {
        self.modalPresentationStyle = .popover // required to force the VC to construct the popoverPresentationController
        self.popoverPresentationController?.delegate = self
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

}
