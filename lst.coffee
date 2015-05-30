MaxPositive = (list) ->
	Math.max.apply @, [0].concat list

Any = (list) ->
	true in (Boolean x for x in list)

All = (list) ->
	not (false in (Boolean x for x in list))

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

IsTokenizable = (str) ->
	Any (x in str for x in "*/^()")

IsNumeric = (str) ->
	All (x in "0123456789." for x in str)

class Fraction
	constructor: (@num, @denom = 1) ->

	ToFloat: ->
		@num / @denom

	ProductWith: (factor) ->
		new Fraction @num * factor.num, @denom * factor.denom

	Reciprocal: ->
		new Fraction @denom, @num

	ToPower: (exponent) ->
		new Fraction @num ** exponent, @denom ** exponent

class CanonicalSI
	constructor: (@factor, @units) ->

CanonicalFrom = (obj) ->
	switch typeof obj
		when "string"
			if IsTokenizable obj
				CanonicalFromFormula obj
			else if IsNumeric obj
				new CanonicalSI (new Fraction (+obj)), {}
			else
				new CanonicalSI (new Fraction 1), {"#{obj}": 1}
		when "object"
			if obj instanceof "CanonicalSI"
				obj
			else
				null
		else
			null

CanonicalFromFormula = (formula) ->
	tokens = Tokenize formula
	canonicals = []
	for token, index in tokens by 2
		[operator, operand] = [tokens[index - 1] or "*", token]
		switch operator
			when "*"
				canonicals.push CanonicalFrom operand
			when "/"
				canonicals.push CanonicalReciprocal CanonicalFrom operand
			when "^"
				canonicals.push CanonicalToPower canonicals.pop(), operand
	console.log canonicals
	canonicals.reduce CanonicalProduct, (new CanonicalSI (new Fraction 1), {})

UnitsFromPairs = (pairList) ->
	pairList.reduce ((acc, pair) -> acc[pair[0]] = pair[1] + (acc[pair[0]] or 0); acc), {}

CanonicalReciprocal = (x) ->
	new CanonicalSI x.factor.Reciprocal(), UnitsFromPairs ([k, -v] for k, v of x.units)

CanonicalToPower = (x, pow) ->
	new CanonicalSI (x.factor.ToPower (+pow)), UnitsFromPairs ([k, v * (+pow)] for k, v of x.units)

CanonicalProduct = (x, y) ->
	new CanonicalSI (x.factor.ProductWith y.factor),
	UnitsFromPairs (([kx, vx] for kx, vx of x.units).concat ([ky, vy] for ky, vy of y.units))

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
table.FillCell 1, 1, "кг * м / (с * (2*с)^2) * м"
table.FillCell 2, 1, "кг / 2 / с^2 * м"
table.InsertIntoPageAt document.body

link = document.createElement "a"
link.appendChild document.createTextNode "test"
f = (e) ->
	console.log Tokenize table.ValueOfCell 2, 1
	console.log CanonicalFrom table.ValueOfCell 2, 1
	e.preventDefault()
link.addEventListener "click", f
link.href = "\#"
document.body.appendChild link
f({preventDefault: ->})
