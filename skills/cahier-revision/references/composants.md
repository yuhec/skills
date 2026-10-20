# Catalogue des composants

Tous ces composants utilisent les classes déjà définies dans `assets/template.html`. Copie le code tel quel et remplace le texte.

## Sommaire
1. En-tête de page
2. Question
3. Surligneurs
4. Texte + schéma côte à côte
5. Flux vertical
6. Chaîne horizontale
7. Tableau
8. Trois mini-encadrés
9. Code, formule, commande
10. Piège et astuce
11. Encadré de rappel rapide
12. Ligne de méthode

---

## 1. En-tête de page

```html
<section class="page" id="rag">
  <div class="head"><span class="pg">Page 1 sur 3</span><span class="sticky">Idée clé en une phrase</span></div>
  <h2 class="title">Titre de la page</h2>
  …
</section>
```

L'`id` sert d'ancre à la navigation : `<a href="#rag">RAG</a>`.

## 2. Question

```html
<div class="q"><span class="qn">Q4</span><h3><mark class="hv">Comment évaluer un RAG ?</mark></h3></div>
```

La numérotation continue d'une page à l'autre.

## 3. Surligneurs

| Classe | Couleur | Usage conseillé |
|---|---|---|
| `hv` | violet | Questions |
| `hy` | jaune | Mot-clé principal |
| `hg` | vert | Bonne pratique, résultat |
| `hp` | rose | Risque, piège, attention |
| `hb` | bleu | Outil, technologie, entrée |
| `ho` | orange | Sortie, stockage, variante |

```html
<mark class="hy">mot-clé</mark>
```

Dans un schéma, on colore le fond de l'étape : `style="background:var(--hb)"`.

## 4. Texte + schéma côte à côte

Deux colonnes sur grand écran, empilées sur mobile.

```html
<div class="row two">
  <ul><li>…</li></ul>
  <div class="box">…schéma ou tableau…</div>
</div>
```

## 5. Flux vertical

Pour un processus ordonné de 3 à 10 étapes.

```html
<div class="box">
  <div class="box-t"><span>Pipeline</span></div>
  <div class="flow">
    <div class="step" style="background:var(--hb)">1. Étape</div><div class="arrow">↓</div>
    <div class="step" style="background:var(--hv)">2. Étape</div><div class="arrow">↓</div>
    <div class="step" style="background:var(--hg)">3. Étape</div>
  </div>
</div>
```

Pour une boucle, remplace la dernière flèche par `<div class="arrow">↻ jusqu'à la fin</div>`.

## 6. Chaîne horizontale

Pour 3 à 6 étapes courtes ; passe à la ligne sur mobile.

```html
<div class="chain">
  <div class="step" style="background:var(--hb)">init</div>→
  <div class="step" style="background:var(--hy)">plan</div>→
  <div class="step" style="background:var(--hg)">apply</div>
</div>
```

## 7. Tableau

Toujours dans `.tw` pour défiler horizontalement sur mobile. La première colonne est en gras automatiquement.

```html
<div class="tw"><table>
  <tr><th>Option</th><th>Quand</th><th>Limite</th></tr>
  <tr><td>A</td><td>…</td><td>…</td></tr>
</table></div>
```

## 8. Trois mini-encadrés

Pour trois catégories parallèles.

```html
<div class="cols3">
  <div class="mini" style="background:var(--hb)"><b>Titre</b>Explication courte</div>
  <div class="mini" style="background:var(--hg)"><b>Titre</b>Explication courte</div>
  <div class="mini" style="background:var(--hy)"><b>Titre</b>Explication courte</div>
</div>
```

## 9. Code, formule, commande

```html
<pre>κ = (accord observé − accord hasard) / (1 − accord hasard)</pre>
```

En ligne : `<code>terraform plan</code>`. Échappe `<` et `>` en `&lt;` et `&gt;` dans le code.

## 10. Piège et astuce

```html
<p class="warn">Erreur fréquente : …</p>
<p class="tip">À retenir : …</p>
```

## 11. Encadré de rappel rapide

Dans une `<div class="grid">`. Ajoute `wide` pour la pleine largeur.

```html
<div class="grid">
  <div class="box">
    <h2><mark class="hb">Notion</mark></h2>
    <ul><li>…</li></ul>
  </div>
  <div class="box wide">…</div>
</div>
```

## 12. Ligne de méthode

En haut d'un rappel rapide, pour le fil conducteur.

```html
<p class="method">Pour chaque réponse : <span class="hy">étape</span> → <span class="hb">outil</span> → <span class="hg">métrique</span></p>
```
