import PackageDescription

let package = Package(
    name: "Simple",
    dependencies: [
                      .Package(url: "https://github.com/PlanTeam/MongoKitten.git", majorVersion: 0, minor: 9),
                      .Package(url: "https://github.com/LoganWright/Genome.git", majorVersion: 3),
                      .Package(url: "https://github.com/qutheory/vapor.git", Version(0, 8, 0)),
                      ]
)
