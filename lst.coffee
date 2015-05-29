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
			editor.dom.value = cell.dom.firstChild?.nodeValue or ""
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

table = new Table
table.AddRow()
table.AddRow()
table.AddRow()
table.AddColumn()
table.AddColumn()
table.FillCell 0, 0, "X1"
table.FillCell 1, 0, "X2"
table.FillCell 2, 0, "X3"
table.InsertIntoPageAt document.body
