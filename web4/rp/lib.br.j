const webTab = document.querySelector(
    "#b-scopeListItem-web"
);

if (webTab) {

    webTab.addEventListener("click", (event) => {

        if (webTab.classList.contains("b_active")) {

            event.preventDefault();
            event.stopPropagation();
        }

    }, true);
}
