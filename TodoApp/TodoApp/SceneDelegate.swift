//
//  SceneDelegate.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 17.06.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let fileCache = FileCache()
    lazy var presenter = TodoItemsListPresenter(fileCache: fileCache, sceneDelegate: self)
    lazy var setupTodoItemPresenter = SetupTodoItemPresenter(fileCache: fileCache, sceneDelegate: self)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let sceneDelegate = (scene as? UIWindowScene) else { return }
        
//        let fileCache = FileCache()
//        fileCache.appendNewItem(item: TodoItem(id: "4", text: "купить машину", importance: Importance.unimportant, deadline: Date.toDate(from: "11.11.2024") ?? Date(), isDone: true, creationDate: Date.toDate(from: "11.12.2024") ?? Date(), modifiedDate: Date.toDate(from: "11.10.2024") ?? Date()))
//
//        fileCache.appendNewItem(item: TodoItem(id: "5", text: "Найти Жену", importance: Importance.important, deadline: Date.toDate(from: "11.11.2024") ?? Date(), isDone: true, creationDate: Date.toDate(from: "11.12.2024") ?? Date(), modifiedDate: Date.toDate(from: "11.10.2024") ?? Date()))
//
//
//        fileCache.saveTodoItemsToJsonFile(file: "TodoItems.json")
//        fileCache.loadTodoItemsFromJsonFile(file: "TodoItems.Json")
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
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
        let vc = UINavigationController(rootViewController: setupTodoItemPresenter.open())
        vc.transitioningDelegate = customTransitionDelegate
        vc.modalPresentationStyle = .custom
        self.window?.rootViewController?.present(vc, animated: true)
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
