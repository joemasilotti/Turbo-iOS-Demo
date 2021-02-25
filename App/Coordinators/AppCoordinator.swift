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

    private func visit(url: URL) {
        let viewController = VisitableViewController(url: url)
        navigationController.pushViewController(viewController, animated: true)
        session.visit(viewController)
    }
}

extension AppCoordinator: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        visit(url: proposal.url)
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        print("didFailRequestForVisitable: \(error)")
    }
}
