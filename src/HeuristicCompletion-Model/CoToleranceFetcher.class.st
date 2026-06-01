"
I enhance the results by providing fuzzy candidates. 
I use the decorator design pattern to preserve the current implementation
"
Class {
	#name : 'CoToleranceFetcher',
	#superclass : 'CoFetcherDecorator',
	#category : 'HeuristicCompletion-Model-Core',
	#package : 'HeuristicCompletion-Model',
	#tag : 'Core'
}

{ #category : 'enumerating' }
CoToleranceFetcher >> filteredEntriesDo: aBlock [

	decoree filteredEntriesDo: aBlock.
	filter requiresFallbackEnumeration ifTrue: [
		decoree fuzzyEntriesDo: [ :entry | (filter fuzzyAccepts: entry) ifTrue: [ aBlock value: entry ] ] ]
]

{ #category : 'initialization' }
CoToleranceFetcher >> initialize [ 
	super initialize 
]

{ #category : 'initialization' }
CoToleranceFetcher >> reset [ 
	super reset
]
