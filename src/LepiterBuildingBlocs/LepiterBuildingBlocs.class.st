Class {
	#name : #LepiterBuildingBlocs,
	#superclass : #BlElement,
	#instVars : [
		'snippet',
		'coder',
		'coderViewModel',
		'snippetViewModel',
		'snippetElement'
	],
	#category : #LepiterBuildingBlocs
}

{ #category : #accessing }
LepiterBuildingBlocs class >> initialize [

	super initialize.

	(Smalltalk hasClassNamed: #GtCoderEvaluationAnnouncement) ifTrue: [ 
		| ast codeUpdated |
		ast := (GtCoderEvaluationAnnouncement
		        >> #isRequestedByElementOrItsChild:) ast.
		codeUpdated := (ast allChildren select: #isMessage) anySatisfy: [ 
			               :each | 
			               #( #coderViewModel #snippetViewModel ) includes:
				               each selector ].
		codeUpdated ifFalse: [ 
			| link |
			link := MetaLink new
				        metaObject: self;
				        selector: #isRequestedByElementOrItsChild:patch:;
				        control: #instead;
				        arguments: #( arguments #receiver ).
			ast link: link ] ]
]

{ #category : #accessing }
LepiterBuildingBlocs class >> isRequestedByElementOrItsChild: arguments patch: aReceiver [

	"Return true if the evaluation ws requested by a given visual element or any of its children"

	<return: #Boolean>
	| anElement object |
	anElement := arguments first.
	object := aReceiver.

	object requesterObject == anElement ifTrue: [ ^ true ].

	object requesterObject == anElement snippetViewModel coderViewModel 
		ifTrue: [ ^ true ].

	(object requesterObject isKindOf: BlElement) ifFalse: [ ^ false ].

	^ object requesterObject hasParent: anElement
]

{ #category : #accessing }
LepiterBuildingBlocs >> coder [

	^ coder
]

{ #category : #accessing }
LepiterBuildingBlocs >> coderViewModel [

	^ coderViewModel
]

{ #category : #accessing }
LepiterBuildingBlocs >> initialize [

	| bindings task |
	super initialize.
	self flag:
		'TODO: this walking back on the stack will probably break if underlying platform code changes'.
	bindings := thisContext sender sender sender arguments second
		            bindingStrategy.
	coder := (bindings bindingOf: #thisCoder) value.
	coderViewModel := (bindings bindingOf: #thisCoderViewModel) value.
	snippet := (bindings bindingOf: #thisSnippet) value.
	snippetViewModel := (bindings bindingOf: #thisSnippetViewModel) value.
	self constraintsDo: [ :c | 
		c vertical matchParent.
		c horizontal matchParent ].
	task := BlTaskAction new action: [ 
		        | containerElement |
		        containerElement := self
			                            allParentsDetect: [ :each | 
			                            each isKindOf:
				                            LeSnippetContainerElement ]
			                            ifFound: [ :found | 
			                            found children first ]
			                            ifNone: [ nil ].
		        self snippetElement: containerElement ].
	self enqueueTask: task.
	^ self addChild: BlBasicExamples new circle
]

{ #category : #accessing }
LepiterBuildingBlocs >> snippet [

	^ snippet
]

{ #category : #accessing }
LepiterBuildingBlocs >> snippetElement [

	^ snippetElement
]

{ #category : #accessing }
LepiterBuildingBlocs >> snippetElement: aContainerElement [

	snippetElement := aContainerElement
]

{ #category : #accessing }
LepiterBuildingBlocs >> snippetViewModel [

	^ snippetViewModel
]
