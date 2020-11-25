let debugSVG = undefined;

function loadTask(task) {
  xhr = new XMLHttpRequest();
  xhr.open("GET", `Courses/${task}.svg`, false);
  xhr.onload = function(e) {
    loadSVG(xhr.responseText);
  }
  if (debugSVG) {
    loadSVG(debugSVG)
  } else {
    xhr.send();
  }
}

function loadSVG(text) {
  let res = text
  res = res.replace(/\sid=/gm, " class=");
  res = res.replace(/_\d+\"/gm, "\"");
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
  if (!debugSVG) {
    window.requestAnimationFrame(function() {
      window.webkit.messageHandlers.control.postMessage('TemplateReady');
    })
  }
}

function showInput(step) {
  hideAll();
  stepNumber = step;
  document.querySelector(`.step-${step} .input`).classList.add("show");
  window.requestAnimationFrame(function() {
    window.webkit.messageHandlers.control.postMessage('InputReady');
  })
}

function restart() {
  hideAll();
  setTimeout(() => {
    showInput(stepNumber);
  }, 1000);
}
