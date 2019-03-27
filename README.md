# FollowerDM
### A Sample App to DM with a Twitter User's Followers

## Scenario & Author
Scenario A by Jeffrey Bergier

## App Requirements
- On launch, display a list of followers of a twitter user
	- The twitter user is hardcoded
	- This list uses the real Twitter API
		- Using `applicationOnly` authentication
- Tapping on a user will show a Direct Message chat screen
	- This screen uses fake data
	- The user is able to submit their own messages
	- This screen simulates a chat happening in real time

## Development Strategies
Because this application is designed to be understood by junior iOS developers, it uses standard Apple practices:

- Storyboards
- Autolayout
- Segues
- MVC

That said, the application also makes a best effort reduce common problems associated with standard Apple practices by doing the following:

- Avoid Massive View Controller
- Use protocols to allow test data to be used
- Result type to allow error handling with Asynchronous API

## Points of Interest
Below are listed some parts of the project that a junior developer should investigate.

### Asset Catalogs - Using Slicing
- The chat bubble images were provided as part of the requirements. If the images were used without modification, then the corners of the chat bubbles would appear stretched out depending on the size and shape of the message.
	- Slices are a feature in Asset Catalog that allow the developer to specify which parts of the image can't be stretched and which parts can.
	- Amazingly, the slices feature actually does this automatically once slicing is turned on.
- Investigate the chat bubble images to see the slicing.

### View Controllers
- `TwitterFollowerTableViewController`
	- This is the launch view controller that loads the list of followers.
	- This view controller handles the segue when the user taps on one of the followers.
- `TwitterDirectMessageViewController`
	- This view controller manages the text field where the user can enter text.
	- This view controller also contains `TwitterDirectMessageTableViewController` via view controller containment.
- `TwitterDirectMessageTableViewController`
	- Displays the list of chat messages.
	- Validates and posts messages that are typed into `TwitterDirectMessageViewController` by the user.
	
### Protocols
- `TwitterAuthTokenControllerProtocol`
	- Specifies API for authenticating with Twitter API.
	- There are 2 implementations of this protocol in the App.
		- `FakeData_TwitterAuthTokenController` - provides a fake auth token.
			- This implementation is not currently used, but can be swapped in by changing `Line 17` of `TwitterFollowerTableViewController.swift`
		- `SimpleTwitterAuthTokenController` - provides a simple implementation that uses the Twitter API.
			 - Obtains an `applicationOnly` bearer token and store it in memory. 
			 - The token is not persisted across launches but this would be easy to add.
- `TwitterFollowerRetrieverControllerProtocol`
	- Specifies the API for retrieving the followers of a specific user.
	- There are 2 implementations of this protocol in the App.
		- `FakeData_TwitterFollowerRetrieverController` - provides fake followers that can be displayed in the list.
			- This implementation is not currently used, but can be swapped in by changing `Line 18` of `TwitterFollowerTableViewController.swift`
		- `SimpleTwitterFollowerRetrieverController` - provides a simple implementation that uses the Twitter API.
			- Only provides the first 200 followers.
			- Has no concept of pagination / infinite scrolling.
- `TwitterDirectMessageControllerProtocol`
	- Specifies the API for retreiving direct messages, sending new messages, and responding to change as new messages come in.
	- There is 1 implementation of this protocol in the App.
		- `FakeData_TwitterDirectMessageController` - provides a simulated real-time chat experience.
			- Generates a new message from the remote user every 5 seconds.
			- Simulates 3 second upload time when user submits a new message.
			- Echoes user's last message as specified in the requirements.
			
### Storyboard
- The Direct Message scene has two items of note
	- The UITextField and its gray background view have fairly sophisticated autolayout.
		- This is required because of iPhone X and safe areas.
		- The gray background area needs to stretch beyond the safe area while the UITextField needs to stay inside of the safe area.
		- They both need to move up and down in response to keyboard changes.
	- Container Views with Embed Segues
		- Storyboards make view controller containment very easy.
		- The `TwitterDirectMessageViewController` class has a lot of work to do just managing the UITextField.
		- Splitting the table view responsibilities to a different controller helps us to avoid Massive View Controller.
		
### Small Things
- Dynamic Text
	- There is no code written specifically for it, but all the labels, textfields, and autolayout supports changing font sizes with dynamic text.
- `KeyboardAnimator`
	- An object that wraps up the complexities of the keyboard appearing, disappearing, and changing size.
	- It provides an animation block that gets executed when the keyboard is changing.
	- The animation matches the duration and curve of the keyboard animation.
- Result type
	- There is a very simple implementation of a result type.
	- The result type provides something akin to Swift's `throws` syntax for asynchronous operations.

