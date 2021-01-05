 
import UIKit

let CScreenWidth = UIScreen.main.bounds.size.width
let defaultAnimationDuration = 0.3
let defaultPlaceholderLeftPadding: CGFloat = 15.0

@objc protocol FloatingTextFieldDelegate:class {
    @objc optional func floatingTextField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    @objc optional func floatingTextFieldDidChange(_ textField : UITextField)
    @objc optional func floatingTextFieldDidBeginEditing(_ textField: UITextField)
    @objc optional func floatingTextFieldDidEndEditing(_ textField: UITextField)
    @objc optional func floatingTextFieldRightViewClick(_ textField: UITextField)
    @objc optional func floatingTextFieldLeftViewClick(_ textField: UITextField)
}


class FloatingTextField: UITextField, UITextFieldDelegate {
    
    public var txtDelegate: FloatingTextFieldDelegate?
    
    @IBOutlet
    public var floatingTextFieldDelegate: AnyObject? {
        get { return delegate as AnyObject }
        set { txtDelegate = newValue as? FloatingTextFieldDelegate }
    }
    
    @IBInspectable var placeHolder: String = ""
    @IBInspectable var placeHolderFont: UIFont?
    @IBInspectable var placeHolderColor:UIColor = UIColor.lightGray
    @IBInspectable var placeHolderColorAfterText:UIColor = UIColor.black
    @IBInspectable var placeHolderBackgroundColor:UIColor = UIColor.white
    @IBInspectable var placeHolderLeftPadding: CGFloat = 15
    @IBInspectable var placeHolderLeftPaddingAfterAnimation: CGFloat = 15
    
    @IBInspectable var borderColor:UIColor = UIColor.black
    @IBInspectable var borderWidth: CGFloat = 0.0
    @IBInspectable var cornerRadius: CGFloat = 1.0
    
    @IBInspectable var rightViewImage: UIImage = UIImage()
    @IBInspectable var leftViewImage: UIImage = UIImage()
    @IBInspectable var allowAnimation: Bool = true
    @IBInspectable var fixedAtTop: Bool = false
    @IBInspectable var roundCorner: Bool = false
    @IBInspectable var showRightView: Bool = false
    @IBInspectable var showLeftView: Bool = false
    
    
    var viewBottomLine = UIView()
    @IBInspectable var showBottomLine: Bool = false
    @IBInspectable var bottomLineColor:UIColor = UIColor.black
    @IBInspectable var bottomLineSelectedColor:UIColor = UIColor.black
    
    var placeholderFontSize : CGFloat = 14
    var lblPlaceHolder = UILabel()
    var btnRightView = UIButton()
    var btnLeftView = UIButton()
    
    var padding = UIEdgeInsets(
        top: 0,
        left: defaultPlaceholderLeftPadding,
        bottom: 0,
        right: defaultPlaceholderLeftPadding
    )
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeholderFontSize = (self.font?.pointSize)!
        
        self.font = UIFont(
            name: (self.font?.fontName)!,
            size: round(CScreenWidth * ((self.font?.pointSize)! / 375))
        )
        
        self.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        DispatchQueue.main.async {
            
            self.textFieldBorderSetup()
            
            self.delegate = self
            self.placeHolderSetup()
            
            // For Right View
            if self.showRightView {
                self.rightViewSetup()
                
                self.padding = UIEdgeInsets(
                    top: 0,
                    left: defaultPlaceholderLeftPadding,
                    bottom: 0,
                    right: self.frame.size.height
                )
            }
            
            // For Left View
            if self.showLeftView {
                self.leftViewSetup()
                
                self.padding = UIEdgeInsets(
                    top: 0,
                    left: self.frame.size.height + 5,
                    bottom: 0,
                    right: defaultPlaceholderLeftPadding
                )
            }
            
            // For Bottom line
            if self.showBottomLine {
                self.bottomLineViewSetup()
            }
            
        }
        
    }
}

// MARK:- --------TextField Inset

extension FloatingTextField {
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

// MARK:- --------Helper Method

extension FloatingTextField {
    
    private func textFieldBorderSetup() {
        
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        //turnery
        if roundCorner {
            self.layer.cornerRadius = self.frame.size.height/2
        }else {
            self.layer.cornerRadius = cornerRadius
        }
        
    }
    
    func updateBottomLineAndPlaceholderFrame() {
        
        lblPlaceHolder.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.frame.size.width,
            height: lblPlaceHolder.frame.size.height
        )
    }
    
    
}

// MARK:- --------PlaceHolder

extension FloatingTextField {
    
    func placeHolderSetup() {
        
        lblPlaceHolder.frame = CGRect(
            x: self.placeHolderXPosstion(false),
            y: self.frame.origin.y + 5,
            width: self.frame.size.width,
            height: self.frame.size.height - 10
        )
        
        lblPlaceHolder.backgroundColor = placeHolderBackgroundColor
        lblPlaceHolder.text = " \(placeHolder) "
        lblPlaceHolder.textColor = placeHolderColor
        
        lblPlaceHolder.font = UIFont(
            name: (self.font?.fontName)!,
            size: round(CScreenWidth * (placeholderFontSize / 375))
        )
        
        lblPlaceHolder.isUserInteractionEnabled = false
        self.superview?.addSubview(lblPlaceHolder)
        
        // To fixed placeholder at top
        if fixedAtTop {
            
            let heightOfLable:CGFloat = CScreenWidth * 16 / 375
            
            self.lblPlaceHolder.frame = CGRect(
                x: self.placeHolderXPosstion(true),
                y: self.frame.origin.y - (heightOfLable/2),
                width: self.frame.size.width,
                height: heightOfLable
            )
            
            self.updateWidthOfPlaceholder(true)
        }else {
            self.updateWidthOfPlaceholder(false)
        }
        
    }
    
    func updatePlaceholderFrame(_ isMoveUp : Bool?) {
        
        // Hide Placeholder
        if self.tag == 1 || self.tag == 3{
            lblPlaceHolder.isHidden = isMoveUp!
            return
        }
        
        // Animation will not perform for fixed placholder at top.
        if fixedAtTop {
            return
        }
        
        // Move Placeholder
        if isMoveUp! {
            
            UIView.animate(withDuration: defaultAnimationDuration) {
                self.lblPlaceHolder.textColor = self.placeHolderColorAfterText
                
                let heightOfLable:CGFloat = CScreenWidth * 16 / 375
                self.lblPlaceHolder.frame = CGRect(
                    x: self.placeHolderXPosstion(true),
                    y: self.frame.origin.y - (heightOfLable/2),
                    width: self.frame.size.width,
                    height: heightOfLable
                )
                
                self.lblPlaceHolder.font = UIFont(
                    name: (self.font?.fontName)!,
                    size: round(CScreenWidth * (self.placeholderFontSize - 2) / 375)
                )
                
                self.layoutIfNeeded()
                self.updateWidthOfPlaceholder(true)
            }
        } else {
            UIView.animate(withDuration: defaultAnimationDuration) {
                self.lblPlaceHolder.textColor = self.placeHolderColor
                
                self.lblPlaceHolder.frame = CGRect(
                    x: self.placeHolderXPosstion(false),
                    y: self.frame.origin.y + 5,
                    width: self.frame.size.width,
                    height: self.frame.size.height - 10
                )
                
                self.lblPlaceHolder.font = UIFont(
                    name: (self.font?.fontName)!,
                    size: round(CScreenWidth * (self.placeholderFontSize ) / 375)
                )
                
                self.layoutIfNeeded()
                self.updateWidthOfPlaceholder(false)
            }
        }
        
    }
    
    private func placeHolderXPosstion(_ isSmallHeight: Bool) -> CGFloat {
        
        var xPossition: CGFloat = 0.0
        
        if isSmallHeight {
            xPossition = self.frame.origin.x + placeHolderLeftPaddingAfterAnimation
        }else {
            xPossition = self.frame.origin.x + placeHolderLeftPadding
        }
        
        if showLeftView {
            xPossition = self.frame.height + 5 + self.frame.origin.x
        }
        
        return xPossition
    }
    
    private func updateWidthOfPlaceholder(_ isSmallHeight: Bool) {
        
        lblPlaceHolder.sizeToFit()
        lblPlaceHolder.frame.size.height = isSmallHeight ? CScreenWidth * 16 / 375 : self.frame.size.height - 10
        
        var maxWidth: CGFloat = self.frame.size.width
        
        if showLeftView {
            maxWidth -= (self.frame.size.height + 5)
        }else {
            maxWidth -= placeHolderLeftPaddingAfterAnimation
        }
        
        if showRightView {
            maxWidth -= (self.frame.size.height + 5)
        } else {
            maxWidth -= placeHolderLeftPaddingAfterAnimation
        }
        
        // If placeholder widht is out of bound.
        if lblPlaceHolder.frame.size.width > maxWidth {
            lblPlaceHolder.frame.size.width = maxWidth
        }
        
    }
    
}

// MARK:- -------- Bottom Line

extension FloatingTextField {
 
    private func bottomLineViewSetup(){
        
        viewBottomLine.frame = CGRect(x: 0.0, y: self.frame.size.height-1, width: self.frame.size.width, height: 1.0)
        viewBottomLine.backgroundColor = bottomLineColor
        self.addSubview(viewBottomLine)
    }
    
    func updatedBottomLineColor(_ isNormalColor: Bool) {
        viewBottomLine.backgroundColor = isNormalColor ? bottomLineColor : bottomLineSelectedColor
    }
    
}

// MARK:- -------- Right view

extension FloatingTextField {
    
    private func rightViewSetup() {
        
        btnRightView.frame = CGRect(
            x: 0.0,
            y: 0,
            width: self.frame.size.height,
            height: self.frame.size.height
        )
        
        btnRightView.setImage(rightViewImage, for: .normal)
        self.rightViewMode = .always
        self.rightView = btnRightView
        
        btnRightView.addTarget(
            self,
            action: #selector(self.rightViewButtonClick(_:)),
            for: .touchUpInside
        )
        
    }
    
    @objc func rightViewButtonClick(_ sender : UIButton) {
        
        guard let delegate = self.txtDelegate else {
            return
        }
        
        _ = delegate.floatingTextFieldRightViewClick?(self)
        
    }
    
}

// MARK:- -------- Left view

extension FloatingTextField {
    
    private func leftViewSetup() {
        
        btnLeftView.frame = CGRect(
            x: 0.0,
            y: 0,
            width: self.frame.size.height,
            height: self.frame.size.height
        )
        
        btnLeftView.setImage(leftViewImage, for: .normal)
        
        self.leftViewMode = .always
        self.leftView = btnLeftView
        
        btnLeftView.addTarget(
            self,
            action: #selector(self.leftViewButtonClick(_:)),
            for: .touchUpInside
        )
        
    }
    
    @objc func leftViewButtonClick(_ sender : UIButton) {
        
        guard let delegate = self.txtDelegate else {
            return
        }
        
        _ = delegate.floatingTextFieldLeftViewClick?(self)
    }
    
}


// MARK:- --------Textfiled Delegate methods

extension FloatingTextField {
    
    @objc func textFieldDidChange(_ textField : UITextField) {
        
        guard let delegate = self.txtDelegate else {
            return
        }
        
        _ = delegate.floatingTextFieldDidChange?(textField)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // update placeholder frame
        self.updatePlaceholderFrame(true)
        
        guard let delegate = self.txtDelegate else {
            return
        }
        
        _ = delegate.floatingTextFieldDidBeginEditing?(textField)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if self.text?.count == 0{
            // update placeholder frame
            self.updatePlaceholderFrame(false)
        }
        
        guard let delegate = self.txtDelegate else {
            return
        }
        
        _ = delegate.floatingTextFieldDidEndEditing?(textField)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let delegate = self.txtDelegate else {
            return true
        }
        
        return delegate.floatingTextField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        
    }
    
}
