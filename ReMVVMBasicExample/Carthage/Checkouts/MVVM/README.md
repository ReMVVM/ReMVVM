
*MVVM* framework is swift library inspired by *ViewModel* from Android Architecture components. I strongly recommend to look at [Android docs](https://developer.android.com/topic/libraries/architecture/viewmodel).

Working on *Model-View-ViewModel* architecture you can ask the question where you should instantiate *View Model* and how to pass it to the *View* (ie. ```UIViewController```). With *MVVM* framework you will use factories to create View Models. You can prepare your custom parametrized factory or use the default one ```InitializableViewModelFactory``` which works on ```Initializable``` ViewModels. 
```swift
class MyViewModel: Initializable { 
    required init() { }
}
```
In your ViewController you can instantiate it by calling
```swift
class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad() 
        let vm: MyViewModel? = ViewModelProviders.provider(for: self).get()
    }
}
```

## Lifecycle

*ViewModel* is created for specific contexts (*ViewControllers*) and live as long as the context (when context is deallocated, *ViewModel* will be  deallocated automatically). 

*View Model* is created by the factory when you call ```provider.get()``` method first time. You have to keep in mind all *View Models* are "cached" for specific context. It means that when you get the same type of View Model for the same context again it will return cached View Model, not a new one (eg. it can be useful for sharing data between views). 

From time to time you may need to re-create *Viewm Model(s)* for the context. You can clear the context calling  ```.clear()``` method from ```ViewModelStore``` but you have to know that all *View Models* will be removed for that context.

## Custom factories

When you need custom factory (eg. parameterized init for *ViewModel*) you can prepare it by implementing ```ViewModelFactory``` protocol.
```swift

struct MyViewModel { }

struct MySecondViewModel { }

struct ParamViewModel {
    let intParam: Int
}

struct MyViewModelFactory: ViewModelFactory {
    func create<VM>() -> VM? {
        switch VM.self {
        case is MyViewModel.Type: return MyViewModel() as? VM
        case is MySecondViewModel.Type: return MySecondViewModel() as? VM
        case is ParamViewModel.Type: return ParamViewModel(intParam: 3) as? VM
        default: return nil
        }
    }
}
```

and then you can use it like that:
```swift
var provider = ViewModelProviders.provider(for: controller, with: MyViewModelFactory())
guard let viewModel: MyViewModel = provider.get() else { return }
```

Another way to make custom factory is to use helpers classes that use closures to create *View Model* ```SingleViewModelFactory``` or ```CompositeViewModelFactory``` eg:

```swift
let singleFactory = SingleViewModelFactory { ParamViewModel(intParam: 3) }

var compositeFactory = CompositeViewModelFactory()
compositeFactory.add { MyViewModel() }
compositeFactory.add { MySecondViewModel() }
compositeFactory.add { ParamViewModel(intParam: 3) }
```

## More "complicated" factory example with RX ;)
```swift
final class FindViewModelFactory: ViewModelFactory {

    private let disposeBag = DisposeBag()
    private var factory = CompositeViewModelFactory()

    private lazy var findViewModel: FindViewModel = {
        return FindViewModel()
    }()

    init() {
        factory.add { [unowned self] in self.findViewModel }
        factory.add { [unowned self] in self.createSearchGlobalViewModel() }
        factory.add { BrandListViewModel(fetcher: ProductsWireframe.brandsFetcher) }
        factory.add { ProductCategoryListViewModel() }
        factory.add { ServiceCategoryListViewModel() }

    }

    private func createSearchGlobalViewModel() -> SearchGlobalViewModel {
        let searchGlobalViewModel = SearchGlobalViewModel()
        findViewModel.searchPredicate.asObservable().bind(to: searchGlobalViewModel.searchPredicate).disposed(by: disposeBag)
        return searchGlobalViewModel
    }

    func create<VM>() -> VM? {
        return factory.create()
    }
}
```
