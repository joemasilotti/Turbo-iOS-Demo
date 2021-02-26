import SafariServices
import SwiftUI
import Turbo
import UIKit
import WebKit

class AppCoordinator: NSObject {
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
        let viewController = makeViewController(for: url, from: properties)
        let modal = properties["presentation"] as? String == "modal"
        navigate(to: viewController, via: action, asModal: modal)
        visit(viewController, as: modal)
    }

    private func makeViewController(for url: URL, from properties: PathProperties) -> UIViewController {
        if properties["controller"] as? String == "numbers" {
            return NumbersViewController()
        }
        return VisitableViewController(url: url)
    }

    private func navigate(to viewController: UIViewController, via action: VisitAction, asModal modal: Bool) {
        if modal {
            navigationController.present(viewController, animated: true)
        } else if action == .advance {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            navigationController.viewControllers = Array(navigationController.viewControllers.dropLast()) + [viewController]
        }
    }

    private func visit(_ viewController: UIViewController, as modal: Bool) {
        guard let visitable = viewController as? Visitable else { return }

        let session = modal ? modalSession : self.session
        session.visit(visitable)
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

    func sessionDidLoadWebView(_ session: Session) {
        session.webView.navigationDelegate = self
    }
}

extension AppCoordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard
            navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }

        let safariViewController = SFSafariViewController(url: url)
        navigationController.present(safariViewController, animated: true)
        decisionHandler(.cancel)
    }
}
