//
//  PinCodeView.swift
//  PinCodeView
//
//  Created by Marc Steven on 2021/2/23.
//

import UIKit


public protocol PinCodeViewDelegate:AnyObject {
    func didEnterPinCode(code:String)
}


@available(iOS 11.0,*)
@IBDesignable public class PinCodeView:UIControl {
    fileprivate var spaceSize:CGFloat = 1
    fileprivate  var inputViewSize:CGFloat = 0
    fileprivate var textField:UITextField!
    @IBInspectable public var numberOfSymbols:Int = 4
    @IBInspectable public var inputViewColor:UIColor = UIColor(red: 244/255.0, green: 245/255.0, blue: 247/255.0, alpha: 1)
    @IBInspectable public var symbolColor :UIColor = UIColor(red: 123/255.0, green: 207/255.0, blue: 218/255.0, alpha: 1)
    @IBInspectable public var underlineColor : UIColor = UIColor.init(red: 123/255.0, green: 207/255.0, blue: 218/255.0, alpha: 1)
        @IBInspectable public var underlineSize : CGFloat = 3
        @IBInspectable public var corners : CGFloat = 9
        @IBInspectable public var font : UIFont = UIFont.boldSystemFont(ofSize: 16)
        @IBInspectable public var symbolSize : CGFloat = 16
        @IBInspectable public var code : String = ""
        
        public weak var delegate : PinCodeViewDelegate?
        public var keyboardType: UIKeyboardType = .numberPad
        public var smartQuotesType: UITextSmartQuotesType = .yes
        override public func draw(_ rect: CGRect) {
            self.calculateSizes(rect: rect)
            self.drawViews()
            self.addTarget(self, action: #selector(touchvent), for: .touchDown)
            if self.textField == nil {
                self.textField = UITextField.init(frame: .zero)

            }
            self.addSubview(self.textField)
            self.textField.keyboardType = .numberPad
            self.textField.delegate = self
            if #available(iOS 12.0, *) {
                self.textField.textContentType = .oneTimeCode
            }
        }

         @objc fileprivate func touchvent() {
            self.textField.becomeFirstResponder()
        }

        func reset() {
            self.code = ""
            self.setNeedsDisplay()
        }
        
        
        fileprivate func calculateSizes(rect: CGRect) {
            let spacesCount = numberOfSymbols - 1
            let maxSizeByVertical = rect.height
            let maxSizeByHorisontal = (rect.width - (CGFloat(spacesCount) * spaceSize)) / CGFloat(numberOfSymbols)
            self.inputViewSize = min(maxSizeByVertical, maxSizeByHorisontal)
            self.spaceSize = (rect.width - (self.inputViewSize * CGFloat(numberOfSymbols))) / CGFloat(spacesCount)
        }
        
        fileprivate func  drawViews() {
            
            for i in 0 ..< numberOfSymbols {
                /// background
                let space : CGFloat = (i == 0) ? 0 : spaceSize
                let x = (CGFloat(i) * inputViewSize) + (CGFloat(i) * space)
                let rect = CGRect.init(x: x, y: 0, width: inputViewSize, height: inputViewSize)
                let path = UIBezierPath.init(roundedRect: rect, cornerRadius: corners)
                self.inputViewColor.setFill()
                path.fill()
                
                /// underline
                
                let underlineRect = CGRect.init(x: x + corners, y: inputViewSize - underlineSize, width: inputViewSize - (corners * 2), height: underlineSize)
                let underlinePath = UIBezierPath.init(roundedRect: underlineRect, cornerRadius: 0)
                if i < code.count {
                    symbolColor.setFill()
                } else {
                    underlineColor.setFill()
                }
                underlinePath.fill()
                
                // symbol
                
                let paragraphStyle = NSMutableParagraphStyle()
                
                let newFont = font.withSize(symbolSize)
                print(newFont)
                paragraphStyle.alignment = .center
                let attributes: [NSAttributedString.Key : Any] = [
                    .paragraphStyle: paragraphStyle,
                    .font: newFont,
                    .foregroundColor: symbolColor
                ]
                let symbol = code[i]
                let attributed = NSAttributedString.init(string: symbol, attributes: attributes)
                let symbolRamge = CGRect.init(x: x + corners, y: (inputViewSize - symbolSize) / 2 - underlineSize, width: inputViewSize - (corners * 2), height: symbolSize)
                attributed.draw(in: symbolRamge)
            }
        }
        public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
        
        public override var canBecomeFirstResponder: Bool {return true}
    }



    @available(iOS 11.0, *)
    extension PinCodeView : UITextFieldDelegate {
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            var trimming = ""
            if let raw = textField.text {
                let work = NSMutableString.init(string: raw)
                work.replaceCharacters(in: range, with: string)
                trimming = work as String
                trimming = trimming.replacingOccurrences(of: " ", with: "")
            }
            
            if trimming.count > self.numberOfSymbols {return false}
            
            textField.text = trimming
            self.code = trimming
            self.delegate?.didEnterPinCode(code:self.code)
            self.setNeedsDisplay()
            return false
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.setNeedsDisplay()
            return textField.resignFirstResponder()
        }
    }

