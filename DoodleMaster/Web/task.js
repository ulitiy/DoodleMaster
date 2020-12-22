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
let refreshVersion = 0;

function hideAll() {
  refreshVersion++;
  const el = document.querySelector(`.show`);
  if (!el) return;
  el.classList.remove("show");
  el.classList.remove("skip-animation");
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
  document.querySelectorAll(`.step-${step} .input .draw-line`).forEach((el) => drawLine(el));
  if (debugSVG) return;
  window.requestAnimationFrame(() =>
    window.requestAnimationFrame(() =>
      window.webkit.messageHandlers.control.postMessage('InputReady')));
}

function getRepeat(el) {
  for (var cl of el.classList.values()) {
    const match = cl.match(/^r(\d+)$/);
    if (match) {
      return parseInt(match[1]);
    }
  }
  return undefined;
}

function getDelay(el) {
  for (var cl of el.classList.values()) {
    const match = cl.match(/^d(\d+)$/);
    if (match) {
      return parseInt(match[1]);
    }
  }
  return undefined;
}

function drawLine(el) {
  const tempVersion = refreshVersion;
  const repeatDelay = getRepeat(el);
  const delay = getDelay(el); // don't move this line
  el.style.transition = "";
  // remove delay, it breaks animation
  tempRemoveDelay(el);

  let len = el.getTotalLength() * 1.1;
  let duration = Math.round(len/100)/10;
  el.style.strokeDasharray = len;
  el.style.strokeDashoffset = len;
  el.classList.remove("hide");

  setTimeout(() => {
    let flip = el.classList.contains("flip");
    el.style.transitionProperty = "stroke-dashoffset, opacity";
    el.style.transitionDuration = `${duration}s, 0.3s`;
    el.style.transitionTimingFunction = "linear";
    el.style.strokeDashoffset = flip ? len * 2 : 0;
  }, 0);

  if (repeatDelay == undefined) return;

  console.log(delay, duration, repeatDelay);
  setTimeout(() => {
    if (tempVersion != refreshVersion) return;
    el.classList.add("hide");
  }, duration * 1000); // there's additional delay for hide
  setTimeout(() => {
    if (tempVersion != refreshVersion) return;
    drawLine(el);
  }, (delay + duration + 0.3 + repeatDelay) * 1000);
}

function tempRemoveDelay(el) {
  var dclass;
  el.classList.forEach((cl) => dclass = cl.match(/^d\d+$/) ? cl : dclass);
  el.classList.remove(dclass);
  setTimeout(() => {
    // bring delay back
    if (dclass) {
      el.classList.add(dclass);
    }
  }, 0);
}

function skipAnimation() {
  document.querySelector(`.show`).classList.add("skip-animation");
  document.querySelectorAll(`.input.show .draw-line`).forEach((el) => {
    if (getRepeat(el) !== undefined) return
    el.style.strokeDasharray = "none";
    el.style.transition = "none";
  });
}

function restart() {
  hideAll();
  setTimeout(() => {
    showInput(stepNumber);
  }, 1000);
}
