Capitals Quiz
=============

JavaScript powered game for matching the correct capital with the given state/country.
Reference data (answer keys) is store in JSON format for simplicity as opposed to a dedicated database.

Currently only has United States available.
Makes use of the [StateFace](https://github.com/propublica/stateface) font.

Working version hosted at [capitalsquiz.me](http://capitalsquiz.me/).

TODO:
-----

* ~~Incorporate media queries for smaller screens.~~
* ~~Add scrollTop event to 'next set' button for smaller screens.~~
* ScrollTop doesn't work on mobile devices, investigate work-arounds.
* Bind 'quiz me again' link to a reusable function rather than just reload the page.
* Improve selection acknowledgement on smaller screens when a user picks a capital.
* Animate transition between 'quiz set' views.
* Incorporate Canada quiz.