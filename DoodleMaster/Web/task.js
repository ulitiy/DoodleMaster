function loadTask(task) {
  xhr = new XMLHttpRequest();
  xhr.open("GET", `Courses/${task}.svg`, false);
  xhr.onload = function (e) {
    document.body.innerHTML = xhr.responseText;
    let svg = document.querySelector("svg");
    svg.removeAttribute("height");
    svg.removeAttribute("width");
    showTemplate(1);
  };
  xhr.send();
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
  document.querySelector(`#step-${step}-template`).classList.add("show");
  window.webkit.messageHandlers.control.postMessage('TemplateReady');
}

function showInput(step) {
  hideAll();
  stepNumber = step;
  document.querySelector(`#step-${step}-input`).classList.add("show");
}

function restart() {
  hideAll();
  setTimeout(() => {
    showInput(stepNumber);
  }, 1000);
}
