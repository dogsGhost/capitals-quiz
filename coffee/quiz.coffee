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
		@$quizForm = $ '#quiz-form'
		@answerKey = []
		@userAnswers = []
		@numberAnswered = 0
		@totalQuestions = 0
		@invalidForm = false
		# This determines how many questions a user sees at one time.
		@qSetLength = 3

	bindQuizList: ->
		$('#quizList').on 'click', 'a', @determineQuiz

	determineQuiz: (e) ->
		e.preventDefault()
		if @.id is 'usa'
			cQ.createAnswerKey()
			cQ.loadUsaQuiz()

	createAnswerKey: ->
		# Randomize the key to be used for this quiz.
		newBaseKey = @shuffle statesAnswerKey
		for state in newBaseKey
			state.cities = @shuffle state.cities
			state.cities = state.cities.splice 2, 2
			state.cities.push state.capital
			state.cities = @shuffle state.cities
			state.letter = statesLetterKey[state.abbr]
		@answerKey = newBaseKey
		@totalQuestions = @answerKey.length

	loadUsaQuiz: ->
		# Remove everything except the form.
		qC = @$quizForm.detach()
		$('.container').empty().append qC

		# call another func to create our html from templates
		html = cQ.createQuestionSet()

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
			$('body').scrollTop(0)

			# Check if they've finished then show next set or show results.
			if cQ.numberAnswered >= cQ.totalQuestions then cQ.showResults() else cQ.showNextSet()

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
		$('.container').html html

		# Bind new game.
		###
		TODO - NOT THE BEST WAY TO DO THIS
		###
		$('.btn--new-game').on 'click', -> location.reload()

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

cQ.init()