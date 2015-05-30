// Generated by CoffeeScript 1.9.2
var All, Any, CanonicalFrom, CanonicalFromFormula, CanonicalProduct, CanonicalReciprocal, CanonicalSI, CanonicalToPower, Cell, Editor, Fraction, IsNumeric, IsTokenizable, MaxPositive, Row, Table, Tokenize, UnitsFromPairs, f, link, table,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

MaxPositive = function(list) {
  return Math.max.apply(this, [0].concat(list));
};

Any = function(list) {
  var x;
  return indexOf.call((function() {
    var i, len, results;
    results = [];
    for (i = 0, len = list.length; i < len; i++) {
      x = list[i];
      results.push(Boolean(x));
    }
    return results;
  })(), true) >= 0;
};

All = function(list) {
  var x;
  return !(indexOf.call((function() {
    var i, len, results;
    results = [];
    for (i = 0, len = list.length; i < len; i++) {
      x = list[i];
      results.push(Boolean(x));
    }
    return results;
  })(), false) >= 0);
};

Table = (function() {
  function Table() {
    this.dom = document.createElement("table");
    this.rows = [];
    this.editor = new Editor;
  }

  Table.prototype.AddRow = function() {
    var i, r, ref, row;
    row = new Row(this);
    for (i = 1, ref = MaxPositive((function() {
      var j, len, ref1, results;
      ref1 = this.rows;
      results = [];
      for (j = 0, len = ref1.length; j < len; j++) {
        r = ref1[j];
        results.push(r.cells.length);
      }
      return results;
    }).call(this)); i <= ref; i += 1) {
      row.AddCell();
    }
    this.rows.push(row);
  };

  Table.prototype.AddColumn = function() {
    var i, len, ref, row;
    ref = this.rows;
    for (i = 0, len = ref.length; i < len; i++) {
      row = ref[i];
      row.AddCell();
    }
  };

  Table.prototype.FillCell = function(row, col, text) {
    this.rows[row].cells[col].FillWith(text);
  };

  Table.prototype.ValueOfCell = function(row, col) {
    return this.rows[row].cells[col].Value();
  };

  Table.prototype.InsertIntoPageAt = function(element) {
    element.appendChild(this.dom);
    this.editor.InsertIntoPageAt(element);
  };

  return Table;

})();

Row = (function() {
  function Row(table) {
    this.dom = table.dom.insertRow();
    this.cells = [];
    this.editor = table.editor;
  }

  Row.prototype.AddCell = function() {
    var cell;
    cell = new Cell(this);
    this.cells.push(cell);
  };

  Row.prototype.ValueOfCell = function(col) {
    return this.cells[col].Value();
  };

  return Row;

})();

Cell = (function() {
  function Cell(row) {
    this.dom = row.dom.insertCell();
    this.dom.classList.add("lst_cell");
    this.dom.addEventListener("dblclick", row.editor.ShowFor(this));
  }

  Cell.prototype.FillWith = function(text) {
    var content;
    while (this.dom.firstChild != null) {
      this.dom.removeChild(this.dom.firstChild);
    }
    content = document.createTextNode(text);
    this.dom.appendChild(content);
  };

  Cell.prototype.Value = function() {
    var ref;
    return ((ref = this.dom.firstChild) != null ? ref.nodeValue : void 0) || "";
  };

  return Cell;

})();

Editor = (function() {
  function Editor() {
    this.CommitAndHide = this.CommitAndHideGenerator();
    this.RevertAndHide = this.RevertAndHideGenerator();
    this.KeyHandler = this.KeyHandlerGenerator();
    this.dom = document.createElement("textarea");
    this.dom.style.position = "absolute";
    this.dom.style.visibility = "hidden";
    this.dom.addEventListener("blur", this.CommitAndHide);
    this.dom.addEventListener("keydown", this.KeyHandler);
    this.cell = null;
  }

  Editor.prototype.InsertIntoPageAt = function(element) {
    element.appendChild(this.dom);
  };

  Editor.prototype.ShowFor = function(cell) {
    var editor;
    editor = this;
    return function() {
      editor.dom.value = cell.Value();
      editor.dom.style.top = cell.dom.offsetTop + "px";
      editor.dom.style.left = cell.dom.offsetLeft + "px";
      editor.dom.style.visibility = "visible";
      editor.dom.focus();
      editor.cell = cell;
    };
  };

  Editor.prototype.CommitAndHideGenerator = function() {
    var editor;
    editor = this;
    return function() {
      var ref;
      if ((ref = editor.cell) != null) {
        ref.FillWith(editor.dom.value);
      }
      editor.cell = null;
      editor.dom.style.visibility = "hidden";
    };
  };

  Editor.prototype.RevertAndHideGenerator = function() {
    var editor;
    editor = this;
    return function() {
      editor.cell = null;
      editor.dom.style.visibility = "hidden";
    };
  };

  Editor.prototype.KeyHandlerGenerator = function() {
    var editor;
    editor = this;
    return function(event) {
      var key;
      if (event.defaultPrevented) {
        return;
      }
      key = event.key || event.keyCode;
      switch (key) {
        case "Enter":
        case 13:
          editor.CommitAndHide();
          event.preventDefault();
          break;
        case "Escape":
        case 27:
          editor.RevertAndHide();
          event.preventDefault();
      }
    };
  };

  return Editor;

})();

Tokenize = function(str) {
  var i, len, ref, results, x;
  ref = str.split(/([\*\/\^\(\)])/);
  results = [];
  for (i = 0, len = ref.length; i < len; i++) {
    x = ref[i];
    if (x.trim().length > 0) {
      results.push(x.trim());
    }
  }
  return results;
};

IsTokenizable = function(str) {
  var x;
  return Any((function() {
    var i, len, ref, results;
    ref = "*/^()";
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      x = ref[i];
      results.push(indexOf.call(str, x) >= 0);
    }
    return results;
  })());
};

IsNumeric = function(str) {
  var x;
  return All((function() {
    var i, len, results;
    results = [];
    for (i = 0, len = str.length; i < len; i++) {
      x = str[i];
      results.push(indexOf.call("0123456789.", x) >= 0);
    }
    return results;
  })());
};

Fraction = (function() {
  function Fraction(num, denom) {
    this.num = num;
    this.denom = denom != null ? denom : 1;
  }

  Fraction.prototype.ToFloat = function() {
    return this.num / this.denom;
  };

  Fraction.prototype.ProductWith = function(factor) {
    return new Fraction(this.num * factor.num, this.denom * factor.denom);
  };

  Fraction.prototype.Reciprocal = function() {
    return new Fraction(this.denom, this.num);
  };

  Fraction.prototype.ToPower = function(exponent) {
    return new Fraction(Math.pow(this.num, exponent), Math.pow(this.denom, exponent));
  };

  return Fraction;

})();

CanonicalSI = (function() {
  function CanonicalSI(factor1, units) {
    this.factor = factor1;
    this.units = units;
  }

  return CanonicalSI;

})();

CanonicalFrom = function(obj) {
  var obj1;
  switch (typeof obj) {
    case "string":
      if (IsTokenizable(obj)) {
        return CanonicalFromFormula(obj);
      } else if (IsNumeric(obj)) {
        return new CanonicalSI(new Fraction(+obj), {});
      } else {
        return new CanonicalSI(new Fraction(1), (
          obj1 = {},
          obj1["" + obj] = 1,
          obj1
        ));
      }
      break;
    case "object":
      if (obj instanceof "CanonicalSI") {
        return obj;
      } else {
        return null;
      }
      break;
    default:
      return null;
  }
};

CanonicalFromFormula = function(formula) {
  var canonicals, i, index, len, operand, operator, ref, token, tokens;
  tokens = Tokenize(formula);
  canonicals = [];
  for (index = i = 0, len = tokens.length; i < len; index = i += 2) {
    token = tokens[index];
    ref = [tokens[index - 1] || "*", token], operator = ref[0], operand = ref[1];
    switch (operator) {
      case "*":
        canonicals.push(CanonicalFrom(operand));
        break;
      case "/":
        canonicals.push(CanonicalReciprocal(CanonicalFrom(operand)));
        break;
      case "^":
        canonicals.push(CanonicalToPower(canonicals.pop(), operand));
    }
  }
  console.log(canonicals);
  return canonicals.reduce(CanonicalProduct, new CanonicalSI(new Fraction(1), {}));
};

UnitsFromPairs = function(pairList) {
  return pairList.reduce((function(acc, pair) {
    acc[pair[0]] = pair[1] + (acc[pair[0]] || 0);
    return acc;
  }), {});
};

CanonicalReciprocal = function(x) {
  var k, v;
  return new CanonicalSI(x.factor.Reciprocal(), UnitsFromPairs((function() {
    var ref, results;
    ref = x.units;
    results = [];
    for (k in ref) {
      v = ref[k];
      results.push([k, -v]);
    }
    return results;
  })()));
};

CanonicalToPower = function(x, pow) {
  var k, v;
  return new CanonicalSI(x.factor.ToPower(+pow), UnitsFromPairs((function() {
    var ref, results;
    ref = x.units;
    results = [];
    for (k in ref) {
      v = ref[k];
      results.push([k, v * (+pow)]);
    }
    return results;
  })()));
};

CanonicalProduct = function(x, y) {
  var kx, ky, vx, vy;
  return new CanonicalSI(x.factor.ProductWith(y.factor), UnitsFromPairs(((function() {
    var ref, results;
    ref = x.units;
    results = [];
    for (kx in ref) {
      vx = ref[kx];
      results.push([kx, vx]);
    }
    return results;
  })()).concat((function() {
    var ref, results;
    ref = y.units;
    results = [];
    for (ky in ref) {
      vy = ref[ky];
      results.push([ky, vy]);
    }
    return results;
  })())));
};

table = new Table;

table.AddRow();

table.AddRow();

table.AddRow();

table.AddColumn();

table.AddColumn();

table.FillCell(0, 0, "кг");

table.FillCell(1, 0, "м");

table.FillCell(2, 0, "с");

table.FillCell(0, 1, "Вт");

table.FillCell(1, 1, "кг * м / (с * (2*с)^2) * м");

table.FillCell(2, 1, "кг / 2 / с^2 * м");

table.InsertIntoPageAt(document.body);

link = document.createElement("a");

link.appendChild(document.createTextNode("test"));

f = function(e) {
  console.log(Tokenize(table.ValueOfCell(2, 1)));
  console.log(CanonicalFrom(table.ValueOfCell(2, 1)));
  return e.preventDefault();
};

link.addEventListener("click", f);

link.href = "\#";

document.body.appendChild(link);

f({
  preventDefault: function() {}
});
