import Turbo
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private lazy var navigationController = UINavigationController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        makeAndAssignWindow(in: windowScene)
        visit(url: URL(string: "https://turbo-native-demo.glitch.me")!)
    }

    private func makeAndAssignWindow(in windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    private func visit(url: URL) {
        let viewController = VisitableViewController(url: url)
        navigationController.pushViewController(viewController, animated: true)
        session.visit(viewController)
    }

    private lazy var session: Session = {
        let session = Session()
        session.delegate = self
        return session
    }()
}

extension SceneDelegate: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        visit(url: proposal.url)
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        print("didFailRequestForVisitable: \(error)")
    }
}
