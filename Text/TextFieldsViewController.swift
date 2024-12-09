import UIKit

class TextFieldsViewController: UIViewController, UITextFieldDelegate {
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Text Fields"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textFieldValidationDelegate: TextFieldValidationDelegate = {
        return TextFieldValidationDelegate(viewController: self)
    }()
    
    private lazy var noDigitsTextField: UITextField = createTextField(placeholder: "Type here")
    private lazy var inputLimitTextField: UITextField = {
        let textField = createTextField(placeholder: "Type here")
        textField.textAlignment = .left
        textField.clearButtonMode = .whileEditing
        textField.rightView = inputLimitCountLabel
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var inputLimitCountLabel: UILabel = {
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
    
    private lazy var _maskedTextField: UITextField = createTextField(placeholder: "wwwww-ddddd")
    private lazy var _linkTextField: UITextField = {
        let textField = createTextField(placeholder: "www.example.com")
        textField.keyboardType = .URL
        return textField
    }()
    private lazy var _passwordTextField: UITextField = {
        let textField = createTextField(placeholder: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    // Password verification
    private lazy var _passwordProgressView: UIProgressView = {
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
    
    private lazy var _passwordRuleStackView: UIStackView = {
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
    
    // Setup view method
    func setupView() {
        view.backgroundColor = .white
        
        // Add a scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        
        // Add centering to the header
        containerStackView.addArrangedSubview(titleLabel)
        
        // Create sections with proportional sizes
        addTextFieldSection(title: "NO digits field", textField: noDigitsTextField)
        addTextFieldSection(title: "Input limit", textField: inputLimitTextField)
        addTextFieldSection(title: "Only characters", textField: maskedTextField)
        addTextFieldSection(title: "Link", textField: linkTextField)
        
        // Password section with rules and progress bar
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
        
        // Limitations.
        NSLayoutConstraint.activate([
            // Scroll restriction (full screen mode with safe zone)
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Restricting the view of the container stack
            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            containerStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            passwordProgressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    // Add text field section method
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
    
    // Create text field method
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
    
    // Setup text field delegates method
    private func setupTextFieldDelegates() {
        noDigitsTextField.delegate = textFieldValidationDelegate
        inputLimitTextField.delegate = textFieldValidationDelegate
        maskedTextField.delegate = textFieldValidationDelegate
        linkTextField.delegate = textFieldValidationDelegate
        passwordTextField.delegate = textFieldValidationDelegate
    }
    
    var maskedTextField: UITextField { get { return _maskedTextField } }
    var linkTextField: UITextField { get { return _linkTextField } }
    var passwordTextField: UITextField { get { return _passwordTextField } }
    var passwordRuleStackView: UIStackView { get { return _passwordRuleStackView } }
    var passwordProgressView: UIProgressView { get { return _passwordProgressView } }
    
    // Gets the no digits text field (read-only access)
    func getNoDigitsTextField() -> UITextField {
        return noDigitsTextField
    }
    
    // Gets the input limit text field (read-only access)
    func getInputLimitTextField() -> UITextField {
        return inputLimitTextField
    }
    
}
