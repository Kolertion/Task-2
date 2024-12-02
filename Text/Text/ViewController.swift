import UIKit

// Це розширення містить усі методи налаштування інтерфейсу користувача
extension TextFieldsViewController {
    func setupView() {
        view.backgroundColor = .white
        
        // Додати подання прокрутки
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        
        // Додати вирівнювання заголовка по центру
        containerStackView.addArrangedSubview(titleLabel)
        
        // Створюйте секції з пропорційними розмірами
        addTextFieldSection(title: "NO digits field", textField: noDigitsTextField)
        addTextFieldSection(title: "Input limit", textField: inputLimitTextField)
        addTextFieldSection(title: "Only characters", textField: maskedTextField)
        addTextFieldSection(title: "Link", textField: linkTextField)
        
        // Розділ паролів з правилами та індикатором прогресу
        let passwordTitleLabel = UILabel()
        passwordTitleLabel.text = "Validation rules"
        passwordTitleLabel.font = .boldSystemFont(ofSize: 16)
        passwordTitleLabel.textAlignment = .left
        containerStackView.addArrangedSubview(passwordTitleLabel)
        
        let passwordStackView = UIStackView()
        passwordStackView.axis = .vertical
        passwordStackView.spacing = 8
        passwordStackView.distribution = .fillProportionally
        passwordStackView.translatesAutoresizingMaskIntoConstraints = false
        
        passwordStackView.addArrangedSubview(passwordTextField)
        passwordStackView.addArrangedSubview(passwordProgressView)
        passwordStackView.addArrangedSubview(passwordRuleStackView)
        
        containerStackView.addArrangedSubview(passwordStackView)
        
        // Обмеження
        NSLayoutConstraint.activate([
            // Обмеження прокрутки (повноекранний режим з безпечною зоною)
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Обмеження подання стека контейнерів
            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            containerStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            passwordProgressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func addTextFieldSection(title: String, textField: UITextField) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
        
        containerStackView.addArrangedSubview(stackView)
    }
    
    func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.font = .systemFont(ofSize: 16)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.contentVerticalAlignment = .center
        return textField
    }
}
