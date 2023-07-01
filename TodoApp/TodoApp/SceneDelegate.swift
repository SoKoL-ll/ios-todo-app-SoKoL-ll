//
//  SceneDelegate.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 17.06.2023.
//

import UIKit
import TodoItemPackage

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let fileCache = FileCache()
    lazy var presenter = TodoItemsListPresenter(fileCache: fileCache, sceneDelegate: self)
    lazy var setupTodoItemPresenter = SetupTodoItemPresenter(fileCache: fileCache, sceneDelegate: self)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let sceneDelegate = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: sceneDelegate)
        let rootViewController: UIViewController
        presenter.build()
        rootViewController = presenter.open()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate: TodoItemsListDelegate {
    func todoItemsCellDidTap(id: String) {
        let customTransitionDelegate = CustomTransitionDelegate()
        setupTodoItemPresenter.build()
        setupTodoItemPresenter.setupWithTodoItem(id: id)
        let viewControllerSetup = UINavigationController(rootViewController: setupTodoItemPresenter.open())
        viewControllerSetup.transitioningDelegate = customTransitionDelegate
        viewControllerSetup.modalPresentationStyle = .custom
        self.window?.rootViewController?.present(viewControllerSetup, animated: true)
    }
    
    func createNewCell(id: String) {
        setupTodoItemPresenter.build()
        setupTodoItemPresenter.setupNewTodoItem(id: id)
        self.window?.rootViewController?.present(UINavigationController(rootViewController: setupTodoItemPresenter.open()), animated: true)
    }
    
}

extension SceneDelegate: SetupTodoItemDelegate {
    func closeScreen() {
        self.window?.rootViewController?.dismiss(animated: true)
        self.presenter.update()
    }
    
    
}
