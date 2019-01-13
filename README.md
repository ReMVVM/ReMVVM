
# ReMVVM
 
*ReMVVM* is an application architecture concept, marriage of *Unidirectional Data Flow* (*Redux*) with *MVVM*. 

Redux + MVVM = ReMVVM 

# Motivation 

**Model-View-ViewModel** - is well known and widely used architecture on *iOS* platform. It is very simple, lightweight, doesn’t bring any boilerplate and works well with reactive programming (can be used without it of course). Working on the app that contain more than single view you will find couple of questions: 
* who is responsible to create View Model ? 
* how to pass parameters to View Model’s constructor or fabric ? 
* how to implement switching to the new view ? Where to make view change and how to pass View Model to it ?

Of course you can find couple patterns to solve that such as coordinator but surprisingly easy you can follow the wrong path.

**Unidirectional Data Flow (UDF)** - the main concept behind is the application state is immutable and can be changed only in one place in the app (*Store*) and only by predictable plain functions (in *Reducers*) ie. State + Action =  NewState. The most popular implementation of that concept is JavaScript library called *Redux*. The first and most popular swift’s implementation is *ReSwift* by Benjamin Encz. If you are not familiar with that architecture I strongly recommend to look on Benjamin’s [presentation](https://academy.realm.io/posts/benji-encz-unidirectional-data-flow-swift/) and look into [ReSwift](https://github.com/ReSwift/ReSwift) documentation. 

You can find an easy example of *Redux* implementation with incrementing and decrementing single integer value. Let’s imagine you have application with 15-30 screens, all with complicated view structure and communication with backend API. It will bring complicated *Application State*, a lot of *Reducers* and dozens or even hundreds of *Actions* for the state changes. 

But… what about making a mix of two architectures ? Can we implement “global” app state by *Unidirectional Data Flow* and use *MVVM* pattern for each screen in the app with all benefits it has ? We can and it is what *ReMVVM* was made for.

# Components 
In *ReMVVM* we can divide components on two groups related with *Unidirectional Data Flow* and *MVVM*

![](/images/ReMVVM_architecture_components.png) 

## Unidirectional Data Flow: 
**Store** - contains your application state that can be modified only by dispatching an action. Every state change is notified to every store Subscriber.

**StoreState** - it’s immutable data structure that holds your application data. In *ReMVVM* it has to provide *ViewModelFactory* that will be used for creating View Models for your view(s).

**StoreAction** - describes state change and is handled by corresponding *Reducer*. 

**Middleware** - mechanism for enhance action’s dispatch functionality. It is usually used for simplify asynchronous dispatch and ‘side effects’ if required.

**Reducer** - provides pure function that returns new state based on current state and the action. 

**_Note:_** *There is a small difference between Redux implementation and ReMVVM. In Redux one reducer can handle any type of action. Because of that we can see a lot of switch blocks inside reducers and it’s not clear where the action is finally handled. In ReMVVM reducer can handle exactly one type of the action. Action handling is separated into different reducers what makes the code more clean.* 

## MVVM:
**View Model** - is designed to store and manage UI related data for the view

**View Model Provider** - provides View Model(s) for the context (View)

**View Model Factory** - creates View Model instances

*View Model* provided by *View Model Provider* lives as long as the context which was created for. For more detail please look at [MVVM library](https://github.com/dgrzeszczak/MVVM) that is a part of ReMVVM.

# Example

We will build application containing two screens. First the Login screen where user may enter his first and second name. And second greeting screen that presents values entered on previous screen with logout button.

![](/images/LoginViewController_screenshot.png) |    | ![](/images/GreetingsViewController_screenshot.png)
| - | --- | - |

**_Note:_** *We use RxSwift/RxCocoa in the example because it's great fit to MVVM architecture but please remember there is no need to use any Reactive framework with ReMVVM and there is no dependency to Rx libarary.* 

First we need a struct for State with the data for our app. It contain data for logged in ```User``` and it also have to provide factory for our View Models. 

```swift
struct AppState: StoreState {
    let factory: ViewModelFactory

    let user: User?
}

struct User {
    let firstName: String
    let lastName: String
}
```

Let's create view models for our screens. ```LoginViewModel``` implements two protocols ```StoreSubscriber``` and ```Initializable```. 

```Initializable``` is used by ```InitializableViewModelFactory``` and ```CompositeViewModelFactory``` for creating View Models by using default/empty constructor. So it means you don't need to provide factory method for it. 

```StoreSubscriber``` means that your view model will be automatically notified on any state changes in store. Here it's used for clearing first and second name values when user logs out.

```swift
final class LoginViewModel: StoreSubscriber, Initializable {
    let firstName = BehaviorSubject(value: "")
    let lastName = BehaviorSubject(value: "")

    func didChange(state: AppState, oldState: AppState) {
        if oldState.user != nil && state.user == nil {
            // reset values on logout
            firstName.onNext("")
            lastName.onNext("")
        }
    }
}
```

```swift
struct GreetingsViewModel {
    let messageLabel: Observable<String>

    init(with user: User) {
        messageLabel = .just("Hello \(user.firstName) \(user.lastName) <3")
    }
}
```

For the simplicyty of the example we will use one factory for all states. Other solution is to use seperate factories for each screen or module in the app. As alredy mentioned ```CompositeViewModelFactory``` by defauts are able to create ```Initializable``` View Models so we only need to add factory for ```GreetingsViewModel```. We will use helper method ```add()``` and it will look like:

```swift
 
let factory = CompositeViewModelFactory()
factory.add { _ -> GreetingsViewModel? in
    guard let user = store.state.user else { return nil }
    return GreetingsViewModel(with: user)
}
```

Ok so that's all regarding *MVVM* part. Let's see how to implement *Unidirectional Data Flow* part. We will have two actions:

 ```swift
struct LoginAction: StoreAction {
    let firstName: String
    let lastName: String
}

struct LogoutAction: StoreAction { }
```

And two reducers for each of them: 

```swift
struct LoginReducer: Reducer {
    static func reduce(state: AppState, with action: LoginAction) -> AppState {
        let user = User(firstName: action.firstName, lastName: action.lastName)
        return AppState(factory: state.factory, user: user)
    }
}
```

```swift
struct LogoutReducer: Reducer {
    static func reduce(state: AppState, with action: LogoutAction) -> AppState {
        return AppState(factory: state.factory, user: nil)
    }
}

```

We can initialize *ReMVVM* like that: 

```swift

let store = Store(with: initialState, middleware: middleware)
store.register(reducer: LoginReducer.self)
store.register(reducer: LogoutReducer.self)

ReMVVM.Config.initialize(with: store)
```

Now we can write ours view controllers. Please notice ```ReMVVMDriven``` protocol which gives us ```ReMVVM``` object for getting view models and dispatching actions. 

 ```swift
class LoginViewController: UIViewController, ReMVVMDriven {

    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!
    @IBOutlet private var loginButton: UIButton!
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        // get view model from remvvm
        guard let viewModel: LoginViewModel = remvvm.viewModel(for: self) else { return }

        // bind view model to view
        viewModel.firstName.bind(to: firstNameTextField.rx.text).disposed(by: disposeBag)
        viewModel.lastName.bind(to: lastNameTextField.rx.text).disposed(by: disposeBag)

        // bind view to view model
        firstNameTextField.rx.text.map { $0 ?? "" }.bind(to: viewModel.firstName).disposed(by: disposeBag)
        lastNameTextField.rx.text.map { $0 ?? "" }.bind(to: viewModel.lastName).disposed(by: disposeBag)

        // handle login button tap
        // without rx: self.remvvm.dispatch(action: LoginAction(firstName: , lastName:))
        loginButton.rx.tap
            .withLatestFrom(Observable.combineLatest(viewModel.firstName, viewModel.lastName))
            .map(LoginAction.init)
            .bind(to: remvvm)
            .disposed(by: disposeBag)
    }
}
```

 ```swift
class GreetingsViewController: UIViewController, ReMVVMDriven {

    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!

    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        // handle logout button tap
        // without Rx: self.remvvm.dispatch(action: LogoutAction())
        logoutButton.rx.tap
            .map { LogoutAction() }
            .bind(to: remvvm)
            .disposed(by: disposeBag)

        // get view model from remvvm and bind to the view
        guard let viewModel: GreetingsViewModel = remvvm.viewModel(for: self) else { return }
        viewModel.messageLabel.bind(to: messageLabel.rx.text).disposed(by: disposeBag)
    }
}
```

The last concept whould like to show is how we can handle navigation in the app using *ReMVVM*. We could have add navigation changes after dispatching each action in UIViewControllers but please notice we didn't handle it there. So where it is ? It's implemented in the last component called *Middleware*. It's mechanism that can change dispatch of the action and is offten used for asynchronous requests and side effect (in our case side effect of  changing the state is displaying new screen of the app). 

*Middleware* is a stack of objects and each action dispatched in the store is passed thorugh each element of that stack. It's done by calling next() method from dispatcher. On the end action is reduced in corresponding reducer and the state in the store is changed. After state is changed the completion block from ```next()``` is called in backward order. 

In middleware you can also dispatch completly new action by calling ```dispatcher.dispatch(action:)```. If you don't call next() method the action's dispatch will break and as a result reducer will not be called and state will not change. It can be intentional in some cases for example when you need to download data asynchronously first.

Let's back to our example and define really simple ```UIState``` that give us possibility to navigate through the app. 

```swift
struct UIState {

    private let rootViewController: UIViewController

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func showModal(controller: UIViewController) {
        rootViewController.present(controller, animated: true, completion: nil)
    }

    func dismissModal() {
        rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
```

And then we can define our middlewares.

```swift

struct LoginMiddleware: Middleware {
    let uiState: UIState

    func applyMiddleware(for state: AppState, action: LoginAction, dispatcher: Dispatcher<LoginAction, AppState>) {

        // here you can do something asynchronously - like download user data
        // ....

        dispatcher.next { state in
            // this closure is called after action is handled by reducer - can be used for side effects like that ;)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LogoutViewController")
            self.uiState.showModal(controller: controller)
        }
    }
}
```

```swift
struct LogoutMiddleware: Middleware {
    let uiState: UIState

    func applyMiddleware(for state: AppState, action: LogoutAction, dispatcher: Dispatcher<LogoutAction, AppState>) {

        dispatcher.next { state in
            self.uiState.dismissModal()
        }
    }
}
```

The biggest advantage is that UIViewControllers know nothing about each other. They are not connected at all, you can easily change the flow of the application without touching UIViewControllers. 

# Summary

The big advantages of the concept of *ReMVVM* architecture is great separation between layers. It's clear where to store model data, who and where creates view model and how it's passed to the view. It takes the biggest advantages of two different architectures and makes the code readable without introducing any boilerplate.
