//
//  AlertService.swift
//  Tracker
//
//  Created by Aleksei Frolov on 17.12.2024.
//

import UIKit

final class AlertService {
    
    static func showDeleteConfirmationAlert(
        title: String,
        deleteOptionTitle: String = Constants.alertServiceDeleteOption,
        onDelete: @escaping () -> Void,
        onCancel: (() -> Void)? = nil,
        presenter: UIViewController
    ) {
        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: deleteOptionTitle,
            style: .destructive
        ) { _ in
            onDelete()
        }
        
        let cancelAction = UIAlertAction(
            title: Constants.alertServiceCancelOption,
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        presenter.present(alert, animated: true, completion: nil)
    }
}
