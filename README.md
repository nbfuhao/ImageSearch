# ImageSearch
A simple image search API using Google Image Search API. A good practice of using RESTful APIs and iOS basic knowledge.

TODO:

- [X] Adjust aspect ratio for image so they are not square.
- [X] Add loading indicators.
- [X] Split history management logic. 
- [X] Eliminate race conditions by cancelling existing network request.
- [X] Checking if the search results are already displayed requires traversing the view hierarchy to see if the view is a descendant - inefficient. 
- [X] Just inserting new cells instead of calling reload function. 
- [X] Remove "Out of date" iOS development practices - objectForKey:, xibs instead of storyboards, sizeToFit instead of auto layout. 
- [X] UI assumes 320 width (remove result button is not right-aligned on iPhone 6).
