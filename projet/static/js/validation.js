// Vérification du formulaire d'achat avant envoi (FR-015).
// Le serveur revérifie tout : ce contrôle améliore seulement l'expérience.
document.addEventListener("DOMContentLoaded", function () {
  var formulaire = document.getElementById("formulaire-achat");
  if (!formulaire) return;

  var champSiege = document.getElementById("numero_siege");
  var messageSiege = document.getElementById("message-siege");
  var regexTelephone = /^\+?[0-9]{8,15}$/;

  function afficherMessage(texte) {
    messageSiege.textContent = texte;
    messageSiege.hidden = false;
  }

  formulaire.addEventListener("submit", function (evenement) {
    var nom = document.getElementById("nom").value.trim();
    var telephone = document.getElementById("telephone").value.trim();
    var piece = document.getElementById("piece_identite").value.trim();

    if (!champSiege.value) {
      evenement.preventDefault();
      afficherMessage("Choisissez d'abord un siège sur le plan du bus.");
      return;
    }
    if (!nom) {
      evenement.preventDefault();
      afficherMessage("Le nom du voyageur est obligatoire.");
      return;
    }
    if (!regexTelephone.test(telephone)) {
      evenement.preventDefault();
      afficherMessage(
        "Téléphone invalide : chiffres seulement (ex. 6XXXXXXXX)."
      );
      return;
    }
    if (!piece) {
      evenement.preventDefault();
      afficherMessage("Le numéro de pièce d'identité est obligatoire.");
      return;
    }
  });
});
