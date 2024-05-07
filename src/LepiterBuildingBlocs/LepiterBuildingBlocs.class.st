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

	| container content |
	container := self new.
	content := container fileSelector.
	container dataSnippetData
		ifEmpty: [ (content childNamed: #variableName) text: 'folder' ]
		ifNotEmpty: [ :data | 
			data variable
				ifNil: [ (content childNamed: #variableName) text: 'folder' ]
				ifNotNil: [ :variable | 
				(content childNamed: #variableName) text: variable ].

			data folder ifNotNil: [ :folder | 
				(content childNamed: #brFileSelector) folder:
					folder asFileReference.
				(content childNamed: #secondLabel) text:
					'Is bound to: ' , folder asFileReference pathString ] ].
	container hideDataSnippet.

	^ container addChild: content
]

{ #category : #accessing }
LepiterBuildingBlocs class >> initialize [
	| method |
	super initialize.
	"method := [ [ GtCoderEvaluationAnnouncement >> #isRequestedByElementOrItsChild: ]
			on: KeyNotFound
			do: [ LeElementSnippetElementRequester >> #isRequestedByElementOrItsChild: ] ]
			on: KeyNotFound
			do: [ nil ].
	method
		ifNotNil: [ | ast codeUpdated |
			ast := method ast.
			codeUpdated := (ast allChildren select: #isMessage)
					anySatisfy: [ :each | #(#coderViewModel #snippetViewModel) includes: each selector ].
			codeUpdated
				ifFalse: [ | link |
					link := MetaLink new
							metaObject: self;
							selector: #isRequestedByElementOrItsChild:patch:;
							control: #instead;
							arguments: #(arguments #receiver).
					ast link: link ] ]"
]

{ #category : #accessing }
LepiterBuildingBlocs class >> isRequestedByElementOrItsChild: arguments patch: aReceiver [

	"Return true if the evaluation ws requested by a given visual element or any of its children"

	<return: #Boolean>
	| anElement object |
	anElement := arguments first.
	object := aReceiver.

	object asCoderRequesterObject == anElement ifTrue: [ ^ true ].

	object asCoderRequesterObject == anElement snippetViewModel coderViewModel 
		ifTrue: [ ^ true ].

	(object asCoderRequesterObject isKindOf: BlElement) ifFalse: [ ^ false ].

	^ object asCoderRequesterObject hasParent: anElement
]

{ #category : #accessing }
LepiterBuildingBlocs class >> runSnippets [

	| container content |
	container := self new.
	content := container runSnippets.
	^ container addChild: content
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
LepiterBuildingBlocs >> doIt: someSnippets [

	| snippets |
	snippets := OrderedCollection new.
	someSnippets do: [ :each | 
		self gatherChildSnippets: each withCollection: snippets ].
	self snippetViewModel snippetsCollectionDo: [ :aSnippetsCollection | 
		| progress size |
		size := snippets size.
		((snippets size = 1 and: [ snippets first = self snippet ]) or: [ 
			 snippets isEmpty ]) ifTrue: [ ^ nil ].
		progress := self snippetElement childNamed: #runSnippetsProgress.
		progress
			amount: 0 total: size;
			visibility: BlVisibility visible.
		(snippets collect: [ :aSnippet | 
			 (aSnippetsCollection findOrCreateSnippetViewModel: aSnippet)
				 coderViewModel ]) doWithIndex: [ :each :index | 
			index = size
				ifFalse: [ each doIt ]
				ifTrue: [ 
					(self snippetElement childNamed: #inspectLastRunSnippet)
						isChecked
						ifTrue: [ each doItAndGo ]
						ifFalse: [ each doIt ] ].
			progress amount: index total: size ].
		progress visibility: BlVisibility hidden ]
]

{ #category : #accessing }
LepiterBuildingBlocs >> doItChildren [

	self doIt: self snippet children
]

{ #category : #accessing }
LepiterBuildingBlocs >> doItPage [

	| direction snippets topMostParentSnippet |
	topMostParentSnippet := self snippet.
	[ topMostParentSnippet parent isKindOf: LePage ] whileFalse: [ 
		topMostParentSnippet := topMostParentSnippet parent ].
	direction := (thisContext sender gtVariables asDictionary at:
		              #aButtonElement) label asString.
	snippets := self snippet page children items.
	direction = 'Above' ifTrue: [ 
		(topMostParentSnippet ~= self snippet and: [ 
			 (snippets indexOf: topMostParentSnippet) = snippets size ]) 
			ifFalse: [ 
				snippets := snippets copyUpTo:
					            (snippets at:
						             (snippets indexOf: topMostParentSnippet)
						             + (topMostParentSnippet = self snippet
								              ifTrue: [ 0 ]
								              ifFalse: [ 1 ])) ] ].
	direction = 'Below' ifTrue: [ 
		snippets := snippets copyAfter: topMostParentSnippet ].
	self doIt: snippets
]

{ #category : #accessing }
LepiterBuildingBlocs >> doItSiblings [

	| direction snippets |
	direction := (thisContext sender gtVariables asDictionary at: #aButtonElement) label asString.
	snippets := self snippet parent children items.
	direction = 'Above' ifTrue: [ snippets := snippets copyUpTo: self snippet ].
	direction = 'Below' ifTrue: [ snippets := snippets copyAfter: self snippet ].
	self doIt: snippets
]

{ #category : #accessing }
LepiterBuildingBlocs >> fileSelector [

	| fileSelector horizontalPane label secondLabel variableName |
	horizontalPane := BrHorizontalPane new.
	label := BrLabel new
		         aptitude: BrGlamorousLabelAptitude new;
		         text: 'Shared Variable: ';
		         padding: (BlInsets all: 5).
	variableName := BrEditableLabel new.
	variableName
		id: #variableName;
		aptitude: (BrGlamorousEditableLabelAptitude new
				 glamorousCodeFont;
				 fontSize: 12);
		padding: (BlInsets all: 5);
		inputFilter: BrTextEditorClassNameInputFilter new;
		when: BrEditorAcceptWish do: [ :aWish | 
		variableName text: aWish text.
		self updateData: [ :someData | 
			someData at: #variable put: aWish text asString ] ];
		whenKey: BlKeyCombination primaryC
		labelDo: [ :aShortcutEvent :aShortcut | 
			Clipboard clipboardText: aShortcutEvent currentTarget text asString ].
	variableName editor
		when: BrTextEditorTextReplacedEvent
		do: [ :anEvent | 
			(self coderViewModel sharedBindings bindingOf:
				 anEvent text asString asSymbol) value: fileSelector folder ].
	fileSelector := BrFileSelector new
		                id: #brFileSelector;
		                buttonLabel: 'Choose Working Directory';
		                okAction: [ :aDirectory :aButton | 
			                (self coderViewModel sharedBindings bindingOf:
					                 variableName text asString asSymbol) value:
					                aDirectory.
			                secondLabel text:
					                'Is bound to: ' , aDirectory pathString.
			                self updateData: [ :someData | 
					                someData at: #folder put: aDirectory pathString ] ].
	secondLabel := BrLabel new
		               id: #secondLabel;
		               aptitude: BrGlamorousLabelAptitude new;
		               text:
			               'Is bound to: ' , fileSelector folder pathString;
		               padding: (BlInsets all: 5).
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
		  id: #fileSelector;
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
			  | aTextSnippet anUnknownSnippet serialized snippetJSON |
			  aTextSnippet := LeTextSnippet string: ''.
			  self snippet addFirstSnippet: aTextSnippet.
			  snippetJSON := self serializeSnippet: aTextSnippet.
			  snippetJSON __type: LeUnknownSnippet leJsonV4Name.
			  snippetJSON data: (data := NeoJSONObject new).
			  serialized := NeoJSONWriter toStringPretty: snippetJSON.
			  anUnknownSnippet := LeUnknownSnippet new
				                      jsonString: serialized
				                      source: self snippet.
			  aTextSnippet removeSelf.
			  self snippet addFirstSnippet: anUnknownSnippet.
			  self snippetViewModel expanded: false.
			  anUnknownSnippet ]
]

{ #category : #accessing }
LepiterBuildingBlocs >> gatherChildSnippets: aSnippet withCollection: snippets [

	(LeCodeSnippet allSubclasses , { LeCodeSnippet } anySatisfy: [ :each | 
		 each = aSnippet class ]) ifTrue: [ 
		aSnippet = self snippet ifFalse: [ snippets add: aSnippet ] ].
	(aSnippet children size > 0 and: [ 
		 (self snippetElement childNamed: #runAllNestedChildren) isChecked ]) 
		ifTrue: [ 
			aSnippet children do: [ :each | 
				self gatherChildSnippets: each withCollection: snippets ] ]
]

{ #category : #accessing }
LepiterBuildingBlocs >> hideDataSnippet [

	self enqueueTask: (BlTaskAction new action: [ 
			 self snippetElement parent previousSiblingDo: [ :brTriangle | 
				 brTriangle viewModel model toggle.
				 self snippetViewModel expanded: false ] ])
]

{ #category : #accessing }
LepiterBuildingBlocs >> initialize [

	| bindings task |
	super initialize.
	self
		flag:
			'TODO: this walking back on the stack will probably break if underlying platform code changes';
		id: #lepiterBuildingBloc.
	bindings := ((thisContext stack
			detect: [ :each | each receiver isKindOf: GtPharoSourceCoder ]) gtVariables
			detect: [ :each | each key = #aGtPharoSourceCoderEvaluationContext ]) value.
	coder := (bindings bindingOf: #thisCoder) value.
	coderViewModel := (bindings bindingOf: #thisCoderViewModel) value.
	snippet := (bindings bindingOf: #thisSnippet) value.
	snippetViewModel := (bindings bindingOf: #thisSnippetViewModel) value.
	self constraintsDo: [ :c | 
		c vertical matchParent.
		c horizontal matchParent ].
"	task := BlTaskAction new action: [ 
		        snippetElement := bindings requesterObject asCoderRequesterObjectself
			                          allParentsDetect: [ :each | 
			                          each isKindOf: LeSnippetContainerElement ]
			                          ifFound: [ :found | found children first ]
			                          ifNone: [ nil ] ].
	self enqueueTask: task."
	^ self
]

{ #category : #accessing }
LepiterBuildingBlocs >> runSnippets [

	| labels |
	labels := self runSnippetsLabels.

	^ BrVerticalPane new
		  id: #runSnippets;
		  padding: (BlInsets all: 10);
		  cellSpacing: 2;
		  aptitude: (BrShadowAptitude new width: 1.2);
		  constraintsDo: [ :c | 
			  c vertical fitContent.
			  c horizontal matchParent ];
		  addChildren: { 
				  labels first.
				  self runSnippetsButtons.
				  labels second.
				  self runSnippetsCheckboxes.
				  self runSnippetsProgress }
]

{ #category : #accessing }
LepiterBuildingBlocs >> runSnippetsButtons [

	| buttonGrid |
	buttonGrid := self runSnippetsCreateButtons.
	#( #pageAbove #pageBelow #pageAll ) do: [ :each | 
		(buttonGrid childNamed: each) action: [ 
			:aButtonElement 
			:aButtonModel 
			:anEvent | [ self doItPage ] forkAt: 29 named: #runSnippets ] ].
	#( #siblingsAbove #siblingsBelow #siblingsAll ) do: [ :each | 
		(buttonGrid childNamed: each) action: [ 
			:aButtonElement 
			:aButtonModel 
			:anEvent | [ self doItSiblings ] forkAt: 29 named: #runSnippets ] ].
	(buttonGrid childNamed: #childrenAll) action: [ 
		:aButtonElement 
		:aButtonModel 
		:anEvent | [ self doItChildren ] forkAt: 29 named: #runSnippets ].
	^ buttonGrid
]

{ #category : #accessing }
LepiterBuildingBlocs >> runSnippetsCheckboxes [

	^ BrHorizontalPane new
		  padding: (BlInsets all: 5);
		  border: (BlBorder paint: (Color gray alpha: 0.3));
		  constraintsDo: [ :c | 
			  c vertical matchParent.
			  c horizontal matchParent ];
		  addChildren: { 
				  (BrHorizontalPane new
					   alignCenter;
					   cellSpacing: 5;
					   constraintsDo: [ :c | 
						   c vertical matchParent.
						   c horizontal matchParent ];
					   addChildren: { 
							   (BrCheckbox new
								    id: #inspectLastRunSnippet;
								    aptitude: BrGlamorousCheckboxAptitude;
								    check).
							   (BrLabel new
								    aptitude: BrGlamorousLabelAptitude new;
								    text: 'Inspect Last Run Snippet') }).
				  (BrHorizontalPane new
					   alignCenter;
					   cellSpacing: 5;
					   constraintsDo: [ :c | 
						   c vertical matchParent.
						   c horizontal matchParent ];
					   addChildren: { 
							   (BrCheckbox new
								    id: #runAllNestedChildren;
								    aptitude: BrGlamorousCheckboxAptitude;
								    check).
							   (BrLabel new
								    aptitude: BrGlamorousLabelAptitude new;
								    text: 'Run Children Snippets Recursively') }) }
]

{ #category : #accessing }
LepiterBuildingBlocs >> runSnippetsCreateButtons [

	| grid |
	grid := BrHorizontalPane new
		        border: (BlBorder paint: (Color gray alpha: 0.3));
		        constraintsDo: [ :c | 
			        c vertical matchParent.
			        c horizontal matchParent ].
	^ grid addChildren: { 
			  (BrVerticalPane new
				   alignTopCenter;
				   cellSpacing: 5;
				   constraintsDo: [ :c | 
					   c vertical fitContent.
					   c horizontal matchParent ];
				   addChildren: { 
						   (BrLabel new
							    aptitude: BrGlamorousLabelAptitude new;
							    text: 'Page Level').
						   (BrButton new
							    id: #pageAbove;
							    label: 'Above';
							    aptitude: BrGlamorousButtonWithLabelAptitude).
						   (BrButton new
							    id: #pageBelow;
							    label: 'Below';
							    aptitude: BrGlamorousButtonWithLabelAptitude).
						   (BrButton new
							    id: #pageAll;
							    label: 'All';
							    aptitude: BrGlamorousButtonWithLabelAptitude) }).
			  (BrVerticalPane new
				   alignTopCenter;
				   cellSpacing: 5;
				   constraintsDo: [ :c | 
					   c vertical matchParent.
					   c horizontal matchParent ];
				   addChildren: { 
						   (BrLabel new
							    aptitude: BrGlamorousLabelAptitude new;
							    text: 'Sibling Level').
						   (BrButton new
							    id: #siblingsAbove;
							    label: 'Above';
							    aptitude: BrGlamorousButtonWithLabelAptitude).
						   (BrButton new
							    id: #siblingsBelow;
							    label: 'Below';
							    aptitude: BrGlamorousButtonWithLabelAptitude).
						   (BrButton new
							    id: #siblingsAll;
							    label: 'All';
							    aptitude: BrGlamorousButtonWithLabelAptitude) }).
			  (BrVerticalPane new
				   alignTopCenter;
				   cellSpacing: 5;
				   constraintsDo: [ :c | 
					   c vertical matchParent.
					   c horizontal matchParent ];
				   addChildren: { 
						   (BrLabel new
							    aptitude: BrGlamorousLabelAptitude new;
							    text: 'Children').
						   (BrButton new
							    id: #childrenAll;
							    label: 'All';
							    aptitude: BrGlamorousButtonWithLabelAptitude) }) }
]

{ #category : #accessing }
LepiterBuildingBlocs >> runSnippetsLabels [

	^ { 
		  (BrHorizontalPane new
			   alignCenter;
			   constraintsDo: [ :c | 
				   c vertical fitContent.
				   c horizontal matchParent ];
			   addChild: (BrLabel new
					    aptitude: (BrGlamorousLabelAptitude new fontSize: 16);
					    text:
						    'Run a Batch of Multiple Snippets Sequentially in a Background Process')).
		  (BrHorizontalPane new
			   alignCenter;
			   constraintsDo: [ :c | 
				   c vertical fitContent.
				   c horizontal matchParent ];
			   addChild: (BrVerticalPane new alignCenter
					    constraintsDo: [ :c | 
						    c vertical fitContent.
						    c horizontal matchParent ];
					    addChildren:
						    (('*Above & below are in relation to the snippet that holds this UI.'
						      , Character cr asString
						      ,
							      'Progress bar will appear and get updated while snippets run and hide again when complete.')
							     lines collect: [ :each | 
								     BrLabel new
									     aptitude: BrGlamorousLabelAptitude new;
									     text: each ]))) }
]

{ #category : #accessing }
LepiterBuildingBlocs >> runSnippetsProgress [

	^ BrHorizontalPane new
		  alignCenter;
		  padding: (BlInsets all: 5);
		  constraintsDo: [ :c | 
			  c vertical fitContent.
			  c horizontal matchParent ];
		  addChild: (BrProgress new
				   id: #runSnippetsProgress;
				   visibility: BlVisibility hidden;
				   patternLabel: '{1}/{2} Snippets Ran';
				   layout: BlLinearLayout new;
				   constraintsDo: [ :c | 
					   c horizontal matchParent.
					   c vertical fitContent ];
				   aptitude: self runSnippetsProgressBarLook + (self runSnippetsProgressTextLook
							    foreground: Color white;
							    labelDo: [ :aLabel | 
								    aLabel constraintsDo: [ :c | c ignoreByLayout ] ]))
]

{ #category : #accessing }
LepiterBuildingBlocs >> runSnippetsProgressBarLook [

	^ BrProgressBarAptitude new
		  barDo: [ :aBar | 
			  aBar background: Color blue.
			  aBar geometry: (BlRoundedRectangleGeometry cornerRadius: 8).
			  aBar constraintsDo: [ :c | c vertical exact: 20 ] ];
		  containerDo: [ :aBarContainer | 
			  aBarContainer background: Color blue muchLighter.
			  aBarContainer geometry:
					  (BlRoundedRectangleGeometry cornerRadius: 8) ]
]

{ #category : #accessing }
LepiterBuildingBlocs >> runSnippetsProgressTextLook [

	^ BrTextLabelAptitude new
		  foreground: Color lightGray;
		  labelDo: [ :aWidget | 
			  aWidget constraintsDo: [ :c | 
					  c margin: (BlInsets all: 3).
					  c linear horizontal alignCenter.
					  c ignored horizontal alignCenter.
					  c ignored vertical alignCenter ] ]
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
