let debugSVG = ``;

function loadTask(task) {
  if (debugSVG) {
    loadSVG(debugSVG);
    return
  }
  xhr = new XMLHttpRequest();
  xhr.open("GET", `Courses/${task}.svg`, false);
  xhr.onload = (e) => loadSVG(xhr.responseText);
  xhr.send();
}

function loadSVG(text) {
  let res = text;
  res = res.replace(/\sid=/gm, " class=");
  res = res.replace(/_\d+/gm, "\"");
  document.body.innerHTML = res;
  let svg = document.querySelector("svg");
  svg.removeAttribute("height");
  svg.removeAttribute("width");
  showTemplate(1);
}

let stepNumber;

function hideAll() {
  const el = document.querySelector(`.show`);
  if (!el) return;
  el.classList.remove("show");
}

function showTemplate(step) {
  hideAll();
  stepNumber = step;
  document.querySelector(`.step-${step} .template`).classList.add("show");
  if (debugSVG) return;
  window.requestAnimationFrame(() =>
    window.requestAnimationFrame(() =>
      window.webkit.messageHandlers.control.postMessage('TemplateReady')));
}

function showInput(step) {
  hideAll();
  stepNumber = step;
  document.querySelector(`.step-${step} .input`).classList.add("show");
  document.querySelectorAll(`.step-${step} .input > .draw-line`).forEach(drawLine);
  if (debugSVG) return;
  window.requestAnimationFrame(() =>
    window.requestAnimationFrame(() =>
      window.webkit.messageHandlers.control.postMessage('InputReady')));
}

function drawLine(el) {
  el.style.transition = "";
  // remove delay, it breaks animation
  var dclass;
  el.classList.forEach((cl) => dclass = cl.match(/^d\d+$/) ? cl : dclass);
  el.classList.remove(dclass);

  let flip = el.classList.contains("flip");

  let len = el.getTotalLength() * 1.1;
  let seconds = Math.round(len/100)/10;
  el.style.strokeDasharray = len;
  el.style.strokeDashoffset = len;

  setTimeout(() => {
    // bring delay back
    if (dclass) {
      el.classList.add(dclass);
    }
    el.style.transition = `stroke-dashoffset ${seconds}s linear`;
    el.style.strokeDashoffset = flip ? len * 2 : 0;
  }, 0);
}

function restart() {
  hideAll();
  setTimeout(() => {
    showInput(stepNumber);
  }, 1000);
}
