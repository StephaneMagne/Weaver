/// This file is generated by Weaver 0.12.1
/// DO NOT EDIT!
// MARK: - FooTest17
protocol FooTest17InputDependencyResolver {
    var fii: FiiTest17 { get }
}
protocol FooTest17DependencyResolver {
    var fee: FeeTest17 { get }
    var fii: FiiTest17 { get }
    var fuu: FuuTest17 { get }
}
final class FooTest17DependencyContainer: FooTest17DependencyResolver {
    let fee: FeeTest17
    let fii: FiiTest17
    private var _fuu: FuuTest17?
    var fuu: FuuTest17 {
        if let value = _fuu { return value }
        let value = FuuTest17()
        _fuu = value
        return value
    }
    init(injecting dependencies: FooTest17InputDependencyResolver, fee: FeeTest17) {
        self.fee = fee
        fii = dependencies.fii
        _ = fuu
    }
}
final class FooTest17ShimDependencyContainer: FooTest17InputDependencyResolver {
    let fii: FiiTest17
    init(fii: FiiTest17) {
        self.fii = fii
    }
}
extension FooTest17 {
    public convenience init(fii: FiiTest17, fee: FeeTest17) {
        let shim = FooTest17ShimDependencyContainer(fii: fii)
        let dependencies = FooTest17DependencyContainer(injecting: shim, fee: fee)
        self.init(injecting: dependencies)
    }
}
