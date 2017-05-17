import Vapor

let drop = Droplet()

drop.get("welcome") { request in
  return "Welcome, to this most glorious Heroku deployment"
}

drop.run()
