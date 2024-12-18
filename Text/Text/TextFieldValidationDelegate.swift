import UIKit

class TextFieldValidationDelegate: NSObject, UITextFieldDelegate {
    // Weak reference to the view controller to avoid retain cycles
    weak var viewController: TextFieldsViewController?
    
    // Initialization with a reference to the view controller
    init(viewController: TextFieldsViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Field without numbers
        if textField == viewController?.getNoDigitsTextField() {
            return !string.contains(where: { $0.isNumber })
        }
        
        // Input restriction field
        if textField == viewController?.getInputLimitTextField() {
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            // Update label with the correct text setting
            let remainingCharacters = 10 - newLength
            if let inputLimitCountLabel = viewController?.getInputLimitTextField().rightView as? UILabel {
                inputLimitCountLabel.text = String(remainingCharacters)
                
                if remainingCharacters < 0 {
                    inputLimitCountLabel.textColor = .red
                    textField.layer.borderColor = UIColor.red.cgColor
                    textField.layer.borderWidth = 1
                } else {
                    inputLimitCountLabel.textColor = .black
                    textField.layer.borderColor = nil
                    textField.layer.borderWidth = 0
                }
            }
            
            // Return true to allow text input
            return true
        }
        
        // Masked field
        if let maskedTextField = viewController?.maskedTextField, textField == maskedTextField {
            return formatMaskedField(textField, range, string)
        }
        
        // Link field
        if textField == viewController?.linkTextField {
            // Delay validation to allow text to be updated
            DispatchQueue.main.async { [weak self] in
                self?.validateAndPrepareLink(textField)
            }
        }
        
        // Password field
        if textField == viewController?.passwordTextField {
            // Calculate the updated password
            guard let currentText = textField.text,
                  let textRange = Range(range, in: currentText) else {
                return true
            }
            
            let updatedPassword = currentText.replacingCharacters(in: textRange, with: string)
            
            DispatchQueue.main.async { [weak self] in
                self?.updatePasswordRules(updatedPassword)
                self?.updatePasswordProgressBar(updatedPassword)
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Automatically add https:// when link text field is selected
        if textField == viewController?.linkTextField {
            if textField.text?.isEmpty == true || textField.text?.hasPrefix("https://") == false {
                textField.text = "https://"
            }
        }
    }
    
    private func formatMaskedField(_ textField: UITextField, _ range: NSRange, _ string: String) -> Bool {
        guard let text = textField.text,
              let textRange = Range(range, in: text) else {
            return true
        }
        
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        let filteredChars = updatedText.filter { $0.isLetter || $0.isNumber }
        
        var formatted = ""
        for (index, char) in filteredChars.enumerated() {
            if index == 5 {
                formatted += "-"
            }
            if index < 10 {
                if index < 5 && char.isLetter {
                    formatted += String(char)
                } else if index >= 5 && char.isNumber {
                    formatted += String(char)
                }
            }
        }
        
        textField.text = formatted
        return false
    }
    
    private func validateAndPrepareLink(_ textField: UITextField) {
        guard var urlString = textField.text else { return }
        
        // Make sure that the prefix https:// is present
        if !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        // Check if the URL is valid
        guard let url = URL(string: urlString) else {
            print("Invalid URL format")
            return
        }
        
        // Perform URL validation using URLSession
        let semaphore = DispatchSemaphore(value: 0)
        var isValidURL = false
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5 // Set a timeout to prevent long waits
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer { semaphore.signal() }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                isValidURL = false
                return
            }
            
            isValidURL = true
        }
        task.resume()
        
        // Wait for the validation to complete (with a timeout)
        _ = semaphore.wait(timeout: .now() + 5)
        
        // If the URL is valid and exists, open it
        if isValidURL {
            print("Valid URL: \(url)")
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        } else {
            print("URL does not exist or is inaccessible")
        }
    }
    
    private func updatePasswordRules(_ password: String) {
        guard let passwordRuleStackView = viewController?.passwordRuleStackView else { return }
        
        let ruleChecks = [
            password.count >= 8,
            password.contains { $0.isNumber },
            password.contains { $0.isLowercase },
            password.contains { $0.isUppercase }
        ]
        
        for (index, label) in passwordRuleStackView.arrangedSubviews.enumerated() {
            guard let ruleLabel = label as? UILabel else { continue }
            ruleLabel.textColor = ruleChecks[index] ? .green : .gray
        }
    }
    
    private func updatePasswordProgressBar(_ password: String) {
        guard let passwordProgressView = viewController?.passwordProgressView else { return }
        
        // Hide progress view if password is empty or very short
        guard password.count > 1 else {
            passwordProgressView.isHidden = true
            passwordProgressView.progress = 0
            return
        }
        
        let ruleChecks = [
            password.count >= 8,
            password.contains { $0.isNumber },
            password.contains { $0.isLowercase },
            password.contains { $0.isUppercase }
        ]
        
        let numRulesMatched = ruleChecks.filter { $0 }.count
        let progressPercentage = (Float(numRulesMatched) / 4.0)
        
        passwordProgressView.isHidden = false

        // Set gradient colors based on the number of matching rules
        switch numRulesMatched {
        case 1:
            passwordProgressView.progressTintColor = .red
        case 2:
            passwordProgressView.progressTintColor = .orange
        case 3:
            passwordProgressView.progressTintColor = .yellow
        case 4:
            passwordProgressView.progressTintColor = .green
        default:
            passwordProgressView.progressTintColor = .clear
        }
        
        passwordProgressView.progress = progressPercentage
    }
}
