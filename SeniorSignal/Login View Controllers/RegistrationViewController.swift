//
//  RegistrationViewController.swift
//  SeniorSignal
//
//  Created by Frederick DeBiase on 11/4/23.
//

import UIKit
import ParseSwift

class RegistrationViewController: UIViewController {
    
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPass: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Add two properties for the password visibility buttons
    private var passwordVisibilityButton: UIButton!
    private var confirmPassVisibilityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup password visibility toggle for both password fields
        setupPasswordVisibilityToggle()
        setupTextFields()
        addDoneButtonToKeyboard()
        
        name.borderStyle = .roundedRect
        email.borderStyle = .roundedRect
        username.borderStyle = .roundedRect
        password.borderStyle = .roundedRect
        confirmPass.borderStyle = .roundedRect

        // Or if you want a custom border
        name.layer.borderColor = UIColor.darkGray.cgColor // Choose a suitable color
        name.layer.borderWidth = 1.0
        name.layer.cornerRadius = 5.0 // Adjust the corner radius as needed

        email.layer.borderColor = UIColor.darkGray.cgColor // Choose a suitable color
        email.layer.borderWidth = 1.0
        email.layer.cornerRadius = 5.0 // Adjust the corner radius as needed
        
        username.layer.borderColor = UIColor.darkGray.cgColor // Choose a suitable color
        username.layer.borderWidth = 1.0
        username.layer.cornerRadius = 5.0 // Adjust the corner radius as needed
        
        password.layer.borderColor = UIColor.darkGray.cgColor // Choose a suitable color
        password.layer.borderWidth = 1.0
        password.layer.cornerRadius = 5.0 // Adjust the corner radius as needed
        
        confirmPass.layer.borderColor = UIColor.darkGray.cgColor // Choose a suitable color
        confirmPass.layer.borderWidth = 1.0
        confirmPass.layer.cornerRadius = 5.0 // Adjust the corner radius as needed
    }
    
    private func setupTextFields() {
        // Set dark text for placeholders
        email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        name.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        username.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        confirmPass.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    func addDoneButtonToKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        // Add the toolbar as an input accessory view to all text fields
        name.inputAccessoryView = doneToolbar
        email.inputAccessoryView = doneToolbar
        username.inputAccessoryView = doneToolbar
        password.inputAccessoryView = doneToolbar
        confirmPass.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        // Dismiss the keyboard when the "Done" button is tapped
        view.endEditing(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        
      //Dynamically display the title of the navigation title
      self.navigationItem.title = "Register"
        
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        if User.current != nil {
            // Log out the current user
            User.logout { result in
                switch result {
                case .success:
                    print("Successfully logged out the current user.")
                    // After logging out, attempt registration
                    self.attemptRegistration()
                case .failure(let error):
                    print("Error logging out: \(error)")
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Logout Failed", message: "Could not log out the current user. Please try again.")
                    }
                }
            }
        } else {
            // If no user is logged in, attempt registration directly
            self.attemptRegistration()
        }
    }
    
    func attemptRegistration() {
        // Input validation
        guard
            let nameText = name.text, !nameText.isEmpty,
            let emailText = email.text, !emailText.isEmpty,
            let usernameText = username.text, !usernameText.isEmpty,
            let passwordText = password.text, !passwordText.isEmpty,
            let confirmPassText = confirmPass.text, !confirmPassText.isEmpty,
            passwordText == confirmPassText
        else {
            presentAlert(title: "Registration Failed", message: "Please make sure all fields are filled and passwords match.")
            return
        }
        
        // Call the function to handle user registration
        registerUser(name: nameText, email: emailText, username: usernameText, password: passwordText)
    }
    
    func registerUser(name: String, email: String, username: String, password: String) {
        var newUser = User()
        newUser.username = username
        newUser.password = password
        newUser.email = email
        // Assuming "name" is a custom field you've added to your Parse User class.
        newUser.name = name
        
        newUser.signup { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("User account for \(username) created successfully.")  // This line logs the success.
                    // Successfully registered the new user, now login
                    self.loginUser(username: username, password: password)
                case .failure(let error):
                    self.presentAlert(title: "Registration Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func loginUser(username: String, password: String) {
        User.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    // Login successful, navigate to HomeViewController
                    self.navigateToHomeViewController()
                case .failure(let error):
                    self.presentAlert(title: "Login Error", message: "Failed to log in user after registration: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func navigateToHomeViewController() {
        // Make sure the identifier "HomeViewController" matches with your Storyboard ID for the HomeViewController.
        guard let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            presentAlert(title: "Error", message: "HomeViewController could not be instantiated.")
            return
        }
        
        // This will reset the navigation stack and make the HomeViewController the root view controller
        if let navigationController = self.navigationController {
            navigationController.setViewControllers([homeVC], animated: false)
        } else {
            presentAlert(title: "Navigation Error", message: "Navigation controller not found.")
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func createToggleButton(normalImage: UIImage?, selectedImage: UIImage?) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = normalImage?.withRenderingMode(.alwaysOriginal)
        config.imagePlacement = .leading
        config.baseForegroundColor = UIColor.clear
        let paddingValue: CGFloat = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: paddingValue, leading: paddingValue, bottom: paddingValue, trailing: paddingValue)
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.setImage(normalImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        
        button.configurationUpdateHandler = { button in
            if button.isHighlighted || button.isSelected {
                button.configuration?.image = selectedImage?.withRenderingMode(.alwaysOriginal)
            } else {
                button.configuration?.image = normalImage?.withRenderingMode(.alwaysOriginal)
            }
            button.configuration?.baseForegroundColor = .clear
        }
        return button
    }

    private func setupPasswordVisibilityToggle() {
        passwordVisibilityButton = createToggleButton(normalImage: UIImage(named: "eyeSlashImage"), selectedImage: UIImage(named: "eyeImage"))
        passwordVisibilityButton.isSelected = false // Initially the button should not show the password
        passwordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility(sender:)), for: .touchUpInside)
        password.isSecureTextEntry = true // Initially the password is hidden
        password.rightView = passwordVisibilityButton
        password.rightViewMode = .whileEditing

        confirmPassVisibilityButton = createToggleButton(normalImage: UIImage(named: "eyeSlashImage"), selectedImage: UIImage(named: "eyeImage"))
        confirmPassVisibilityButton.isSelected = false // Initially the button should not show the password
        confirmPassVisibilityButton.addTarget(self, action: #selector(toggleConfirmPassVisibility(sender:)), for: .touchUpInside)
        confirmPass.isSecureTextEntry = true // Initially the confirm password is hidden
        confirmPass.rightView = confirmPassVisibilityButton
        confirmPass.rightViewMode = .whileEditing
    }

    @objc func togglePasswordVisibility(sender: UIButton) {
        sender.isSelected.toggle()
        password.isSecureTextEntry = !sender.isSelected
    }

    @objc func toggleConfirmPassVisibility(sender: UIButton) {
        sender.isSelected.toggle()
        confirmPass.isSecureTextEntry = !sender.isSelected
    }
}
