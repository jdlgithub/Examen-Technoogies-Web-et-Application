// Plan des sièges : grille HTML/CSS chargée par fetch depuis
// /api/voyages/<id>/sieges (sujet : sièges pris grisés, dessinés en HTML/CSS).
document.addEventListener("DOMContentLoaded", function () {
  var conteneur = document.getElementById("plan-sieges");
  if (!conteneur) return;

  var idVoyage = conteneur.dataset.voyage;
  var champSiege = document.getElementById("numero_siege");
  var boutonAchat = document.getElementById("bouton-achat");
  var messageSiege = document.getElementById("message-siege");

  fetch("/api/voyages/" + idVoyage + "/sieges")
    .then(function (reponse) {
      if (!reponse.ok) throw new Error("Réponse invalide du serveur");
      return reponse.json();
    })
    .then(function (donnees) {
      conteneur.innerHTML = "";

      donnees.sieges.forEach(function (siege) {
        var bouton = document.createElement("button");
        bouton.type = "button";
        bouton.textContent = siege.numero;
        bouton.className = siege.pris ? "siege siege-pris" : "siege";
        bouton.setAttribute(
          "aria-label",
          "Siège " + siege.numero + (siege.pris ? " (vendu)" : " (libre)")
        );

        if (siege.pris) {
          bouton.disabled = true;
        } else {
          bouton.addEventListener("click", function () {
            // Déselection du siège précédent
            var precedent = conteneur.querySelector(".siege-selectionne");
            if (precedent) precedent.classList.remove("siege-selectionne");
            bouton.classList.add("siege-selectionne");
            champSiege.value = siege.numero;
            boutonAchat.disabled = false;
            messageSiege.hidden = true;
          });
        }
        conteneur.appendChild(bouton);
      });
    })
    .catch(function (erreur) {
      conteneur.innerHTML =
        "<p class='flash erreur'>Impossible de charger le plan des sièges (" +
        erreur.message + "). Rechargez la page.</p>";
    });
});
