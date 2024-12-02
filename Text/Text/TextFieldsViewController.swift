import UIKit

class TextFieldsViewController: UIViewController, UITextFieldDelegate {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Text Fields"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var noDigitsTextField: UITextField = createTextField(placeholder: "Type here")
    lazy var inputLimitTextField: UITextField = {
        let textField = createTextField(placeholder: "Type here")
        textField.textAlignment = .left
        textField.clearButtonMode = .whileEditing
        textField.rightView = inputLimitCountLabel
        textField.rightViewMode = .always
        return textField
    }()
    
    // Мітка для відображення кількості символів
    lazy var inputLimitCountLabel: UILabel = {
        let label = UILabel()
        label.text = "10"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 40).isActive = true
        label.backgroundColor = .clear
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    lazy var maskedTextField: UITextField = createTextField(placeholder: "wwwww-ddddd")
    lazy var linkTextField: UITextField = {
        let textField = createTextField(placeholder: "www.example.com")
        textField.keyboardType = .URL
        return textField
    }()
    lazy var passwordTextField: UITextField = {
        let textField = createTextField(placeholder: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    // Індикатор прогресу перевірки пароля
    lazy var passwordProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .lightGray.withAlphaComponent(0.3)
        progressView.progressTintColor = .clear
        progressView.progress = 0
        progressView.isHidden = true
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        return progressView
    }()
    
    // Мітки правил валідації
    lazy var passwordRuleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let rules = [
            "- minimum of 8 characters.",
            "- minimum 1 digit.",
            "- minimum 1 lowercased.",
            "- minimum 1 uppercased."
        ]
        
        rules.forEach { rule in
            let label = UILabel()
            label.text = rule
            label.font = .systemFont(ofSize: 12)
            label.textColor = .gray
            label.numberOfLines = 1
            stackView.addArrangedSubview(label)
        }
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTextFieldDelegates()
    }
    
    private func setupTextFieldDelegates() {
        noDigitsTextField.delegate = self
        inputLimitTextField.delegate = self
        maskedTextField.delegate = self
        linkTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Поле без цифр
        if textField == noDigitsTextField {
            return !string.contains(where: { $0.isNumber })
        }
        
        // Поле обмеження введення
        if textField == inputLimitTextField {
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            
            // Оновлення мітки з підтримкою від'ємних значень
            let remainingCharacters = 10 - newLength
            inputLimitCountLabel.text = "\(remainingCharacters)"
            
            // Зміна кольору мітки залежно від кількості символів
            if remainingCharacters < 0 {
                inputLimitCountLabel.textColor = .red
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1
            } else if remainingCharacters <= 2 {
                inputLimitCountLabel.textColor = .orange
                textField.layer.borderColor = nil
                textField.layer.borderWidth = 0
            } else {
                inputLimitCountLabel.textColor = .black
                textField.layer.borderColor = nil
                textField.layer.borderWidth = 0
            }
            
            // Дозволяє продовжувати введення без обмежень
            return true
        }
        
        // Замасковане поле
        if textField == maskedTextField {
            return formatMaskedField(textField, range, string)
        }
        
        // Поле посилання
        if textField == linkTextField {
            // Затримати перевірку, щоб дозволити оновлення тексту
            DispatchQueue.main.async {
                self.validateAndPrepareLink(textField)
            }
        }
        
        // Поле пароля
        if textField == passwordTextField {
            updatePasswordRules(textField.text ?? "")
            updatePasswordProgressBar(textField.text ?? "")
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Автоматично додавати https:// коли вибрано поле з текстом посилання
        if textField == linkTextField {
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
        
        // Переконайтеся, що префікс https://
        if !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        // Перевірка та спроба відкрити URL-адресу
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            print("Valid URL: \(url)")
            
            // Додатково: Додати жест дотику, щоб відкрити URL-адресу
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openURL))
            textField.addGestureRecognizer(tapGesture)
            textField.isUserInteractionEnabled = true
        } else {
            print("Invalid URL")
        }
    }
    
    @objc private func openURL() {
        guard let urlString = linkTextField.text,
              let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    private func updatePasswordRules(_ password: String) {
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
        // Приховати перегляд прогресу, якщо пароль порожній або дуже короткий
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

        // Встановити кольори градієнта на основі кількості правил, що збігаються
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
