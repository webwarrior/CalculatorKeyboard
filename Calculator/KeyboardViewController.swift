//
//  KeyboardViewController.swift
//  Calculator
//
//  Created by Shaun O'Reilly on 11/11/2015.
//  Copyright © 2015 Visual Recruit Pty Ltd. All rights reserved.
//

import UIKit

enum Operation {
    case Addition
    case Multiplication
    case Subtraction
    case Division
    case None
}

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet var display: UILabel!
    var calculatorView: UIView!
    var shouldClearDisplayBeforeInserting = true
    
    var internalMemory = 0.0
    var nextOperation = Operation.None
    var shouldCompute = false
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        clearDisplay()
        
        //let button = createButtonWithTitle("😀")
        //self.view.addSubview(button)
        
        /*
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .System)
    
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
    
        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.nextKeyboardButton)
    
        let nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])

        */
        
    }
    
    /*
    func createButtonWithTitle(title: String)->UIButton {
        
        let button = UIButton(type: .System)
        button.frame=CGRectMake(0,0,100,100)
        button.setTitle(title, forState: .Normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFontOfSize(100)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: "didTabButton:", forControlEvents: .TouchUpInside)
        
        return button
    }

    
    func didTabButton(button: UIButton) {
        let title = button.titleForState(.Normal)
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        if let input = display?.text as String? {
            proxy.insertText(title!)
        }
    }
    */
    
    func loadInterface() {
        // load the nib file
        let calculatorNib = UINib(nibName: "Calculator", bundle: nil)
        // instantiate the view
        calculatorView = calculatorNib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        // add the interface to the main view
        view.addSubview(calculatorView)
        
        // copy the background color
        view.backgroundColor = calculatorView.backgroundColor
        
        // This will make the button call advanceToNextInputMode() when tapped
        nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
    }
    
    @IBAction func clearDisplay() {
        display.text = "0"
        internalMemory = 0
        nextOperation = Operation.Addition
        shouldClearDisplayBeforeInserting = true
    }
    
    
    @IBAction func didTapNumber(number: UIButton) {
        if shouldClearDisplayBeforeInserting {
            display.text = ""
            shouldClearDisplayBeforeInserting = false
        }
        
        shouldCompute = true
        
        if let numberAsString = number.titleLabel?.text {
            let numberAsNSString = numberAsString as NSString
            if let oldDisplay = display?.text! {
                display.text = "\(oldDisplay)\(numberAsNSString.intValue)"
            } else {
                display.text = "\(numberAsNSString.intValue)"
            }
        }
    }

    @IBAction func didTapDot() {
        if let input = display?.text {
            var hasDot = false
            for ch in input.unicodeScalars {
                if ch == "." {
                    hasDot = true
                    break
                }
            }
            if hasDot == false {
                display.text = "\(input)."
            }
        }
    }

    @IBAction func didTapInsert() {
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        if let input = display?.text as String? {
            proxy.insertText(input)
        }
    }

    @IBAction func didTapOperation(operation: UIButton) {
        if shouldCompute {
            computeLastOperation()
        }
        
        if let op = operation.titleLabel?.text {
            switch op {
            case "+":
                nextOperation = Operation.Addition
            case "-":
                nextOperation = Operation.Subtraction
            case "X":
                nextOperation = Operation.Multiplication
            case "%":
                nextOperation = Operation.Division
            default:
                nextOperation = Operation.None
            }
        }
    }
    
    @IBAction func computeLastOperation() {
        // remember not to compute if another operation is pressed without inputing another number first
        shouldCompute = false
        
        if let input = display?.text {
            let inputAsDouble = (input as NSString).doubleValue
            var result = 0.0
            
            // apply the operation
            switch nextOperation {
            case .Addition:
                result = internalMemory + inputAsDouble
            case .Subtraction:
                result = internalMemory - inputAsDouble
            case .Multiplication:
                result = internalMemory * inputAsDouble
            case .Division:
                result = internalMemory / inputAsDouble
            default:
                result = 0.0
            }
            
            nextOperation = Operation.None
            
            var output = "\(result)"
            
            // if the result is an integer don't show the decimal point
            if output.hasSuffix(".0") {
                output = "\(Int(result))"
            }
            
            // truncatingg to last five digits
            var components = output.componentsSeparatedByString(".")
            if components.count >= 2 {
                let beforePoint = components[0]
                var afterPoint = components[1]
                if afterPoint.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 5 {
                    //let index: String.Index = advance(afterPoint.startIndex, 5)
                    let index: String.Index = afterPoint.startIndex.advancedBy(5)
                    afterPoint = afterPoint.substringToIndex(index)
                }
                output = beforePoint + "." + afterPoint
            }
            
            
            // update the display
            display.text = output
            
            // save the result
            internalMemory = result
            
            // remember to clear the display before inserting a new number
            shouldClearDisplayBeforeInserting = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

}

class RoundButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

class RoundLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
