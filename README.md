# Cinephile

This app shows a list of upcoming movies from The Movie Database website.
It also allows you to search for any movie.

# Setup Instructions

- Install Cocopods (https://cocoapods.org/)
- Using the terminal, `cd` to the root of the project and run `pod install`
- Open `Cinephile.xcworkspace` with XCode
- Build and run
- That is it! 👏🏻

# Third-party libraries

- SDWebImage (https://github.com/SDWebImage/SDWebImage)
    Used to asynchronously load and cache images on the app

- Ws (https://github.com/freshOS/ws)
    Used to communicate with the remote API

- Arrow (https://github.com/freshOS/Arrow)
    Used to map the JSON responses from the API into structs

- thenPromise (https://github.com/freshOS/then)
    Used to allow for cleaner asynchronous code and improved flow control, avoiding the clutter and possible problems of multiple closures

# Screenshots


![](screenshots/upcoming_movies.png?raw=true "Upcoming movies listing") ![](screenshots/movie_details.png?raw=true "Movie details") ![](screenshots/search.png?raw=true "Searching")

![](screenshots/landscape.png?raw=true "Landscape orientation")