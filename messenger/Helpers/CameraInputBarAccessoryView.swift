//
//  CameraInputBarAccessoryView.swift
//  messenger
//
//  Created by Администратор on 09.05.2022.
//

import UIKit
import InputBarAccessoryView

protocol  CameraInputBarAccessoryViewDelegate : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
}

extension CameraInputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]){
        
    }
}


 class CameraInputBarAccessoryView: InputBarAccessoryView {
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    func configure(){
        let camera = makeButton(named: "ic_camera")
        camera.tintColor = .darkGray
        camera.onTouchUpInside { [weak self] item in
            self?.showImagePickerControllerActionSheet()
        }
        self.setLeftStackViewWidthConstant(to: 35, animated: true)
        self.setStackViewItems([camera], forStack: .left, animated: false)
        self.inputPlugins = [attachmentManager]
    }
    
    override func didSelectSendButton() {
        
        if attachmentManager.attachments.count > 0 {
            
            (delegate as? CameraInputBarAccessoryViewDelegate)?.inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
        }
        else {
            
            delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
        }
    }
    
    
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                   
                if #available(iOS 13.0, *) {
                    $0.image = UIImage(systemName: "camera.fill")?.withRenderingMode(.alwaysTemplate)
                } else {
                    $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                }
                
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
    }
    
}




extension CameraInputBarAccessoryView : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @objc  func showImagePickerControllerActionSheet()  {
        

        let photoLibraryAction = UIAlertAction(title: "Выбрать из библиотеки", style: .default) { [weak self] action in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }
        
        let cameraAction = UIAlertAction(title: "Сфотографировать", style: .default) { [weak self] action in
            self?.showImagePickerController(sourceType: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default , handler: nil)
        
        showAlert(style: .actionSheet, title: "Выберите изображение", message: nil, actions: [photoLibraryAction, cameraAction , cancelAction], completion: nil)
    }
    
    func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "Ок", style: .cancel, handler: nil)], completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        
        getRootViewController()?.present(alert, animated: true, completion: completion)
    }
    
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType){
        
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = sourceType
        imgPicker.presentationController?.delegate = self
        inputAccessoryView?.isHidden = true
        getRootViewController()?.present(imgPicker, animated: true, completion: nil)
      
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[  UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            self.inputPlugins.forEach { _ = $0.handleInput(of: editedImage)}

        }
        else if let originImage = info[  UIImagePickerController.InfoKey.originalImage] as? UIImage {
 
            self.inputPlugins.forEach { _ = $0.handleInput(of: originImage)}
             
        }
        getRootViewController()?.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        getRootViewController()?.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
    }
    
    
    func getRootViewController() -> UIViewController? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
    }
    
    
}

extension CameraInputBarAccessoryView: AttachmentManagerDelegate {
    
    
    // MARK: - AttachmentManagerDelegate
    
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        self.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        self.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        self.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        self.showImagePickerControllerActionSheet()
    }
    
    // MARK: - AttachmentManagerDelegate Helper
    
    func setAttachmentManager(active: Bool) {
        
        let topStackView = self.topStackView
        if active && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
    }
}


extension CameraInputBarAccessoryView: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        isHidden = false
    }
}
