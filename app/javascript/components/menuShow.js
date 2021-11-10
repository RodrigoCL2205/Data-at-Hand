const initMenu = () => {

  const menu = document.querySelector(".br-menu");
  const buttonMenu = document.querySelector("#menu-small");
  const buttonMenu2 = document.querySelector("#menu-small-2");
  const buttonClose = document.querySelector("#close-menu");

  buttonMenu.addEventListener("click", (event) => {
    event.preventDefault;
    menu.classList.toggle("active");
  });

  buttonMenu2.addEventListener("click", (event) => {
    event.preventDefault;
    menu.classList.toggle("active");
  });

  buttonClose.addEventListener("click", (event) => {
    event.preventDefault;
    menu.classList.remove("active");
  });

}

export { initMenu };
