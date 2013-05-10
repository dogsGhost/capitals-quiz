###
* @fileOverview This file makes our quiz work.
* @author David Wilhelm
###

cQ =
	init: ->
		@cacheVariables()
		@bindQuizList()

	cacheVariables: ->
		@quizFormTemplate = Handlebars.compile $('#quiz-form-template').html()
		@resultsTemplate = Handlebars.compile $('#results-template').html()
		@$container = $ '.container'
		@$initContent = []
		@$quizForm = $ '#quiz-form'
		@answerKey = []
		@userAnswers = []
		@numberAnswered = 0
		@totalQuestions = 0
		@invalidForm = false
		# This determines how many questions a user sees at one time.
		@qSetLength = 3
		return

	bindQuizList: ->
		$('#quizList').on 'click', 'a', @determineQuiz

	determineQuiz: (e) ->
		e.preventDefault()
		if @.id is 'usa'
			$.getJSON 'js/statesAnswerKey.json', cQ.createAnswerKey
		else if @.id is 'canada'
			false

	createAnswerKey: (json) ->
		# Randomize the key to be used for this quiz.
		newBaseKey = cQ.shuffle json	
		for state in newBaseKey
			state.cities = cQ.shuffle state.cities
			state.cities = state.cities.splice 2, 2
			state.cities.push state.capital
			state.cities = cQ.shuffle state.cities

		cQ.answerKey = newBaseKey
		cQ.totalQuestions = cQ.answerKey.length
		cQ.loadUsaQuiz()

	loadUsaQuiz: ->
		# Remove everything except the form.
		@$initContent = @$container.children().detach()
		@$container.append @$initContent[3]

		# Create our html from templates.
		html = @createQuestionSet()

		# Bind form submit
		@$quizForm.on 'submit', @processForm

		# Populate the form then show it.
		@$quizForm
			.find('div')
				.html(html)
				.end()
			.show()

	createQuestionSet: ->
		# Create our object to pass to the templates.
		set =
			states: @answerKey.slice @numberAnswered, @numberAnswered + @qSetLength
			answered: @numberAnswered
			total: @totalQuestions
			percentage: "#{String Math.round (@numberAnswered / @totalQuestions * 100)}%"
		
		# Generate html to be output.
		@quizFormTemplate set

	processForm: (e) ->
		# Validate form.
		# Store values and increment counters.
		# Decide what view to generate next.
		e.preventDefault()

		data = $(@).serializeArray()

		cQ.validateForm data
		if not cQ.invalidForm
			for item in data
				cQ.userAnswers.push item
			cQ.numberAnswered += cQ.qSetLength

			# Check if they've finished then show next set or show results.
			if cQ.numberAnswered >= cQ.totalQuestions then cQ.showResults() else cQ.showNextSet()
			cQ.toTop()

	validateForm: (arr) ->
		@invalidForm = false
		errorMsg = "<div class='question__no-answer'>
      <p>Please select a capital for this state.</p>
      </div>"

		$(".question__no-answer").remove()
		for item in arr
			if not item.value
				$(".question--#{item.name}").prepend errorMsg
				@invalidForm = true
		return

	showNextSet: ->
		html = @createQuestionSet()
		
		# Populate the form with new questions.
		@$quizForm
			.find('div')
				.html(html)
				
		# If this is the last set of questions.
		if cQ.numberAnswered >= (cQ.totalQuestions - cQ.qSetLength)
			@.$quizForm.find('input[type=submit]').val 'View Results \u27A1'

	showResults: ->
		# Check userAnswers vs answerKey.
		results = 
			total: @totalQuestions
			wrong: []

		for answer in @userAnswers
			for state in @answerKey
				if answer.name is state.abbr
					if answer.value isnt state.capital
						results.wrong.push state
						break

		results.correct = results.total - results.wrong.length
		results.score = "#{String Math.round (results.correct / results.total * 100)}%"

		# Generate results template.
		html = @resultsTemplate results

		# Change the view.
		@$quizForm
			.find('div')
				.empty()
				.end()
			.remove()
		@$container.html html

		# Bind new game.
		#not the best way to do this
		$('.btn--new-game').on 'click', -> location.reload()

	###
	This is what will load the original content back in, as opposed to a page reload.
	loadInitView: ->
		cQ.$container.empty().append cQ.$initContent
	###

	shuffle: (arr) ->
		# Perform the Fisher-Yates shuffle on an array.
	  i  = arr.length
	  return false if i is 0
	  while --i
	    j = Math.floor Math.random() * (i + 1)
	    tempi = arr[i]
	    tempj = arr[j]
	    arr[i] = tempj
	    arr[j] = tempi
	  arr

	toTop: () ->
		# Auto-scrollTop on mobile seems to require userAgent sniffing... bummer.
		if navigator.userAgent.match(/(iPod|iPhone|iPad|Android)/)
			window.scroll 0, 0
		else
		  $('html, body').animate
		  	scrollTop: 0
		  , 600

cQ.init()