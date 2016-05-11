//
//  UITests.swift
//  UITests
//
//  Created by Bart Pede on 03/02/16.
//
//

import XCTest

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) -> Void {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        var deleteString: String = ""
        for _ in stringValue.characters {
            deleteString += "\u{8}"
        }
        self.typeText(deleteString)

        self.typeText(text)
    }
}

class UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func localized(key: String) -> String {
        let localizationBundle = NSBundle(path: NSBundle(forClass: UITests.self).pathForResource(deviceLanguage.componentsSeparatedByString("-")[0], ofType: "lproj")!)
        return NSLocalizedString(key, bundle: localizationBundle!, comment: "")
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        let app = XCUIApplication()
        let cfg:NSDictionary! = NSDictionary(contentsOfFile: NSBundle(forClass: UITests.self).pathForResource("RogerthatConfig", ofType: "plist")!)
        var nextElementShouldExist = false

        let isRogerthat:Bool = cfg["APP_TYPE"] as? Int == 0
        let isCityApp:Bool = cfg["APP_TYPE"] as? Int == 1
        let isEnterprise:Bool = cfg["APP_TYPE"] as? Int == 2

        let agreeBtn = app.buttons[localized(isEnterprise ? "Start registration" : "Agree and continue")]
        if (agreeBtn.exists) {
            nextElementShouldExist = true
            agreeBtn.tap()
        }

        let continueBtn1 = app.navigationBars[localized("Location usage")].buttons[localized("Continue")]
        if (nextElementShouldExist || continueBtn1.exists) {
            nextElementShouldExist = true
            continueBtn1.tap()
        }

        if (isCityApp) {
            let continueBtn2 = app.navigationBars[localized("Notifications")].buttons[localized("Continue")]
            if (nextElementShouldExist || continueBtn2.exists) {
                nextElementShouldExist = true
                continueBtn2.tap()
                continueBtn2.tap()
                continueBtn2.tap()
                if (NSProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!.hasPrefix("iPhone4")) {
                    continueBtn2.tap()
                }
            }
        }

        if (cfg["FACEBOOK_REGISTRATION"] as? Bool == true) {
            let emailBtn = app.buttons[localized("Use e-mail")]
            if (nextElementShouldExist || emailBtn.exists) {
                nextElementShouldExist = true
                emailBtn.tap()
            }
        }

        let enterEMailAddressTextField = app.textFields[localized(isEnterprise ? "Enter company e-mail address" : "Enter e-mail address")]
        if (nextElementShouldExist || enterEMailAddressTextField.exists) {
            nextElementShouldExist = true
            enterEMailAddressTextField.tap()
            enterEMailAddressTextField.typeText("apple.review@rogerth.at")
            app.buttons[localized("Send activation code")].tap()

            app.textFields["PIN"].typeText("0666")
        }

        sleep(5)

        let saveProfileBtn = app.navigationBars[localized("Profile")].buttons[localized("Done")]
        if (saveProfileBtn.exists) {
            let tablesQuery = app.tables
            let textField = tablesQuery.textFields.elementBoundByIndex(0)
            textField.buttons.elementBoundByIndex(0).tap()
            textField.typeText("Apple Review")
            let editNameStaticText = tablesQuery.staticTexts[localized("Edit name:")]
            tablesQuery.cells.containingType(.StaticText, identifier:localized("Day of birth")).staticTexts[localized("Unknown")].tap()
            editNameStaticText.tap()
            tablesQuery.cells.containingType(.StaticText, identifier:localized("Gender")).staticTexts[localized("Unknown")].tap()
            editNameStaticText.tap()
            saveProfileBtn.tap()
            sleep(1)
        }

        // Force hide the Push Notifications popup by tapping the homescreen header
        app.statusBars.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(0).tap()

        snapshot("01-Home")
    }
    
}
