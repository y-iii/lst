MaxPositive = (list) ->
	Math.max.apply @, [0].concat list

class Table
	constructor: ->
		@dom = document.createElement "table"
		@rows = []
		@editor = new Editor

	AddRow: ->
		row = new Row @
		row.AddCell() for [1..MaxPositive(r.cells.length for r in @rows)] by 1
		@rows.push row
		return

	AddColumn: ->
		row.AddCell() for row in @rows
		return

	FillCell: (row, col, text) ->
		@rows[row].cells[col].FillWith text
		return

	ValueOfCell: (row, col) ->
		@rows[row].cells[col].Value()

	InsertIntoPageAt: (element) ->
		element.appendChild @dom
		@editor.InsertIntoPageAt element
		return

class Row
	constructor: (table) ->
		@dom = table.dom.insertRow()
		@cells = []
		@editor = table.editor

	AddCell: ->
		cell = new Cell @
		@cells.push cell
		return

	ValueOfCell: (col) ->
		@cells[col].Value()

class Cell
	constructor: (row) ->
		@dom = row.dom.insertCell()
		@dom.classList.add "lst_cell"
		@dom.addEventListener "dblclick", row.editor.ShowFor @

	FillWith: (text) ->
		@dom.removeChild @dom.firstChild while @dom.firstChild?
		content = document.createTextNode text
		@dom.appendChild content
		return

	Value: ->
		@dom.firstChild?.nodeValue or ""

class Editor
	constructor: ->
		@CommitAndHide = @CommitAndHideGenerator()
		@RevertAndHide = @RevertAndHideGenerator()
		@KeyHandler = @KeyHandlerGenerator()
		@dom = document.createElement "textarea"
		@dom.style.position = "absolute"
		@dom.style.visibility = "hidden"
		@dom.addEventListener "blur", @CommitAndHide
		@dom.addEventListener "keydown", @KeyHandler
		@cell = null

	InsertIntoPageAt: (element) ->
		element.appendChild(@dom)
		return

	ShowFor: (cell) ->
		editor = @
		->
			editor.dom.value = cell.Value()
			editor.dom.style.top = "#{cell.dom.offsetTop}px"
			editor.dom.style.left = "#{cell.dom.offsetLeft}px"
			editor.dom.style.visibility = "visible"
			editor.dom.focus()
			editor.cell = cell
			return

	CommitAndHideGenerator: ->
		editor = @
		->
			editor.cell?.FillWith editor.dom.value
			editor.cell = null
			editor.dom.style.visibility = "hidden"
			return

	RevertAndHideGenerator: ->
		editor = @
		->
			editor.cell = null
			editor.dom.style.visibility = "hidden"
			return

	KeyHandlerGenerator: ->
		editor = @
		(event) ->
			if event.defaultPrevented
				return
			key = event.key or event.keyCode
			switch key
				when "Enter", 13
					editor.CommitAndHide()
					event.preventDefault()
				when "Escape", 27
					editor.RevertAndHide()
					event.preventDefault()
			return

Tokenize = (str) ->
	x.trim() for x in str.split /([\*\/\^\(\)])/ when x.trim().length > 0

CanonicalFromFormula = (formula) ->
	tokens = Tokenize formula
	canonicals = []
	for token, index in tokens by 2
		[operator, operand] = [tokens[index - 1] or "*", token]
		switch operator
			when "*"
				canonicals.push CanonicalFromToken operand
			when "/"
				canonicals.push CanonicalReciprocal CanonicalFromToken operand
			when "^"
				canonicals.push CanonicalToPower canonicals.pop(), operand
	canonicals.reduce CanonicalProduct, {factor: 1, units: {}}

CanonicalFromToken = (token) ->
	switch typeof token
		when "number"
			{factor: (+token), units: {}}
		when "string"
			{factor: 1, units: {"#{token}": 1}}
		when "object"
			token

ObjectFromPairs = (pairList) ->
	pairList.reduce ((acc, pair) -> acc[pair[0]] = pair[1]; acc), {}

CanonicalReciprocal = (x) ->
	{factor: 1 / x.factor, units: ObjectFromPairs ([k, -v] for k, v of x.units)}

CanonicalToPower = (x, pow) ->
	{factor: x.factor ** (+pow), units: ObjectFromPairs ([k, (+pow)] for k, v of x.units)}

CanonicalProduct = (x, y) ->
	# {factor: x.factor * y.factor, units: ObjectFromPairs ([k, ])}
	null

table = new Table
table.AddRow()
table.AddRow()
table.AddRow()
table.AddColumn()
table.AddColumn()
table.FillCell 0, 0, "кг"
table.FillCell 1, 0, "м"
table.FillCell 2, 0, "с"
table.FillCell 0, 1, "Вт"
table.FillCell 1, 1, "кг * м / (с * с^2) * м"
table.FillCell 2, 1, "кг / (2*с)^2 * м"
table.InsertIntoPageAt document.body

link = document.createElement "a"
link.appendChild document.createTextNode "test"
f = (e) ->
	console.log Tokenize table.ValueOfCell 2, 1
	console.log CanonicalFromFormula table.ValueOfCell 2, 1
	e.preventDefault()
link.addEventListener "click", f
link.href = "\#"
document.body.appendChild link
f({preventDefault: ->})
