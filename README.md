# ImageSearch
A simple image search API using Google Image Search API. A good practice of using RESTful APIs and iOS basic knowledge.

TODO:

- Adjust aspect ratio for image so they are not square.
- ~~Add loading indicators~~.
- ~~Split history management logic~~. 
- Eliminate race conditions by cancelling existing network request.
- Checking if the search results are already displayed requires traversing the view hierarchy to see if the view is a descendant - inefficient. 
- ~~Just inserting new cells instead of calling reload function~~. 
- Remove "Out of date" iOS development practices ~~- objectForKey:~~, xibs instead of storyboards, sizeToFit instead of auto layout. 
- UI assumes 320 width (remove result button is not right-aligned on iPhone 6).
