import SwiftUI
import Turbo
import UIKit

class AppCoordinator {
    var rootViewController: UIViewController { navigationController }

    func start() {
        visit(url: URL(string: "https://turbo-native-demo.glitch.me")!)
    }

    // MARK: Private

    private let navigationController = UINavigationController()

    private lazy var session: Session = {
        let session = Session()
        session.delegate = self
        return session
    }()

    private func visit(url: URL, action: VisitAction = .advance) {
        let viewController = VisitableViewController(url: url)
        if action == .advance {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            navigationController.viewControllers = Array(navigationController.viewControllers.dropLast()) + [viewController]
        }
        session.visit(viewController)
    }
}

extension AppCoordinator: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        visit(url: proposal.url, action: proposal.options.action)
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        guard let topViewController = navigationController.topViewController else { return }

        let swiftUIView = ErrorView(errorMessage: error.localizedDescription)
        let hostingController = UIHostingController(rootView: swiftUIView)

        topViewController.addChild(hostingController)
        hostingController.view.frame = topViewController.view.frame
        topViewController.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: topViewController)
    }
}
