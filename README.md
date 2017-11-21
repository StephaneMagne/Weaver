# BeaverDI

A dependency injection system based on meta programmation and annotations

# Annotate your classes

By adding annotations to your class, you can easily make `beaverdi` generate a bunch of injected dependencies for you.

- A service with injected dependencies

```swift
final class MyService: Injectable {
  let dependencies: DependencyResolver

  // beaverdi.inject(from: .self(scope: .graph))
  // api: APIProtocol
  
  // beaverdi.inject(from: .self(scope: .container))
  // router: RouterProtocol
  
  // beaverdi.inject(from: .self(scope: .weak))
  // session: SessionProtocol?
  
  // beaverdi.inject(from: .parent)
  // otherService: MyOtherServiceProtocol

  init(_ dependencies: DependencyContainer) {
    self.dependencies = dependencies
  }
  
  func doSomething() {
    otherService.doSomething(in: api).then { result in
      if let session = self.session {
        router.redirectSomewhereWeAreLoggedIn()
      } else {
        router.redirectSomewhereWeAreLoggedOut()
      }
    }
  }
}
```

- Code generated by beaverdi

```swift

final class MyServiceDependencies: DependencyResolver {
  override func registerDependencies(in store: DependencyStore) {
    store.register(APIProtocol.self, scope: .graph, builder: { _ in
      return API()
    })
    
    store.register(RouterProtocol.self, scope: .container, builder: { dependencies in
      return Router(dependencies)
    })
    
    store.register(SessionProtocol.self, scope: .weak, builder: { dependencies in 
      return Session(dependencies)
    })
  }
}

extension MyService {
  var api: APIProtocol {
    return dependencies.resolve(APIProtocol.self)
  }
  
  var session: SessionProtocol? {
    return dependencies.resolve(SessionProtocol.self)
  }
  
  var delegate: MyServiceDelegate {
    return dependencies.resolve(MyServiceDelegate.self)
  }
}
```
