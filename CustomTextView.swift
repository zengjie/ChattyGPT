import UIKit

class CustomTextView: UITextView {
    
    var onShiftReturnPressed: (() -> Void)?
    
    override var keyCommands: [UIKeyCommand]? {
        let shiftReturn = UIKeyCommand(title: "", image: nil, action: #selector(shiftReturnPressed), input: "\r", modifierFlags: [.shift], propertyList: nil)
        return [shiftReturn]
    }
}

extension CustomTextView {
    @objc func shiftReturnPressed(_ sender: UIKeyCommand) {
        onShiftReturnPressed?()
    }
}
