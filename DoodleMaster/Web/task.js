let debugSVG = ``;

function loadTask(task) {
  if (debugSVG) {
    loadSVG(debugSVG);
    return
  }
  xhr = new XMLHttpRequest();
  xhr.open("GET", `courses/${task}.svg`, false);
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
}

let stepNumber;
let refreshVersion = 0;
let mustSkipAnimation = false;
shadowSize = 10;

function getStepSettings(step) {
  const el = document.querySelector(`.step:nth-child(${countSteps() - step})`);
  let template = [...el.classList].find((c) => c.startsWith("s-")) || "default";
  return template.replace(/^s-/, "");
}

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
  createTemplate(step);
  document.querySelector(`.step:nth-child(${countSteps() - step})>.template`).classList.add("show");
  makeRGBTemplates(step);
  if (debugSVG) return;
  onRepaint(() =>
      window.webkit.messageHandlers.control.postMessage('TemplateReady'));
}

function createTemplate(step) {
  let el = document.querySelector(`.step:nth-child(${countSteps() - step}) .template`);
  if(el) return;

  el = document.createElementNS('http://www.w3.org/2000/svg', "g");
  el.classList.add("template");
  document.querySelector(`.step:nth-child(${countSteps() - step})`).appendChild(el);
}

function onRepaint(f) {
  let svg = document.querySelector("svg");
  svg.style.display = "none";
  svg.style.offsetHeight;
  svg.style.display = "block";
  window.requestAnimationFrame(() => {
    setTimeout(() => {
      svg.style.display = "none";
      svg.style.offsetHeight;
      svg.style.display = "block";
      window.requestAnimationFrame(f);
    }, 100)
  })
}

function showInput(step) {
  hideAll();
  onRepaint(() => {
      if (!debugSVG) {
        window.webkit.messageHandlers.control.postMessage('InputReady')
      }
      stepNumber = step;
      document.querySelector(`.step:nth-child(${countSteps() - step})>.input`).classList.add("show");
      document.querySelectorAll(`.step:nth-child(${countSteps() - step})>.input .draw-line`).forEach((el) => drawLine(el));
      if (mustSkipAnimation) {
        skipAnimation();
      }
    });
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

  let len = el.getTotalLength() * 1.02;
  let duration = Math.round(len/100)/10;
  duration = duration >= 0.9 ? duration : 0.9;
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

function setSkipAnimation(val) {
  mustSkipAnimation = val;
  if(!val) return;
  skipAnimation();
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
  showInput(stepNumber);
  skipAnimation();
}

function setShadowSize(size) {
  shadowSize = size;
}

function makeRGBTemplates(step) {
  document.querySelectorAll(`.step:nth-child(${countSteps() - step}) .g-template:empty, .step:nth-child(${countSteps() - step}) .g-template :empty`).forEach((el) => 
    makeTemplate(el, step, "#0F0", shadowSize * 1.7 - 5));

  const els = document.querySelectorAll(`.step:nth-child(${countSteps() - step}) .rgb-template:empty, .step:nth-child(${countSteps() - step}) .rgb-template :empty`);
  els.forEach((el) => makeTemplate(el, step, "#0F0", shadowSize * 1.7 - 5)); // was 1.9 but reduced for dashes
  els.forEach((el) => makeTemplate(el, step, "#00F", shadowSize * 0.87)); // 0.87 can be barely 100%. 0.85 easy, 0.9 impossible
  els.forEach((el) => makeTemplate(el, step, "#F00", 5)); // ~1.5px in 320*256 resolution of template on GPU

  document.querySelectorAll(`.step:nth-child(${countSteps() - step}) .rgb-template`).forEach((el) =>
    el.classList.remove("rgb-template"));
  document.querySelectorAll(`.step:nth-child(${countSteps() - step}) .g-template`).forEach((el) => 
    el.classList.remove("g-template"));
}

function makeTemplate(el, step, color, size) {
  const n = el.cloneNode();
  n.classList.remove("rgb-template", "g-template", "input", "template");
  document.querySelector(`.step:nth-child(${countSteps() - step}) .template`).appendChild(n);
  n.setAttribute("stroke", color)
  n.setAttribute("stroke-width", size)
}

function countSteps() {
  return document.querySelectorAll(`.step`).length;
}
