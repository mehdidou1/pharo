"
I represent a completion entry that is management by a ECModel and shown in the ECMenuMorph as a menu entry.

Each of my subclass will represent a specific kind of entity. For example a globalvariable, self...
"
Class {
	#name : 'CoEntry',
	#superclass : 'Object',
	#traits : 'TProperties',
	#classTraits : 'TProperties classTrait',
	#classVars : [
		'OriginDisplayed',
		'SpaceAfterCompletion'
	],
	#category : 'NECompletion-Model',
	#package : 'NECompletion',
	#tag : 'Model'
}

{ #category : 'instance creation' }
CoEntry class >> contents: aString node: aNode [
	self properties.
	self propertyAt: #description put: nil. 
	self propertyAt: #displayedContents put: nil.
	self propertyAt: #fetcherName put: nil.
	
	^ self new contents: aString node: aNode
]

{ #category : 'class initialization' }
CoEntry class >> initialize [

	CoEntry deprecatedAliases: { #NECEntry }.
	CoGlobalEntry deprecatedAliases: {#NECGlobalEntry}.
CoSelectorEntry deprecatedAliases: {#NECSelectorEntry}.
CoEntry deprecatedAliases: {#NECEntry}.
CoTypingVisitor deprecatedAliases: {#NECTypingVisitor}.
CoLocalEntry deprecatedAliases: {#NECLocalEntry}.
CoClassVarEntry deprecatedAliases: {#NECClassVarEntry}.
CoSymbolEntry deprecatedAliases: {#NECSymbolEntry}.
CoCompletionSorter deprecatedAliases: {#NECNECmpletionSorter}.
CoEntryDescription deprecatedAliases: {#NECEntryDescription}.
CoInstVarEntry deprecatedAliases: {#NECInstVarEntry}.
CoVariableEntry deprecatedAliases: {#NECVariableEntry}.
CoSnippetEntry deprecatedAliases: {#NECSnippetEntry}.
CoCompletionItemSelected deprecatedAliases: {#NECNECmpletionItemSelected}.
CoAdHocUsageTracker deprecatedAliases: {#NECAdHocUsageTracker}.
CoSpecialVariableEntry deprecatedAliases: {#NECSpecialVariableEntry}.
]

{ #category : 'accessing' }
CoEntry class >> originDisplayed: aBoolean [

	OriginDisplayed := aBoolean
]

{ #category : 'accessing' }
CoEntry class >> spaceAfterCompletion [

	^ SpaceAfterCompletion
]

{ #category : 'accessing' }
CoEntry class >> spaceAfterCompletion: aBoolean [

	SpaceAfterCompletion := aBoolean
]

{ #category : 'operations' }
CoEntry >> <= aECEntry [
	^ self propertyAt: #contents <= aECEntry contents
]

{ #category : 'operations' }
CoEntry >> activateOn: aCompletionContext [

	| entryContents |
	"Log the usage"
	CoAdHocUsageTracker incrementUsageFor: self contents.
	
	"By default insert the contents of the entry instead of the token in the text editor"
	entryContents := self contents asSymbol separateKeywords.
	entryContents := (self class spaceAfterCompletion
				ifTrue: [ entryContents , ' ' ]
				ifFalse: [ entryContents ]).
	aCompletionContext replaceTokenInEditorWith: entryContents
]

{ #category : 'matching' }
CoEntry >> beginsWith: aString [

	^ self contents beginsWith: aString
]

{ #category : 'private' }
CoEntry >> browseCompletionItem [
	self subclassResponsibility
]

{ #category : 'accessing' }
CoEntry >> contents [
	^ self propertyAt: #contents
]

{ #category : 'accessing' }
CoEntry >> contents: aString [
	self propertyAt: #contents put: aString
]

{ #category : 'accessing' }
CoEntry >> contents: aString node: aNode [

	self propertyAt: #contents put: aString.
	self propertyAt: #node put: aNode.
]

{ #category : 'detail information' }
CoEntry >> createDescription [
	
	^ CoEntryDescription label: self contents
]

{ #category : 'operations' }
CoEntry >> description [

	self propertyAt: #description 
		ifPresent: [ ^self propertyAt: #description ] 
		ifAbsent: [ self propertyAt: #description put: self createDescription.
			^ self propertyAt: #description
			 ].
]

{ #category : 'accessing' }
CoEntry >> displayedContents [
	"displayedContents offers the possibility to display a different information in the menu than the one returned when the user select an entry. By default displayContents is delegating to contents."

	 self propertyAt: #displayedContents 
		ifPresent: [ ^self propertyAt: #displayedContents ] 
		ifAbsent: [ ^self propertyAt: #contents. ].
]

{ #category : 'accessing' }
CoEntry >> displayedContents: aString [ 
	"displayedContents offers the possibility to display a different information in the menu than the one returned when the user select an entry. By default displayContents is delegating to contents."

	self propertyAt: #displayedContents put: aString
]

{ #category : 'accessing' }
CoEntry >> fetcher [
	self 
		deprecated: 'Use fetcherName instead' 
		transformWith: '`@rec fetcher ' -> '`@rec fetcherName'.
	^ self propertyAt: #fetcherName
]

{ #category : 'accessing' }
CoEntry >> fetcher: anObject [
	self 
		deprecated: 'Use fetcherName: instead' 
		transformWith: '`@rec fetcher: `@arg' -> '`@rec fetcherName: `@arg class name'.
	self fetcherName: anObject class name
]

{ #category : 'accessing' }
CoEntry >> fetcherName [
	
	^ self propertyAt: #fetcherName
]

{ #category : 'accessing' }
CoEntry >> fetcherName: aString [
	
	self propertyAt: #fetcherName put: aString
]

{ #category : 'accessing' }
CoEntry >> hightlightSymbol [
	^nil
]

{ #category : 'accessing' }
CoEntry >> label [ 

	| typeString |
	typeString := self rawLabel.
	self originDisplayed ifTrue: [ typeString := typeString , ' from: ', self fetcher asString ].
	^ typeString
]

{ #category : 'accessing' }
CoEntry >> node [

	^ self propertyAt: #node
]

{ #category : 'accessing' }
CoEntry >> node: anObject [

	^ self propertyAt: #node put: anObject
]

{ #category : 'accessing' }
CoEntry >> originDisplayed [

	^ OriginDisplayed ifNil: [ OriginDisplayed := false ]
]

{ #category : 'printing' }
CoEntry >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: (self propertyAt: #contents);
		nextPut: $,.

	self hightlightSymbol ifNotNil: [ aStream nextPutAll: self hightlightSymbol ].

	aStream nextPut: $)
]

{ #category : 'accessing' }
CoEntry >> rawLabel [
	^ 'unknown'
]
