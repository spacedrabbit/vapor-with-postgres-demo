//
//  TasksViewController.swift
//  vapor-todolist
//
//  Created by Louis Tur on 5/13/17.
//
//

import Foundation
import Vapor
import VaporPostgreSQL
import HTTP

// MARK: - Newer Lesson
final class TaskViewController {
  
  convenience init(drop: Droplet)  {
    self.init()
    
    self.addRoutes(drop: drop)
    
    // cant get this table check to work. passing on this for now
    //do {
    //  try drop.database?.driver.raw("SELECT * FROM sqlite_master WHERE name ='Tasks' and type='table';")
    //}
    //catch {
    // self.createDB()
    //}
  }
  
  // TODO: look into the function signature for handler to explain to the class
  func addRoutes(drop: Droplet) {
    drop.get("version", handler: version)
    drop.get("task", "all", handler: getAll)
    drop.post("task", "new", handler: create)
    drop.put("task", "update", handler: update)
    drop.delete("task", "delete", handler: delete)
    
    drop.get("catDB", "make", handler: createKittyDB)
    drop.post("catDB", "create", handler: insertKitty)
  }
  
  func version(request: Request) throws -> ResponseRepresentable {
    return try JSON(node: drop.database?.driver.raw("SELECT version()"))
  }
  
  func getAll(request: Request) throws -> ResponseRepresentable {
    guard let result = try drop.database?.driver.raw("SELECT * FROM tasks;") else {
      throw Abort.badRequest
    }
    
    guard let nodes = result.nodeArray else {
      return try JSON(node: [])
    }
    
    let tasks = nodes.flatMap{ Task(node: $0) }
    return try JSON(node: tasks)
  }
  
  func create(request: Request) throws -> ResponseRepresentable {
    
    guard
      let id = request.json?["id"]?.int, // this is created automatically since it is a unique key
      let taskTitle = request.json?["title"]?.string
      else {
        throw Abort.badRequest
    }
    
    // TODO: look up this sql syntax
    // TODO: how to make it to autoincrement
    guard let _ = try drop.database?.driver.raw("INSERT INTO tasks (taskID, title) VALUES (\(id), '\(taskTitle)');") else {
      throw Abort.custom(status: .notAcceptable, message: "Could not insert")
    }
    
    return "Task added"
  }
  
  func update(request: Request) throws -> ResponseRepresentable {
    guard
      let id = request.json?["id"]?.int,
      let taskTitle = request.json?["title"]?.string
      else { throw Abort.badRequest }
    
    guard let _ = try drop.database?.driver.raw("UPDATE tasks SET title = '\(taskTitle)' WHERE taskID = \(id);") else {
      throw Abort.custom(status: .notAcceptable, message: "Could not update record with ID: \(id)")
    }
    
    return try JSON(node: ["success":true])
  }
  
  func delete(request: Request) throws -> ResponseRepresentable {
    
    guard
      let id = request.json?["id"]?.int
      else { throw Abort.badRequest }
    
    guard let record = try drop.database?.driver.raw("SELECT * FROM tasks WHERE taskID = \(id);") else {
      throw Abort.notFound
    }
    
    guard let verifiedCount = record.array?.count, verifiedCount > 0 else {
      throw Abort.notFound
    }
    
    guard let _ = try drop.database?.driver.raw("DELETE FROM tasks WHERE taskID = \(id);") else {
      throw Abort.custom(status: .notAcceptable, message: "Could not delete record with ID: \(id)")
    }
    
    return try JSON(node: ["success":true])
  }
  
  
  
  // MARK: - Kitty Requests
  let cat: String = "cats"
  func createKittyDB(request: Request) -> ResponseRepresentable {
    do {
      try drop.database?.driver.raw("CREATE TABLE \(cat) (" +
                                                        "cat_id integer primary key,\n" +
                                                        "cat_name text,\n" +
                                                        "cat_breed text);")
    }
    catch {
      return "Error in making kitty DB \(error)"
    }
    
    return "Making kittens"
  }
  
  func insertKitty(request: Request) throws -> ResponseRepresentable {
    
    guard
      let catID = request.json?["cat_id"]?.int,
      let catName = request.json?["cat_name"]?.string,
      let catBreed = request.json?["cat_breed"]?.string
    else {
        throw Abort.badRequest
    }
    
    return try JSON(node: drop.database?.driver.raw("INSERT INTO \(cat) VALUES (\(catID), '\(catName)', '\(catBreed)');"))
  }
  
  func deleteKittyDB(request: Request) -> ResponseRepresentable {
    do {
      try drop.database?.driver.raw("DROP TABLE \(cat)")
    }
    catch {
      return "Error in deleting kittyDB \(error)"
    }
    
    return "Deleted kittyDB"
  }
  
  func createDB() {
    do {
      try drop.database?.driver.raw("CREATE TABLE tasks (taskID integer PRIMARY KEY,\ntitle text);")
    }
    catch {
      print("Error making table \(error)")
    }
    
  }
  
}
