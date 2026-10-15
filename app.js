(function () {
  "use strict";

  var STORAGE_KEY = "kurzspiel-laengen-v1";
  var POSITIONS = ["730", "900", "1100"];
  // "v" = normales Schlägerblatt, "o" = geöffnetes Schlägerblatt
  var FACES = ["v", "o"];

  function defaultClubs() {
    return ["LW", "SW", "GW", "PW", "9er"].map(function (name) {
      return emptyClub(name);
    });
  }

  function emptyClub(name) {
    return { name: name, v730: null, v900: null, v1100: null, o730: null, o900: null, o1100: null };
  }

  function load() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        var data = JSON.parse(raw);
        if (Array.isArray(data.clubs)) return data.clubs.map(clean);
      }
    } catch (e) { /* ignore and fall back */ }
    return defaultClubs();
  }

  function save() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({ clubs: clubs }));
    } catch (e) { /* storage unavailable */ }
  }

  function toNum(v) {
    if (v === null || v === undefined || v === "") return null;
    var n = parseFloat(String(v).replace(",", "."));
    return isFinite(n) && n >= 0 ? Math.round(n * 2) / 2 : null;
  }

  function clean(c) {
    return {
      name: String((c && c.name) || "").slice(0, 20),
      v730: toNum(c && c.v730),
      v900: toNum(c && c.v900),
      v1100: toNum(c && c.v1100),
      o730: toNum(c && c.o730),
      o900: toNum(c && c.o900),
      o1100: toNum(c && c.o1100)
    };
  }

  function fmt(n) {
    return String(n).replace(".", ",");
  }

  var clubs = load();
  var editing = false;

  var viewSec = document.getElementById("view");
  var editSec = document.getElementById("edit");
  var viewBody = document.getElementById("viewBody");
  var editList = document.getElementById("editList");
  var modeBtn = document.getElementById("modeBtn");
  var tpl = document.getElementById("editItemTpl");

  function renderView() {
    viewBody.textContent = "";
    var shown = clubs.filter(function (c) { return c.name.trim(); });
    if (!shown.length) {
      var tr = document.createElement("tr");
      tr.className = "none";
      var td = document.createElement("td");
      td.colSpan = 4;
      td.textContent = "Noch keine Schläger. Tippe oben auf „Bearbeiten“.";
      tr.appendChild(td);
      viewBody.appendChild(tr);
      return;
    }
    shown.forEach(function (c) {
      FACES.forEach(function (f) { viewBody.appendChild(viewRow(c, f)); });
    });
  }

  function viewRow(c, f) {
      var tr = document.createElement("tr");
      var th = document.createElement("td");
      th.textContent = c.name;
      if (f === "o") {
        tr.className = "open";
        var tag = document.createElement("span");
        tag.className = "tag";
        tag.textContent = "offen";
        th.appendChild(tag);
      }
      tr.appendChild(th);
      POSITIONS.forEach(function (p) {
        var td = document.createElement("td");
        var v = c[f + p];
        if (v === null) {
          td.className = "empty";
          td.textContent = "–";
        } else {
          td.textContent = fmt(v);
          var u = document.createElement("small");
          u.textContent = "m";
          td.appendChild(u);
        }
        tr.appendChild(td);
      });
      return tr;
  }

  function renderEdit() {
    editList.textContent = "";
    clubs.forEach(function (c, i) {
      var li = tpl.content.firstElementChild.cloneNode(true);
      var name = li.querySelector(".name");
      name.value = c.name;
      name.addEventListener("input", function () { clubs[i].name = name.value.slice(0, 20); save(); });
      FACES.forEach(function (f) {
        POSITIONS.forEach(function (p) {
          var key = f + p;
          var inp = li.querySelector("." + key);
          inp.value = c[key] === null ? "" : fmt(c[key]);
          inp.addEventListener("input", function () { clubs[i][key] = toNum(inp.value); save(); });
        });
      });
      li.querySelector(".up").disabled = i === 0;
      li.querySelector(".down").disabled = i === clubs.length - 1;
      li.querySelector(".up").addEventListener("click", function () { move(i, -1); });
      li.querySelector(".down").addEventListener("click", function () { move(i, 1); });
      li.querySelector(".del").addEventListener("click", function () {
        var label = c.name.trim() || "diesen Schläger";
        if (confirm("„" + label + "“ wirklich löschen?")) {
          clubs.splice(i, 1);
          save();
          renderEdit();
        }
      });
      editList.appendChild(li);
    });
  }

  function move(i, d) {
    var j = i + d;
    if (j < 0 || j >= clubs.length) return;
    var t = clubs[i]; clubs[i] = clubs[j]; clubs[j] = t;
    save();
    renderEdit();
  }

  function setMode(edit) {
    editing = edit;
    viewSec.hidden = edit;
    editSec.hidden = !edit;
    modeBtn.textContent = edit ? "Fertig" : "Bearbeiten";
    if (edit) renderEdit(); else renderView();
    window.scrollTo(0, 0);
  }

  modeBtn.addEventListener("click", function () { setMode(!editing); });

  document.getElementById("addBtn").addEventListener("click", function () {
    clubs.push(emptyClub(""));
    save();
    renderEdit();
    var names = editList.querySelectorAll(".name");
    names[names.length - 1].focus();
  });

  document.getElementById("exportBtn").addEventListener("click", function () {
    var blob = new Blob([JSON.stringify({ clubs: clubs }, null, 2)], { type: "application/json" });
    var a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = "kurzspiel-laengen-" + new Date().toISOString().slice(0, 10) + ".json";
    document.body.appendChild(a);
    a.click();
    setTimeout(function () { URL.revokeObjectURL(a.href); a.remove(); }, 1000);
  });

  document.getElementById("importInput").addEventListener("change", function (e) {
    var file = e.target.files && e.target.files[0];
    if (!file) return;
    var reader = new FileReader();
    reader.onload = function () {
      try {
        var data = JSON.parse(reader.result);
        if (!Array.isArray(data.clubs)) throw new Error("format");
        if (confirm("Aktuelle Daten durch die Sicherung ersetzen?")) {
          clubs = data.clubs.map(clean);
          save();
          renderEdit();
        }
      } catch (err) {
        alert("Diese Datei ist keine gültige Sicherung.");
      }
      e.target.value = "";
    };
    reader.readAsText(file);
  });

  document.getElementById("resetBtn").addEventListener("click", function () {
    if (confirm("Alle Schläger und Längen löschen und mit LW, SW, GW, PW, 9er neu anfangen?")) {
      clubs = defaultClubs();
      save();
      renderEdit();
    }
  });

  renderView();

  if ("serviceWorker" in navigator && location.protocol === "https:") {
    navigator.serviceWorker.register("sw.js").catch(function () {});
  }
})();
