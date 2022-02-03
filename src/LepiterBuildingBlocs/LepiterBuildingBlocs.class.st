Class {
	#name : #LepiterBuildingBlocs,
	#superclass : #BlElement,
	#instVars : [
		'snippet',
		'coder',
		'coderViewModel',
		'snippetViewModel',
		'snippetElement',
		'dataSnippet',
		'data'
	],
	#category : #LepiterBuildingBlocs
}

{ #category : #accessing }
LepiterBuildingBlocs class >> fileSelector [

	| container |
	container := self new.
	container dataSnippetData ifNotEmpty: [ :data | 
		self inform: data asString ].

	^ container addChild: container fileSelector
]

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
LepiterBuildingBlocs class >> template [
	| container content |
	container := self new.
	content := container template.
	^ container addChild: content
	
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
LepiterBuildingBlocs >> dataSnippet [

	^ dataSnippet ifNil: [ 
		  dataSnippet := self findOrCreateChildDataSnippet ]
]

{ #category : #accessing }
LepiterBuildingBlocs >> dataSnippetData [

	^ data ifNil: [ 
		  dataSnippet := self findOrCreateChildDataSnippet.

		  data ifNil: [ 
			  data := (self serializeSnippet: dataSnippet) at: #data ] ]
]

{ #category : #accessing }
LepiterBuildingBlocs >> fileSelector [

	| fileSelector horizontalPane label secondLabel variableName |
	(self coderViewModel sharedBindings bindingOf: #folder) value:
		'.' asFileReference.
	horizontalPane := BrHorizontalPane new.
	label := BrLabel new
		         aptitude: BrGlamorousLabelAptitude new;
		         text: 'Shared Variable: ';
		         padding: (BlInsets all: 5).
	variableName := BrEditableLabel new.
	variableName
		aptitude: (BrGlamorousEditableLabelAptitude new
				 glamorousCodeFont;
				 fontSize: 12);
		padding: (BlInsets all: 5);
		text: 'folder';
		inputFilter: BrTextEditorClassNameInputFilter new;
		when: BrEditorAcceptWish do: [ :aWish | 
		(self coderViewModel sharedBindings bindingOf:
			 aWish text asString asSymbol) value: fileSelector folder.
		variableName text: aWish text.
		self updateData: [ :data | 
			data at: #variable put: aWish text asString ] ];
		whenKey: BlKeyCombination primaryC
		labelDo: [ :aShortcutEvent :aShortcut | 
			Clipboard clipboardText: aShortcutEvent currentTarget text asString ].
	secondLabel := BrLabel new
		               aptitude: BrGlamorousLabelAptitude new;
		               text:
			               'Is bound to: ' , '.' asFileReference pathString;
		               padding: (BlInsets all: 5).
	fileSelector := BrFileSelector new
		                buttonLabel: 'Choose Working Directory';
		                okAction: [ :aDirectory :aButton | 
			                (self coderViewModel sharedBindings bindingOf:
					                 variableName text asString asSymbol) value:
					                aDirectory.
			                secondLabel text:
					                'Is bound to: ' , aDirectory pathString.
			                self updateData: [ :data | 
					                data at: #folder put: aDirectory pathString ] ].
	horizontalPane
		constraintsDo: [ :c | 
			c vertical fitContent.
			c horizontal matchParent ];
		padding: (BlInsets all: 5).
	horizontalPane addChildren: { 
			label.
			variableName.
			secondLabel }.
	^ BrVerticalPane new
		  constraintsDo: [ :c | 
			  c vertical matchParent.
			  c horizontal matchParent ];
		  padding: (BlInsets all: 5);
		  addChildren: { 
				  horizontalPane.
				  fileSelector }
]

{ #category : #accessing }
LepiterBuildingBlocs >> findOrCreateChildDataSnippet [

	^ self snippet children items
		  detect: [ :each | each isKindOf: LeUnknownSnippet ]
		  ifNone: [ 
			  | aSnippet serialized snippetJSON |
			  aSnippet := LeTextSnippet string: ''.
			  self snippet addFirstSnippet: aSnippet.
			  snippetJSON := self serializeSnippet: aSnippet.
			  snippetJSON __type: LeUnknownSnippet leJsonV4Name.
			  snippetJSON data: (data := NeoJSONObject new).
			  serialized := NeoJSONWriter toStringPretty: snippetJSON.
			  aSnippet becomeForward:
				  (LeUnknownSnippet new jsonString: serialized source: aSnippet).
			  self snippetViewModel expanded: false.
			  aSnippet ]
]

{ #category : #accessing }
LepiterBuildingBlocs >> initialize [

	| bindings task |
	super initialize.
	self flag:
		'TODO: this walking back on the stack will probably break if underlying platform code changes'.
	bindings := (thisContext stack detect: [ :each | 
		             each contextClass = GtPharoSourceCoder ]) arguments
		            second bindingStrategy.
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
	^ self
]

{ #category : #accessing }
LepiterBuildingBlocs >> serializeSnippet: aSnippet [

	^ NeoJSONObject fromString: (String streamContents: [ :s | 
			   LeJsonV4 uniqueInstance
				   serialize: aSnippet
				   on: s
				   prettyPrint: true ])
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

{ #category : #accessing }
LepiterBuildingBlocs >> template [

	| cloneButton horizontalPane label pageName |
	horizontalPane := BrHorizontalPane new.
	label := BrLabel new
		         aptitude: BrGlamorousLabelAptitude new;
		         text:
			         'You can clone this page with the name on the right: ';
		         padding: (BlInsets all: 5).
	pageName := BrEditableLabel new.
	pageName
		aptitude: (BrGlamorousEditableLabelAptitude new
				 glamorousCodeFont;
				 fontSize: 12);
		padding: (BlInsets all: 5);
		text: self snippet page title , ' - Copy';
		when: BrEditorAcceptWish do: [ :aWish | pageName text: aWish text ];
		whenKey: BlKeyCombination primaryC
		labelDo: [ :aShortcutEvent :aShortcut | 
			Clipboard clipboardText: aShortcutEvent currentTarget text asString ];
		whenKey:
			(BlKeyCombinationBuilder new primary key: BlKeyboardKey backslash)
				build
		labelDo: [ :aShortcutEvent :aShortcut | 
		pageName text: Date today yyyymmdd ].
	cloneButton := BrButton new
		               aptitude: BrGlamorousButtonWithLabelAptitude;
		               label: 'Clone Page';
		               padding: (BlInsets all: 5);
		               beNormalSize;
		               action: [ :aButtonElement :aButtonModel :anEvent | 
			               aButtonElement previousSiblingDo: [ :anElement | 
					               anElement phlow spawnTool:
							               (self snippet page duplicatePageWithNewName:
									                anElement text asString) asPhlowTool ] ].
	horizontalPane
		constraintsDo: [ :c | 
			c vertical matchParent.
			c horizontal matchParent ];
		padding: (BlInsets all: 5).
	^ horizontalPane addChildren: { 
			  label.
			  pageName.
			  cloneButton }
]

{ #category : #accessing }
LepiterBuildingBlocs >> updateData: aBlock [

	| snippetJSON |
	aBlock value: data.
	snippetJSON := self serializeSnippet: dataSnippet.
	snippetJSON data: data.
	dataSnippet
		jsonString: (NeoJSONWriter toStringPretty: snippetJSON)
		source: self snippet
]
