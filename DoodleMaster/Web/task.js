function LoadTask(task) {
  xhr = new XMLHttpRequest();
  xhr.open("GET", `Courses/${task}.svg`, false);
  xhr.onload = function (e) {
    document.body.innerHTML = xhr.responseText;
  };
  xhr.send();
}

document.addEventListener("DOMContentLoaded", () => {
  LoadTask(task);
});
