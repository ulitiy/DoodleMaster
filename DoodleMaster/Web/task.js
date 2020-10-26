function LoadTask(task) {
  xhr = new XMLHttpRequest();
  xhr.open("GET", `Courses/${task}.svg`, false);
  xhr.onload = function (e) {
    document.body.innerHTML = xhr.responseText;
    SetStep(1);
  };
  // document.body.innerHTML = test_svg;
  // SetStep(1);
  xhr.send();
}

function SetStep(step) {
  document.body.className = `show-step-${step}`;
}

function Restart() {
  if(document.body.className === "") {
    return;
  }
  let oldClassName = document.body.className;
  document.body.className = "";
  setTimeout(() => {
    document.body.className = oldClassName;
  }, 1000);
}

function SetStepsLE(step) {
  document.body.className = `show-steps-le-${step}`;
}

document.addEventListener("DOMContentLoaded", () => {
  LoadTask(task);
});
