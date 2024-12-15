import UIKit

class KeyboardManager {
    private weak var scrollView: UIScrollView?
    private weak var view: UIView?
    private var keyboardHeight: CGFloat = 0
    private var originalContentInset: UIEdgeInsets = .zero
    private var originalScrollIndicatorInsets: UIEdgeInsets = .zero
    
    init(scrollView: UIScrollView, view: UIView) {
        self.scrollView = scrollView
        self.view = view
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let scrollView = scrollView, let view = view,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeTextField = view.findFirstResponder() as? UITextField else {
            return
        }
        
        // We keep the original insets
        originalContentInset = scrollView.contentInset
        originalScrollIndicatorInsets = scrollView.scrollIndicatorInsets
        
        // Determine the height of the keyboard
        keyboardHeight = keyboardFrame.size.height
        
        // Determine the position of the active text box
        let textFieldBottom = activeTextField.convert(activeTextField.bounds, to: view).maxY
        let visibleHeight = view.frame.height - keyboardHeight
        
        if textFieldBottom > visibleHeight {
            let scrollAmount = textFieldBottom - visibleHeight + 20
            
            // We update insets and offset content
            UIView.animate(withDuration: 0.3) {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardHeight, right: 0)
                scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardHeight, right: 0)
                scrollView.contentOffset = CGPoint(x: 0, y: scrollAmount)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let scrollView = scrollView else { return }
        
        // Returning the original insets
        UIView.animate(withDuration: 0.3) {
            scrollView.contentInset = self.originalContentInset
            scrollView.scrollIndicatorInsets = self.originalScrollIndicatorInsets
            scrollView.contentOffset = .zero
        }
    }
}

// Extension to find the active responder
extension UIView {
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        
        for subview in subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
}
