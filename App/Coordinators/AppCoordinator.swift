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
    private lazy var session = makeSession()
    private lazy var modalSession = makeSession()

    private func makeSession() -> Session {
        let session = Session()
        session.delegate = self
        session.pathConfiguration = PathConfiguration(sources: [
            .file(Bundle.main.url(forResource: "PathConfiguration", withExtension: "json")!),
        ])
        return session
    }

    private func visit(url: URL, action: VisitAction = .advance, properties: PathProperties = [:]) {
        let viewController: UIViewController

        if properties["controller"] as? String == "numbers" {
            viewController = NumbersViewController()
        } else {
            viewController = VisitableViewController(url: url)
        }

        if properties["presentation"] as? String == "modal" {
            navigationController.present(viewController, animated: true)
        } else if action == .advance {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            navigationController.viewControllers = Array(navigationController.viewControllers.dropLast()) + [viewController]
        }

        if let visitable = viewController as? Visitable {
            if properties["presentation"] as? String == "modal" {
                modalSession.visit(visitable)
            } else {
                session.visit(visitable)
            }
        }
    }
}

extension AppCoordinator: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        visit(url: proposal.url, action: proposal.options.action, properties: proposal.properties)
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
