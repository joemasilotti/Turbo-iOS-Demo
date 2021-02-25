import SwiftUI
import UIKit

class NumbersViewController: UIHostingController<NumbersView> {
    init() {
        super.init(rootView: NumbersView())
    }

    @available(*, unavailable)
    @objc dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct NumbersView: View {
    private let numbers = 1 ... 10

    var body: some View {
        List(numbers, id: \.self) { number in
            Text(String(number))
        }
    }
}

struct NumbersView_Preview: PreviewProvider {
    static var previews: some View {
        NumbersView()
    }
}
