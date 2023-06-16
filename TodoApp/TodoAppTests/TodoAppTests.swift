//
//  TodoAppTests.swift
//  TodoAppTests
//
//  Created by Alexandr Sokolov on 17.06.2023.
//

import XCTest
@testable import TodoApp

final class TodoAppTests: XCTestCase {

    var todoItem: TodoItem!
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        todoItem = TodoItem(id: "4", text: "купить машину", importance: Importance.unimportant, deadline: Date.toDate(from: "11.11.2002") ?? Date(), isDone: true, creationDate: Date.toDate(from: "11.12.2002") ?? Date(), modifiedDate: Date.toDate(from: "11.10.2002") ?? Date())
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        todoItem = nil
        try super.tearDownWithError()
    }

    func testInit() throws {
        XCTAssertEqual(self.todoItem.id, "4")
        XCTAssertEqual(self.todoItem.text, "купить машину")
        XCTAssertEqual(self.todoItem.importance, Importance.unimportant)
        XCTAssertEqual(self.todoItem.deadline, Date.toDate(from: "11.11.2002")!)
        XCTAssertTrue(self.todoItem.isDone)
        XCTAssertEqual(self.todoItem.creationDate, Date.toDate(from: "11.12.2002")!)
        XCTAssertEqual(self.todoItem.modifiedDate, Date.toDate(from: "11.10.2002")!)
        
    }

    
    func testParseJson() throws {
        var answer: [String: Any] = [
            "text": "купить машину",
            "isDone": true,
            "id": "4",
            "creationDate": "11.12.2002",
            "importance": "unimportant",
            "modifiedDate": "11.10.2002",
            "deadline": "11.11.2002"
        ]
        
        var todoItemFromJson = TodoItem.parse(json: answer)
        
        XCTAssertEqual(self.todoItem.id, todoItemFromJson?.id)
        XCTAssertEqual(self.todoItem.text, todoItemFromJson?.text)
        XCTAssertEqual(self.todoItem.importance, todoItemFromJson?.importance)
        XCTAssertEqual(self.todoItem.deadline, todoItemFromJson?.deadline)
        XCTAssertEqual(self.todoItem.isDone, todoItemFromJson?.isDone)
        XCTAssertEqual(self.todoItem.creationDate, todoItemFromJson?.creationDate)
        XCTAssertEqual(self.todoItem.modifiedDate, todoItemFromJson?.modifiedDate)
        
        answer["id"] = nil
        todoItemFromJson = TodoItem.parse(json: answer)
        
        XCTAssertEqual(nil, todoItemFromJson?.isDone)
        
        answer = [
            "text": "купить машину",
            "id": "4",
            "creationDate": "",
            "modifiedDate": "11.10.2002",
            "deadline": "11.11.2002"
        ]
        
        todoItemFromJson = TodoItem.parse(json: answer)
        
        XCTAssertEqual(todoItemFromJson?.isDone, false)
        XCTAssertEqual(todoItemFromJson?.importance, Importance.common)
    }
    
    
    func testGetJsonFromTodoItem() throws {
        let answer: [String: Any] = [
            "text": "купить машину",
            "isDone": true,
            "id": "4",
            "creationDate": "11.12.2002",
            "importance": "unimportant",
            "modifiedDate": "11.10.2002",
            "deadline": "11.11.2002"
        ]
        let todoItemJson = self.todoItem.json as? [String: Any]
        XCTAssertEqual(todoItemJson!["id"] as! String, answer["id"] as! String)
        XCTAssertEqual(todoItemJson!["text"] as! String, answer["text"] as! String)
        XCTAssertEqual(todoItemJson!["isDone"] as! Bool, answer["isDone"] as! Bool)
        XCTAssertEqual(todoItemJson!["creationDate"] as! String, answer["creationDate"] as! String)
        XCTAssertEqual(todoItemJson!["importance"] as! String, answer["importance"] as! String)
    }
    
    func testGetCSVFromTodoItem() throws {
        let answer = "4,купить машину,unimportant,11.11.2002,true,11.12.2002,11.10.2002"
        
        let todoItemCSV = self.todoItem.csv
        
        XCTAssertEqual(answer, todoItemCSV)
    }
    
    func testParseCSV() throws {
        var answer = "4,купить машину,unimportant,11.11.2002,true,11.12.2002,11.10.2002"
        
        var todoItemFromCSV = TodoItem.parse(csv: answer)
        
        XCTAssertEqual(self.todoItem.id, todoItemFromCSV?.id)
        XCTAssertEqual(self.todoItem.text, todoItemFromCSV?.text)
        XCTAssertEqual(self.todoItem.importance, todoItemFromCSV?.importance)
        XCTAssertEqual(self.todoItem.deadline, todoItemFromCSV?.deadline)
        XCTAssertEqual(self.todoItem.isDone, todoItemFromCSV?.isDone)
        XCTAssertEqual(self.todoItem.creationDate, todoItemFromCSV?.creationDate)
        XCTAssertEqual(self.todoItem.modifiedDate, todoItemFromCSV?.modifiedDate)
        
        answer = "4,купить машину,,11.11.2002,true,11.12.2002,11.10.2002"
        todoItemFromCSV = TodoItem.parse(csv: answer)
        XCTAssertEqual(Importance.common, todoItemFromCSV?.importance)
        
        answer = "4,11.10.2002"
        todoItemFromCSV = TodoItem.parse(csv: answer)
        XCTAssertEqual(nil, todoItemFromCSV?.id)

        answer = "4,купить машину,unimportant,,,11.12.2002,"
        todoItemFromCSV = TodoItem.parse(csv: answer)
        XCTAssertEqual(nil, todoItemFromCSV?.deadline)
        XCTAssertEqual(nil, todoItemFromCSV?.modifiedDate)
        
        
        
    }
}
