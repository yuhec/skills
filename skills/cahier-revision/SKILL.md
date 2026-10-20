---
name: cahier-revision
description: Crée des fiches de révision au style « cahier manuscrit » (papier ligné, spirale, surligneurs, questions numérotées Q1, Q2…, schémas de flux, tableaux) à partir d'un article, d'un cours, d'un document, d'une vidéo transcrite ou d'un sujet. Utilise ce skill dès que l'utilisateur demande « fais-moi une fiche », « une fiche de révision », « un cahier de révision », « une cheat sheet », « un aide-mémoire », « un rappel rapide », « résume ce cours en fiche » ou veut réviser, mémoriser ou préparer un examen ou un entretien à partir d'un contenu, même s'il ne mentionne pas le style cahier.
---

# Cahier de révision

Ce skill produit des fiches de révision visuelles qui ressemblent à des pages de cahier : papier ligné, marge rouge, spirale, écriture manuscrite, surligneurs de couleur, questions numérotées avec leur réponse, schémas et tableaux dessinés à la main. Le but est la mémorisation : chaque page doit pouvoir se relire en quelques minutes et se réciter à voix haute.

Le gabarit complet est dans `assets/template.html`. Le catalogue des composants (avec le code de chacun) est dans `references/composants.md`. Lis les deux avant d'écrire la page.

## 1. Comprendre la demande

Repère trois choses dans le message, sans poser de question si elles sont déductibles :

- **La source** : une URL, un fichier joint, un texte collé, ou seulement un sujet (« fais-moi une fiche sur les transformers »).
- **Le format** :
  - **Cahier** (par défaut) : une ou plusieurs pages en questions-réponses numérotées, avec schémas et tableaux. Pour apprendre.
  - **Rappel rapide** : une seule page dense en grille d'encadrés. Pour réviser juste avant un examen ou un entretien. Utilise-le quand l'utilisateur dit « rappel », « dernière ligne droite », « une seule page », « résumé express ».
- **Le découpage** : un article court donne une page. Un cours long donne une page par chapitre ou grande notion, avec une barre de navigation en haut. Au-delà de 8 pages, propose de découper en plusieurs cahiers.

Si la source est introuvable ou inaccessible (lien privé, fichier absent), dis-le et demande-la plutôt que d'inventer le contenu.

## 2. Lire et vérifier la source

- **URL** : récupère la page avec l'outil de lecture web. Si elle est inaccessible, dis-le.
- **Fichier** : lis-le entièrement (PDF, docx, transcription).
- **Sujet seul** : fais des recherches pour t'appuyer sur des sources fiables et à jour, surtout pour les noms de produits, versions, API, dates et réglementations.

Règles d'exactitude, parce qu'une fiche de révision fausse fait apprendre des erreurs :

- Chaque chiffre, nom d'API, date ou affirmation précise doit venir de la source ou d'une vérification. N'invente rien pour remplir une case.
- Si un point vient de tes connaissances générales sans vérification, marque-le « (à vérifier) » dans la fiche.
- Si la source contient une erreur évidente, signale-la dans un encadré d'avertissement plutôt que de la recopier.
- Le pied de page indique la source (titre ou URL) et la date de création, et précise ce qui a été vérifié.

Droit d'auteur : reformule tout dans tes propres mots. Ne recopie pas de paragraphes, ne reconstitue pas la structure de l'article section par section. Au plus une citation courte (moins de 15 mots) par source, entre guillemets.

## 3. Construire le contenu

### En format cahier

Transforme la matière en **questions qu'un examinateur pourrait poser**, numérotées en continu sur tout le cahier (Q1, Q2… même d'une page à l'autre). Vise 4 à 8 questions par page.

Pour chaque question, choisis le composant qui montre le mieux la réponse :

| Nature de la réponse | Composant |
|---|---|
| Définition, idées clés | Liste à puces courte |
| Processus, pipeline, étapes ordonnées | Flux vertical (`.flow`) ou chaîne horizontale (`.chain`) |
| Comparaison de 2 à 4 options | Tableau (`table`) |
| Trois catégories en parallèle | Mini-encadrés (`.cols3`) |
| Formule, code, commande | Bloc `pre` |
| Erreur fréquente, piège | Encadré rouge (`.warn`) |
| Astuce, règle à retenir | Encadré vert (`.tip`) |
| Exemple chiffré | Tableau ou calcul pas à pas |

Une page alterne les composants : ne mets pas que des listes. Mets un schéma ou un tableau à côté du texte quand ça aide (grille `.row.two`).

Chaque page a un titre encadré, un numéro de page (« Page 2 sur 5 ») et un post-it penché qui résume l'idée clé de la page en une phrase.

### En format rappel rapide

Une seule page : un titre, une ligne de méthode ou de fil conducteur en haut, puis une grille d'encadrés (un par notion), chacun avec un titre surligné et 3 à 6 puces très courtes. Un encadré pleine largeur pour le schéma principal si le sujet en a un.

### Règles d'écriture

- Langue : celle de l'utilisateur (français par défaut). Garde les termes techniques d'origine quand c'est ainsi qu'on les utilise (embedding, recall, canary).
- Phrases courtes, une idée par puce. Pas de phrases d'introduction ni de conclusion.
- Surligne au plus un ou deux mots-clés par puce. Si tout est surligné, rien ne ressort.
- Couleurs des surligneurs : violet pour les questions, et jaune, vert, rose, bleu, orange pour varier les étapes d'un schéma. Le rose et le rouge signalent un risque ou un piège.
- Donne des exemples concrets et chiffrés : un exemple calculé se retient mieux qu'une définition.

## 4. Produire la page

1. Copie `assets/template.html` comme point de départ et garde son CSS tel quel : il gère le papier ligné, la spirale, le mode sombre, le mobile et les zones de sécurité des téléphones.
2. Remplace le contenu d'exemple par le tien en utilisant les composants de `references/composants.md`.
3. Mets à jour le `<title>`, la barre de navigation (une entrée par page, supprime-la s'il n'y a qu'une page) et le pied de page.
4. Vérifie que les tableaux sont dans un conteneur `.tw` (défilement horizontal sur mobile) et que chaque flux se lit dans l'ordre.

## 5. Livrer

- Dans claude.ai, si l'outil de publication d'artifacts est disponible, enregistre le fichier dans `/mnt/user-data/outputs/` et publie-le comme page, avec l'émoji 📓 comme favicon. Pour une mise à jour, republie la même page plutôt que d'en créer une nouvelle.
- Sinon, enregistre le fichier `.html` et présente-le à l'utilisateur.
- Dans ta réponse, reste bref : ce que couvre la fiche (nombre de pages et de questions), et ce qui n'a pas pu être vérifié. Ne résume pas le contenu de la fiche dans le chat.

## Exemples de demandes

- « Fais-moi une fiche pour cet article : https://… » → lire l'article, une page de 4 à 6 questions.
- « Fais-moi un cahier de révision sur ce cours » + PDF → une page par chapitre, navigation en haut.
- « Une fiche de rappel rapide sur Kubernetes avant mon entretien » → recherches, puis une page en grille.
- « Ajoute une page sur le monitoring à mon cahier » → reprendre le fichier existant, continuer la numérotation des questions, republier.
