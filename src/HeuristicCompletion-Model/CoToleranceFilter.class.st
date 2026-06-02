"
I let the user enter typos. I have a rate of acceptance. I use an edit distance to propose alternative.
"
Class {
	#name : 'CoToleranceFilter',
	#superclass : 'CoFilter',
	#instVars : [
		'decoree'
	],
	#classVars : [
		'MinimumTokenSize',
		'Rate'
	],
	#category : 'HeuristicCompletion-Model-Core',
	#package : 'HeuristicCompletion-Model',
	#tag : 'Core'
}

{ #category : 'algorithms' }
CoToleranceFilter class >> damerauLevenshteinDistanceBetween: source and: target maxDistance: maxDistance [

	| previousRow currentRow twoRowsBack minInRow cost insertion deletion substitution value |
	source = target ifTrue: [ ^ 0 ].

	previousRow := Array new: target size + 1.
	1 to: (target size + 1) do: [ :j |
		previousRow at: j put: j - 1 ].

	1 to: source size do: [ :i |
		currentRow := Array new: target size + 1.
		currentRow at: 1 put: i.
		minInRow := i.

		1 to: target size do: [ :j |
			cost := ((source at: i) = (target at: j))
				ifTrue: [ 0 ]
				ifFalse: [ 1 ].

			insertion := (currentRow at: j) + 1.
			deletion := (previousRow at: (j + 1)) + 1.
			substitution := (previousRow at: j) + cost.

			value := insertion min: deletion.
			value := value min: substitution.

			(i > 1 and: [ j > 1 and: [
				(source at: i) = (target at: (j - 1))
					and: [ (source at: (i - 1)) = (target at: j) ] ] ]) ifTrue: [
						twoRowsBack ifNotNil: [
							value := value min: ((twoRowsBack at: (j - 1)) + 1) ] ].

			currentRow at: (j + 1) put: value.
			minInRow := minInRow min: value ].

		minInRow > maxDistance ifTrue: [ ^ 0 ].
		twoRowsBack := previousRow.
		previousRow := currentRow ].

	^ (previousRow last <= maxDistance)
		ifTrue: [ previousRow last ]
		ifFalse: [ 0 ]

]

{ #category : 'default values' }
CoToleranceFilter class >> defaultMinimumTokenSize [

	^ 2

	
]

{ #category : 'default values' }
CoToleranceFilter class >> defaultRate [

	^ 0.75

	
]

{ #category : 'configuration' }
CoToleranceFilter class >> disable [

	Rate := -1
]

{ #category : 'configuration' }
CoToleranceFilter class >> enable [

	Rate := self defaultRate 
]

{ #category : 'configuration' }
CoToleranceFilter class >> enabled [

	^ Rate > 0.0
]

{ #category : 'class initialization' }
CoToleranceFilter class >> initialize [ 

	self reset
]

{ #category : 'configuration' }
CoToleranceFilter class >> minimumTokenSize [

	^ MinimumTokenSize
]

{ #category : 'configuration' }
CoToleranceFilter class >> minimumTokenSize: anInteger [ 

	MinimumTokenSize := (anInteger ifNil: [ self defaultMinimumTokenSize ]) max: 1
]

{ #category : 'configuration' }
CoToleranceFilter class >> rate [

	^ Rate
]

{ #category : 'configuration' }
CoToleranceFilter class >> rate: aNumber [ 

	| value |
	value := (aNumber ifNil: [ self defaultRate ]) asFloat.
	Rate := (value max: 0.0) min: 1.0
]

{ #category : 'class initialization' }
CoToleranceFilter class >> reset [ 

	Rate := self defaultRate.
	MinimumTokenSize := self defaultMinimumTokenSize
	
]

{ #category : 'algorithms' }
CoToleranceFilter class >> scoreForCandidate: aCandidateString token: aTokenString caseSensitive: aBoolean tolerance: aTolerance [
	"The closer the value is to 0, the better the match between the candidate and the token
	 Returns 0 if  * the candidate and the token don't start with the same caracter 
						* Token or the candidate is empty
						* The candidate starts exactly with the token
						* The tolerance is not enabled, or the token size does not exceed the minimum size
						* The keyword arity is not stable
	"

	| candidate token maxSize maxEdits distance |
	candidate := aCandidateString asString.
	token := aTokenString asString.

	token isEmpty ifTrue: [ ^ 0 ].
	candidate = token ifTrue: [ ^ 0 ].

	candidate := aBoolean
		             ifTrue: [ candidate ]
		             ifFalse: [ candidate asLowercase ].
	token := aBoolean
		         ifTrue: [ token ]
		         ifFalse: [ token asLowercase ].
	(candidate beginsWith: token) ifTrue: [ ^ 0 ].
	(self shouldTryFuzzyFor: token candidate: candidate tolerance: aTolerance) ifFalse: [ ^ 0 ].

	maxSize := token size max: candidate size.
	maxEdits := (aTolerance * maxSize) ceiling.
	maxEdits <= 0 ifTrue: [ ^ 0 ].


	distance := self damerauLevenshteinDistanceBetween: token and: candidate maxDistance: maxEdits.

	distance ifNil: [ ^ 0 ].
	^ distance asFloat / maxSize
]

{ #category : 'algorithms' }
CoToleranceFilter class >> shouldTryFuzzyFor: token candidate: candidate tolerance: aTolerance [
	" I verify if the fuzzy match is applicable or not
	  I return false if : 	* Tolerance is disabled
							 	* The Token or the candidate is empty
								* The token size does not exceeed the minimum token length
								* Thee keyword arity is not stable
								* The first caracter of the candidate and the token does not match
	  Otherwise I return true
	"

	| maxSize maxEdits |
	(self enabled not or: [ aTolerance <= 0.0 ]) ifTrue: [ ^ false ].
	token isEmpty ifTrue: [ ^ false ].
	candidate isEmpty ifTrue: [ ^ false ].
	token size < self minimumTokenSize ifTrue: [ ^ false ]. "Keep keyword arity stable"
	((token includes: $:) or: [ candidate includes: $: ]) ifTrue: [
		(token occurrencesOf: $:) = (candidate occurrencesOf: $:) ifFalse: [ ^ false ] ]. "Cheap guardrails to avoid noisy matches"
	token first = candidate first ifFalse: [ ^ false ].
	maxSize := token size max: candidate size.
	maxEdits := (aTolerance * maxSize) ceiling.
	^ (token size - candidate size) abs <= maxEdits
]

{ #category : 'testing' }
CoToleranceFilter >> accepts: aCandidate [
	^ (decoree accepts: aCandidate) or: [ self class enabled and: [ self fuzzyAccepts: aCandidate ] ]
]

{ #category : 'accessing' }
CoToleranceFilter >> completionString [

	^ decoree completionString
]

{ #category : 'testing' }
CoToleranceFilter >> decoree [

	^ decoree 
]

{ #category : 'testing' }
CoToleranceFilter >> decoree: aFilter [

	decoree := aFilter 
]

{ #category : 'testing' }
CoToleranceFilter >> fuzzyAccepts: aCandidate [

	^ (self fuzzyScoreFor: aCandidate) isZero not
]

{ #category : 'testing' }
CoToleranceFilter >> fuzzyScoreFor: aCandidate [

	^ self class scoreForCandidate: aCandidate contents
		token: decoree completionString
		caseSensitive: (decoree class = CoCaseSensitiveBeginsWithFilter)
		tolerance: Rate

]

{ #category : 'testing' }
CoToleranceFilter >> isCaseSensitive [

	^ decoree isCaseSensitive
]

{ #category : 'testing' }
CoToleranceFilter >> isLessNarrowThanCaseInsensitive: anotherFilter [

	^ decoree isLessNarrowThanCaseInsensitive: anotherFilter
]

{ #category : 'testing' }
CoToleranceFilter >> isLessNarrowThanCaseSensitive: anotherFilter [

	^ decoree isLessNarrowThanCaseSensitive: anotherFilter
]

{ #category : 'testing' }
CoToleranceFilter >> isLessNarrowThanNegation: anotherFilter [

	^ decoree isLessNarrowThanNegation: anotherFilter
]

{ #category : 'testing' }
CoToleranceFilter >> isMoreNarrowThan: anotherFilter [

	^ decoree isMoreNarrowThan: anotherFilter
]

{ #category : 'testing' }
CoToleranceFilter >> requiresFallbackEnumeration [
	"Checks whether fuzzy match is enabled or not"
	^ self class enabled and: [ decoree completionString size >= self class minimumTokenSize ]
]
