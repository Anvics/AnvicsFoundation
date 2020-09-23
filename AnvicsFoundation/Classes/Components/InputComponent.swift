//
//  TextfieldComponent.swift
//  Hora
//
//  Created by Nikita Arkhipov on 07.02.2020.
//  Copyright © 2020 Hora. All rights reserved.
//

import UIKit
import ReactiveKit
import FastArchitecture
import Bond
import Animatics
import AnimaticsBond
import SwifterSwift

class InputComponentData: Equatable{
    let text: String?
    let placeholder: String?
    
    let hasError: Bool?
    
    let isEnabled: Bool?
    let isVisible: Bool?
    let isFirstRepsonder: Bool?
    
    public init(text: String? = nil, placeholder: String? = nil, hasError: Bool? = nil, isEnabled: Bool? = nil, isVisible: Bool? = nil, isFirstRepsonder: Bool? = nil) {
        self.text = text
        self.placeholder = placeholder
        self.hasError = hasError
        self.isEnabled = isEnabled
        self.isVisible = isVisible
        self.isFirstRepsonder = isFirstRepsonder
    }
    
    func isEqual(to: InputComponentData) -> Bool{
        return text == to.text && placeholder == to.placeholder && hasError == to.hasError && isEnabled == to.isEnabled && isVisible == to.isVisible && isFirstRepsonder == to.isFirstRepsonder
    }
}

func ==(left: InputComponentData, right: InputComponentData) -> Bool{
    return left.isEqual(to: right)
}

//MARK: - InputComponent
class InputComponent: UIView{
    static var textFont = UIFont.systemFont(ofSize: 16)
    static var textColor = UIColor.black
    
    static var placeholderFont = UIFont.systemFont(ofSize: 16)
    static var placeholderColor = UIColor(hexString: "#757575")
    static var errorColor = UIColor.red
    static var placeholderScale: CGFloat = 0.75
    static var underlineColor = UIColor.clear
    static var inactiveUnderlineColor = UIColor.clear
    static var underlineHeight: CGFloat = 1
    static var borderColor = UIColor.white
    static var borderWidth: CGFloat = 1
    static var cornerRadius: CGFloat = 4
    static var cornersOffset: CGFloat = 0
    
    let textField = UITextField()
    let isEnabled = Property(true)
//    fileprivate var skipTextTimes: Int { 2 }
    
    fileprivate let text = Property("")
    fileprivate let textUpdatedEvent = SafeReplayOneSubject<String>()
    fileprivate let placeholderLabel = UILabel()
    private var cornersOffset: CGFloat{ return InputComponent.cornersOffset }
    
    fileprivate let underlineView = UIView()
    
    @IBInspectable var placeholder: String = "" {
        didSet { placeholderLabel.text = placeholder }
    }
    @IBInspectable var showsClearButton: Bool = false {
        didSet { textField.clearButtonMode = showsClearButton ? .always : .never }
    }
    
    @IBInspectable var visibleOffset: CGFloat {
        get { return textField.visibleOffset }
        set { textField.visibleOffset = newValue }
    }
    
    @IBInspectable var defaultIsEmpty: Bool = true
    @IBInspectable var hasToolbar: Bool = false{
        didSet { if hasToolbar { addToolbar() } }
    }
    
    private var stringMask: StringMask?
    
    @IBInspectable open var maskString: String? {
        didSet {
            guard let maskString = maskString else { return }
            stringMask = StringMask(mask: maskString)
        }
    }
    
    func setInitial(text: String?){
        guard let text = text else { return }
        self.text.value = text
        textField.text = text
        defaultIsEmpty = false
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = CGRect(x: cornersOffset, y: 15, width: bounds.width - cornersOffset * 2, height: 32)
        underlineView.frame = CGRect(x: 0, y: bounds.size.height - InputComponent.underlineHeight - 1, width: bounds.size.width, height: InputComponent.underlineHeight)
        clipsToBounds = false
        if textField.superview == nil { addViews() }
    }
    
    fileprivate func addViews(){
        [textField, placeholderLabel, underlineView].forEach(addSubview)
        textField.font = InputComponent.textFont
        textField.textColor = InputComponent.textColor
        textField.borderStyle = .none
        textField.clearButtonMode = .never
        textField.delegate = self
        
        placeholderLabel.frame = CGRect(x: cornersOffset, y: 16, width: bounds.width - cornersOffset * 2, height: 24)
        placeholderLabel.font = InputComponent.placeholderFont
        placeholderLabel.textColor = InputComponent.placeholderColor
        if !defaultIsEmpty { moveUpPlaceholderAnimation.performWithoutAnimation() }
        
        borderColor = InputComponent.borderColor
        borderWidth = InputComponent.borderWidth
        cornerRadius = InputComponent.cornerRadius
        
        underlineView.backgroundColor = InputComponent.underlineColor
        bringSubviewToFront(underlineView)
        
        setupBindings()
    }
    
    fileprivate func setupBindings(){
        isEnabled.toSignal().animateFalse(disableAnimation)
        isEnabled.bind(to: reactive.isUserInteractionEnabled)
        text.bind(to: textUpdatedEvent)
        textUpdatedEvent.map { $0.isEmpty }.animateFalse(moveUpPlaceholderAnimation, initiallyPerform: nil)
//        textField.reactive.text.ignoreNils().dropFirst(skipTextTimes).bind(to: text)
    }
    
    @objc func finishEditing() {
        endEditing(true)
    }
    
    func updateText(_ text: String){
        textField.text = text
        textUpdatedEvent.send(text)
    }
    
    fileprivate func setHasError(_ hasError: Bool){
        placeholderLabel.textColor = hasError ? InputComponent.errorColor : InputComponent.placeholderColor
    }
    
    fileprivate func addToolbar() {
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.barTintColor = UIColor.white
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(finishEditing))
        doneButton.tintColor = UIColor.black
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
    }
    
    func update(data: InputComponentData){
        resolve(data.text, resolver: updateText(_:))
        resolve(data.placeholder) { self.placeholder = $0 }
        resolve(data.hasError, resolver: setHasError(_:))
        resolve(data.isEnabled) { self.isEnabled.value = $0 }
        resolve(data.isVisible) {
            self.isHidden = !$0
            if !$0 { self.resignFirstResponder() }
        }
        resolve(data.isFirstRepsonder) {
            _ = $0 ? self.textField.becomeFirstResponder() : self.resignFirstResponder()
        }
    }
    
    private var disableAnimation: AnimaticsReady { return AlphaAnimator(0.5).to(self) }
    
    private var moveUpPlaceholderAnimation: AnimaticsReady {
        return (ScaleAnimator(InputComponent.placeholderScale).to(placeholderLabel) + XAnimator(cornersOffset).to(placeholderLabel) + YAnimator(2).to(placeholderLabel)).duration(0.5)
    }
}

extension InputComponent: UITextFieldDelegate{
    func textFieldShouldClear(_ textField: UITextField) -> Bool{
        text.value = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishEditing()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let previousMask = self.stringMask
        let currentText: NSString = textField.text as NSString? ?? ""
        
        let newText = currentText.replacingCharacters(in: range, with: string)

        guard let mask = self.stringMask else { text.value = newText; return true }
        
        var formattedString = mask.mask(string: newText)
        
        if (previousMask != nil && mask != previousMask!) || formattedString == nil {
            let unmaskedString = mask.unmask(string: newText)
            formattedString = mask.mask(string: unmaskedString)
        }
        
        guard let finalText = formattedString as NSString? else { return false }
        
        if finalText == currentText && range.location < currentText.length && range.location > 0 {
            let res = self.textField(textField, shouldChangeCharactersIn: NSRange(location: range.location - 1, length: range.length + 1) , replacementString: string)
            if res { text.value = formattedString ?? "" }
            
            return res
        }
        
        text.value = formattedString ?? ""

        if finalText != currentText {
            textField.text = finalText as String
            
            if range.location < currentText.length {
                var cursorLocation = 0
                
                if range.location > finalText.length {
                    cursorLocation = finalText.length
                } else if currentText.length > finalText.length {
                    cursorLocation = range.location
                } else {
                    cursorLocation = range.location + 1
                }
                
                guard let startPosition = textField.position(from: textField.beginningOfDocument, offset: cursorLocation) else { return false }
                guard let endPosition = textField.position(from: startPosition, offset: 0) else { return false }
                textField.selectedTextRange = textField.textRange(from: startPosition, to: endPosition)
            }
            
            return false
        }
        
        return true
    }
}

class TextfieldComponent: InputComponent, FastComponent{
    var event: SafeSignal<String> { text.dropFirst(1) }
}

//MARK: - DateInputComponent
class DateInputData: InputComponentData, FastDataCreatable{
    var minimumDate: Date?
    var currentDate: Date?
    var maximumDate: Date?
    
    required public init(data: Date?){
        currentDate = data
        super.init()
    }
    init(minimumDate: Date? = nil, currentDate: Date? = nil, maximumDate: Date? = nil, placeholder: String? = nil, hasError: Bool? = nil, isEnabled: Bool? = nil, isVisible: Bool? = nil, isFirstRepsonder: Bool? = nil) {
        self.minimumDate = minimumDate
        self.currentDate = currentDate
        self.maximumDate = maximumDate
        super.init(placeholder: placeholder, hasError: hasError, isEnabled: isEnabled, isVisible: isVisible, isFirstRepsonder: isFirstRepsonder)
    }
    
    override func isEqual(to: InputComponentData) -> Bool {
        if let to = to as? DateInputData{
            return minimumDate == to.minimumDate && currentDate == to.minimumDate && maximumDate == to.maximumDate && super.isEqual(to: to)
        }
        return super.isEqual(to: to)
    }
}

class DateInputComponent: InputComponent, FastComponent{
    typealias Data = DateInputData
    let event = SafeReplayOneSubject<Date>()
    let datePicker = UIDatePicker(frame: .zero)
    
    var minimumDate: Date? {
        didSet { datePicker.minimumDate = minimumDate }
    }
    
    var currentDate: Date?{
        didSet{ if let d = currentDate { datePicker.date = d } }
    }
    
    var maximumDate: Date? {
        didSet { datePicker.maximumDate = maximumDate }
    }
    
    var dateFormat = "MM/dd/yyyy"
    
    var pickerMode: UIDatePicker.Mode = .time
    
    func setLocale(_ locale: String){
        datePicker.locale = Locale(identifier: locale)
    }
    
    func updateText(date: Date){
        updateText(date.string(withFormat: dateFormat))
    }
    
    override func setupBindings() {
        super.setupBindings()
        datePicker.datePickerMode = pickerMode
        datePicker.reactive.date.bind(to: event)
        datePicker.reactive.date.map { [weak self] d in self?.format(date: d) ?? "" }.bind(to: text)
        text.dropFirst(1).bind(to: textField.reactive.text)
        
        textField.inputView = datePicker
        addToolbar()
    }
    
    func update(data: DateInputData) {
        resolve(data.minimumDate) { self.minimumDate = $0 }
        resolve(data.currentDate) { self.currentDate = $0; self.updateText(date: $0) }
        resolve(data.maximumDate) { self.maximumDate = $0 }
        super.update(data: data)
    }
    
    private func format(date: Date) -> String{
        date.string(withFormat: dateFormat)
    }
}

//MARK: - OptionPickerComponent
class OptionPickerData: InputComponentData, FastDataCreatable{
    var selectedOption: Int?
    var options: [String]?
    
    required public init(data: [String]?){
        options = data
        super.init()
    }
    
    init(selectedOption: Int? = nil, options: [String]? = nil, placeholder: String? = nil, hasError: Bool? = nil, isEnabled: Bool? = nil, isVisible: Bool? = nil, isFirstRepsonder: Bool? = nil) {
        self.selectedOption = selectedOption
        self.options = options
        super.init(placeholder: placeholder, hasError: hasError, isEnabled: isEnabled, isVisible: isVisible, isFirstRepsonder: isFirstRepsonder)
    }
    
    override func isEqual(to: InputComponentData) -> Bool {
        if let to = to as? OptionPickerData{
            return selectedOption == to.selectedOption && options == to.options && super.isEqual(to: to)
        }
        return super.isEqual(to: to)
    }
}

class OptionPickerComponent: InputComponent, FastComponent{
    typealias Data = OptionPickerData
    
    let event = SafeReplayOneSubject<Int>()
    
    let optionsPicker = UIPickerView(frame: CGRect.zero)
    
//    override var skipTextTimes: Int{ 1 }
    
    var pickerOptions: [String] = []{
        didSet{ updateOptions() }
    }
    
    override func setupBindings() {
        super.setupBindings()
        optionsPicker.reactive.selectedRow.map { i, c in i }.bind(to: event)
        text.dropFirst(1).bind(to: textField.reactive.text)
        
        textField.inputView = optionsPicker
        addToolbar()
    }
    
    func setSelectedIndex(_ index: Int){
        guard 0 <= index && index < pickerOptions.count else {
            print("OptionPickerComponent: incorrect index \(index) with \(pickerOptions.count) elements: \(pickerOptions)")
            return
        }
        updateText(pickerOptions[index])
        optionsPicker.selectRow(index, inComponent: 0, animated: false)
    }
    
    func update(data: OptionPickerData) {
        resolve(data.options) {
            self.pickerOptions = $0
            self.setSelectedIndex(0)
        }
        resolve(data.selectedOption) { self.setSelectedIndex($0) }
        super.update(data: data)
    }
    
    private let optionsBag = DisposeBag()
    
    private func updateOptions(){
        optionsBag.dispose()
        let values = pickerOptions//Array(pickerOptions.split(separator: ",").map(String.init))
        let data = MutableObservableArray(values)
        data.bind(to: optionsPicker).dispose(in: optionsBag)
        event.map { values.safeAt(index: $0) }.ignoreNils().bind(to: text).dispose(in: optionsBag)
    }
}







fileprivate struct Constants {
    static let letterMaskCharacter: Character = "A"
    static let numberMaskCharacter: Character = "0"
}

struct StringMask: Equatable {
    
    var mask: String = ""
    
    private init() { }
    
    public init(mask: String) {
        self.init()
        
        self.mask = mask
    }
    
    public static func ==(lhs: StringMask, rhs: StringMask) -> Bool {
        return lhs.mask == rhs.mask
    }
    
    public func mask(string: String?) -> String? {
        
        guard let string = string else { return nil }
        
        if string.count > mask.count {
            return nil
        }
        
        var formattedString = ""
        
        var currentMaskIndex = 0
        for i in 0..<string.count {
            if currentMaskIndex >= mask.count {
                return nil
            }
            
            let currentCharacter = string[string.index(string.startIndex, offsetBy: i)]
            var maskCharacter = mask[mask.index(string.startIndex, offsetBy: currentMaskIndex)]
            
            if currentCharacter == maskCharacter {
                formattedString.append(currentCharacter)
            } else {
                while (maskCharacter != Constants.letterMaskCharacter && maskCharacter != Constants.numberMaskCharacter) {
                    formattedString.append(maskCharacter)
                    
                    currentMaskIndex += 1
                    maskCharacter = mask[mask.index(string.startIndex, offsetBy: currentMaskIndex)]
                }
                
                let isValidLetter = maskCharacter == Constants.letterMaskCharacter && isValidLetterCharacter(currentCharacter)
                let isValidNumber = maskCharacter == Constants.numberMaskCharacter && isValidNumberCharacter(currentCharacter)
                
                if !isValidLetter && !isValidNumber {
                    return nil
                }
                
                formattedString.append(currentCharacter)
            }
            
            currentMaskIndex += 1
        }
        
        return formattedString
    }
    
    public func unmask(string: String?) -> String? {
        
        guard let string = string else { return nil }
        var unmaskedValue = ""
        
        for character in string {
            if self.isValidLetterCharacter(character) || isValidNumberCharacter(character) {
                unmaskedValue.append(character)
            }
        }
        
        return unmaskedValue
    }
    
    private func isValidLetterCharacter(_ character: Character) -> Bool {
        
        let string = String(character)
        if string.unicodeScalars.count > 1 {
            return false
        }
        
        let lettersSet = NSCharacterSet.letters
        let unicodeScalars = string.unicodeScalars
        return lettersSet.contains(unicodeScalars[unicodeScalars.startIndex])
    }
    
    private func isValidNumberCharacter(_ character: Character) -> Bool {
        
        let string = String(character)
        if string.unicodeScalars.count > 1 {
            return false
        }
        
        let lettersSet = NSCharacterSet.decimalDigits
        let unicodeScalars = string.unicodeScalars
        return lettersSet.contains(unicodeScalars[unicodeScalars.startIndex])
    }
    
}
