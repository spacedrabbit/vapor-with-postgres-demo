import Vapor
import HTTP
import VaporPostgreSQL

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider.self)
let taskController = TaskViewController(drop: drop)


drop.run()
