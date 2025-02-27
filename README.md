In order to run the app you will need to have a token and a key from 
(https://developers.themoviedb.org/3/getting-started/introduction)

The keys should be saved inside the APIKeys.xcconfig file in the form:
API_TOKEN = your_token
API_KEY = your key
No quotes needed

App is trying to conform to the MVVM architectural pattern using a Router.
The list of the movies is populated using UIKit, while the details implementation are in SwiftUI.
Combine also is used in some places to give a reactive approach by observing propery changes.
