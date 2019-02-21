# README

![LogoRubyRails](https://www.coderhold.com/wp-content/uploads/2017/09/What-is-Ruby-on-Rails.png)

## Projet QEmotion

### Versions utilisées :
* Ruby : 2.3.3
* Rails : 5.1.6.1
* GraphQL : 1.5.0

### Librairie et gem utilisée :
* Utilisation de la gem bcrypt pour le cryptage des mots de passe.
* Utilisation de la gem mysql2 pour le développement.
* Utilisation de la gem pg pour la base de données en PostgreSQL sur le serveur de Heroku.

### ATTENTION !!!!
Penser à activer la gem nécessaire dans le gemfile et de mettre l'autre en commentaire !

Le fichier database.yml pour la production est dans le repositorie sous le nom de DEV.database.yml (/config/DEV.database.yml)

Le projet sera par défaut en dev avec la gem mysql2 d'activée

------

## But du projet :

Pour découvrir les proﬁls de nos développeurs nous souhaitons analyser leur activité sur Github.
Github propose une API GraphQL pour l'accès aux données.

Nous souhaitons avoir les fonctionnalités suivantes sur l'application :

* Rechercher un utilisateur sur Github -- **Terminé**
* Visualiser la liste des dépôts publics auxquels il contribue -- **Terminé**
* Afﬁcher les statistiques de ses contributions par dépôt -- **Terminé**
* Pour chaque dépôt auquel il contribue visualiser les langages utilisés -- **Terminé**
* Pour chaque dépôt auquel il contribue sa position dans le top 10 des contributeurs de ce dépôt **Terminé**
* Connaitre le top 3 des langages qu'il utilise le plus fréquemment -- **Terminé**
* Nous souhaitons pouvoir conserver nos recherches pour y revenir ultérieurement -- **Terminé**
* Déploiement du projet rails sur HEROKU ou AWS ou tout autre plateforme en ligne -- **Terminé** (adresse du site : https://vauvilliersqemotion.herokuapp.com/)

------

## Informations supplémentaires :
* Durée max du projet : 7 jours
* Date de rendu : Vendredi 22 Février
* Déploiement sur OVH impossible, leurs serveurs ne supportent pas Rails
* Le développement du projet a été ralenti par la limite d'utilisation de l'API de GitHub qui est de 60 fois par heure
