---
name: brainstorming
description: Déclenche quand l'utilisateur dit "je veux brainstormer", "mode brainstorm", "mode plan", "je veux explorer". Claude pose des questions d'exploration avant de proposer une solution, même si une idée évidente émerge. Continue à raffiner jusqu'à avoir les vraies contraintes et objectifs (la clé — l'utilisateur arrête de lever des doutes/questions).
---

# Brainstorming First

## Comportement principal

Quand ce skill déclenche, tu entres en mode brainstorming exploratoire et TU NE PROPOSES PAS DE SOLUTION IMMÉDIATEMENT, même si tu as une idée.

## Phase 1 : Compréhension

- **Écoute l'intention** — Qu'est-ce qu'il/elle cherche vraiment à faire ?
- **Identifie les implicites** — Quelles contraintes, risques ou objectifs ne sont pas énoncés ?
- **Pose des questions ouvertes** pour explorer :
  - Les objectifs réels (pas juste la surface)
  - Les contraintes connues (budget, temps, tech, ressources)
  - Les doutes ou peurs (« ça peut casser comment ? »)
  - Les alternatives déjà rejetées et pourquoi
  - Ce qui compte vraiment dans le succès

## Phase 2 : Intégration des réactions

- L'utilisateur émet un doute ? Explore-le. Ne dis pas « non mais en fait c'est possible » — demande plus.
- L'utilisateur conteste l'orientation ? Pause. Raffine ta compréhension avant de continuer.
- L'utilisateur propose une variante ? Creuse-la. C'est une info importante.

## Phase 3 : Checkpoint avant esquisse

Une fois que tu penses avoir les vraies contraintes et objectifs, PAUSE et résume ce que tu as compris :

- Les objectifs réels
- Les contraintes/risques clés
- Ce qui compte vraiment dans le succès

Demande : « C'est ça qu'on cherche ? Je suis bien d'accord sur X, Y, Z ? »

Attends son accord explicite avant de proposer un plan.

## Phase 4 : Présenter les directions après accord

Une fois qu'il/elle valide ta compréhension, tu peux proposer 2-3 directions + leurs trade-offs (pas un plan détaillé complet encore).

## Phase 5 : Demander le « go » avant plan détaillé

Après avoir présenté les directions, demande explicitement :
« Je pars dans quelle direction ? Ou tu veux qu'on raffine une des deux avant que je te fasse le plan détaillé ? »

Attends son choix ET son « ok, lance » avant de produire un vrai plan d'exécution.

## Signaux d'arrêt du skill

Le skill se désactive quand l'utilisateur dit explicitement « ok, lance le plan » ou « ok c'est bon, fais-le ». À ce moment, tu produis un plan détaillé et sors du mode brainstorming.

## Ce qu'il NE FAUT PAS faire

- Proposer un plan A/B/C comme « solution » à un problème mal compris
- Ignorer les doutes pour avancer plus vite
- Poser 10 questions à la fois (max 2-3, ciblées)
- Utiliser « mais techniquement on pourrait... » pour contredire une objection sans l'explorer
- Sauter les checkpoints : accord sur la compréhension, choix de direction, « go » pour le plan détaillé

## Exemple de déroulé

```
USER: Je veux brainstormer un nouveau système de tracking interne

CLAUDE (mode brainstorming):
Avant qu'on dessine quelque chose, je veux bien comprendre :

1. Vous tracez quoi au juste ? Les heures passées sur quoi, ou plutôt l'état d'avancement, ou ?
2. Qu'est-ce qui ne va pas avec votre système actuel ? (C'est important pour ne pas reproduire le même problème)

USER: On veut tracker les tâches, l'état d'avancement. L'actuel, c'est un Google Sheet et personne l'utilise.

CLAUDE (toujours mode brainstorming):
Bon, donc l'adoption est un vrai risque. Pourquoi vous pensez que les gens ne l'utilisent pas ?
- Trop long à remplir ?
- Pas accessible ?
- Personne ne se responsabilise ?
- Quelque chose d'autre ?

Ça va aider à se demander : est-ce que c'est un problème d'outil, ou d'habitudes ?

USER: Ouais c'est...

[...on continue d'explorer jusqu'à clarté suffisante...]

CLAUDE (checkpoint):
Attends, je récap ce que j'ai compris pour être sûr :
- Vous tracez les tâches et l'avancement
- Le problème actuel : l'adoption (le Google Sheet, personne ne l'utilise)
- Ce qui compte vraiment : lightweight + accessible, pas un truc complexe
- Et l'adoption dépend plus de responsabilisation/process que de l'outil lui-même

C'est ça ? Ou j'ai loupé quelque chose ?

USER: Ouais c'est bon. Ajoute juste... le truc doit être intégrable à notre workflow Slack.

CLAUDE:
Ok, l'intégration Slack c'est une vraie contrainte. Donc :

Voilà deux directions :
1. Intégration simple (Slack embed + base de données minimale) — moins flexible, plus adoptée
2. Outil dédié léger (Plane, variante Linear) — plus flexible, risque d'adoption si pas de process autour

Lequel vous tente ? Ou il y a un truc dans les deux qui clash ?

USER: Je pense que l'option 1 c'est plus notre truc. Lightweight et intégré à Slack directement.

CLAUDE:
Ok, direction 1 (Slack embed). Avant que je me lance dans le plan détaillé — tu veux que je te fasse quoi exactement ? Genre :
- Les steps pour setup et intégration
- Les risques/limitations de cette approche
- Le timeline et les ressources
- Les trois ?

Et sinon, il y a un truc que tu veux qu'on affine avant que je commence ?
```

## Contexte

Ce skill existe parce que Claude a tendance à proposer une réponse rapide même quand les vraies questions ne sont pas posées. Ce skill force la pause et l'exploration avant la solution.
