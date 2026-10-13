# skills

Mes skills d'agent (Claude Code et Codex), génériques et réutilisables dans n'importe quel projet,
plus de quoi **générer les skills propres à un projet** avec `/init-skills`.

Les skills d'ici ne contiennent rien de spécifique à un projet. Ce qui décrit un projet donné
(commandes, routes, base de données, conventions) est généré **dans ce projet**, à partir des
templates, et y reste.

```
skills/      skills génériques, installés globalement (symlinks)
templates/   patterns extraits de projets réels, que /init-skills remplit pour un projet donné
install.sh   lie chaque skill dans ~/.claude/skills et ~/.codex/skills
```

## Installation

```bash
git clone git@github.com:yuhec/skills.git ~/code/skills
~/code/skills/install.sh            # symlinks dans ~/.claude/skills et ~/.codex/skills
~/code/skills/install.sh --force    # remplace les copies existantes (sauvegardées en <nom>.bak-<date>)
```

Les symlinks font qu'un `git pull` met tout à jour. Un skill déjà présent en copie (non symlink)
n'est pas écrasé sans `--force`.

## Démarrer un projet

Dans le projet : `/init-skills`. Il détecte la stack, propose les skills à générer, pose les
quelques questions que le code ne tranche pas, génère dans `.claude/skills/`, **exécute chaque
commande écrite** pour prouver les skills, puis fait un rapport. Rien n'est commité : tu relis le
diff.

## Skills

| Skill | Appel | À quoi il sert | Étapes |
|---|---|---|---|
| `init-skills` | `/init-skills`, « initialise les skills de ce projet » | Équiper un projet de ses propres skills, prouvés, à partir des templates | 1. Inventaire de l'existant · 2. Détection en parallèle (stack/runner, tests, git/CI, runtime) · 3. Tableau de proposition, attente du go · 4. Questions sur les trous · 5. Génération depuis les templates · 6. Preuve : chaque commande exécutée · 7. Branchement (fichier de règles, Codex) · 8. Rapport proven/draft |
| `reviewing-code` | « review mon code », « relis la branche X », « review la PR 123 » ; modes `quick` · `full` · `adversarial` · `fix` | L'unique skill de code review : diff confronté au reste du codebase et au ticket, chaque finding re-vérifié dans le code | 1. Périmètre (non commité, branche, PR) et base · 2. Contexte : préférences perso, `.claude/review-rules.md`, règles du repo, ticket + parent + sœurs · 3. Lecture complète des fichiers (artefacts générés en diff seulement) · 4. Lentilles : correction, réutilisation/design, qualité, tests, sécurité (en sous-agents si gros diff) + Codex en `adversarial` · 5. Re-vérification de chaque finding, faux positifs écartés · 6. Rapport 🔴🟡🟢✅ + « À trancher » · 7. En `fix` : corrections sûres + gate rapide |
| `grill-me` | `/grill-me`, « grill-moi sur ce plan » | Stress-tester un plan ou une décision par un interrogatoire en rondes | 1. Arbre de décisions · 2. Ronde = toutes les questions débloquées, numérotées, avec ma recommandation · 3. Les faits sont cherchés par sous-agents, jamais demandés · 4. Recalcul de la frontière · 5. Fin quand plus rien n'est implicite |
| `brainstorming` | « je veux brainstormer », « mode brainstorm » | Explorer un problème avant toute solution | 1. Compréhension par questions ouvertes (2-3 max) · 2. Intégrer doutes et objections · 3. Checkpoint de reformulation · 4. 2-3 directions + trade-offs · 5. Go explicite avant le plan détaillé |
| `sum-up` | `/sum-up <branche>`, « résume cette PR » | S'approprier une branche/PR : schéma, pas prose | 1. Lire le vrai diff vs la base · 2. Une ligne de valeur · 3. Fichiers par rôle · 4. Flux avec données à chaque étape · 5. Comportement par mode · 6. Les « pourquoi » non évidents · 7. Autres points d'entrée |
| `pr-comments` | `/pr-comments <n>`, « ces commentaires sont pertinents ? » | Trier les commentaires de review en tableau de verdicts, sans toucher au code | 1. Récupérer tous les commentaires (threads groupés, bots filtrés) · 2. Juger contre le code à la tête de PR, les règles et les décisions prises · 3. Tableau Oui/Partiellement/Non/À trancher · 4. Décisions à prendre et ordre d'application |
| `writing-manual-test-scenarios` | « plan de recette », « comment je teste cette PR » | Scénarios de test manuels courts pour une PR | 1. Lire le diff et le ticket · 2. Remonter chaque changement jusqu'à un écran (appelants inclus) · 3. Happy path · 4. Non-régression des zones impactées · 5. Cas tordus tirés du diff · 6. « Non couvert » explicite |
| `explain-diff-html` | « explique ce diff en HTML » | Page HTML autonome et pédagogique sur un changement, avec quiz | 1. Cerner le changement · 2. Explorer le code autour · 3. Récit : contexte → intuition → code · 4. Page unique sans dépendance externe · 5. Quiz de 5 questions équilibré · 6. Validation et lien |
| `capturing-task-lessons` | « fais une rétro », « capture ce qu'on a appris » | Transformer une session longue en leçons routées vers la bonne couche | 1. Trouver le transcript (worktrees inclus) · 2. Trois relecteurs en parallèle : jugement, outillage (Codex), divergent · 3. Synthèse Accepted/Rejected/Backlog · 4. Préférer un mécanisme (type, garde, lint, test) à une phrase · 5. Attendre ton choix · 6. Appliquer · 7. Résumé |
| `logging-decision-trails` | « garde une trace », « show me your work » | Journal TSV append-only des décisions d'un long run, audité avant restitution | 1. Une ligne par décision (quoi, pourquoi, preuve, résultat) via `log.sh` · 2. Hors git · 3. Audit du journal contre le transcript · 4. Relecture par un autre modèle · 5. Section « Attention » |
| `evaluating-skill-changes` | « ce skill sert vraiment ? », « compare les deux versions » | Mesurer en A/B aveugle si une modif de skill change le comportement des agents | 1. Lire les deux bras · 2. Grille de 3-6 critères · 3. Environnements isolés et neutres · 4. Prompt organique unique · 5. Candidats Claude + Codex en parallèle · 6. Juge aveugle · 7. Vérification par transcripts · 8. Recommandation |
| `delegating-to-codex` | « délègue à codex », « codex luna / sol » | Déléguer à Codex proprement : bon modèle, sandbox, cwd épinglé | 1. Rendre la commande d'abord · 2. Petit modèle / grand modèle · 3. `codex exec -C <worktree>` + sandbox ouverte au toolchain · 4. `< /dev/null` · 5. Gates rapides pour Codex, gates complets pour toi · 6. Ne pas croire un vert délégué |
| `creating-verification-skills` | « aucun moyen de vérifier que ça marche vraiment » | Générer le skill `verifying-<surface>` d'un service : lancer, piloter, prouver | 1. Vérifier qu'aucun n'existe · 2. Interroger le repo (surface, lancement, pilotage, auth, observation, isolation prouvée) · 3. Générer depuis le template · 4. Carte des fonctionnalités · 5. Run de preuve complet · 6. Renvoi vers la maintenance |
| `maintaining-verification-skills` | « le skill de vérif est à jour ? » | Auditer un `verifying-*` contre le service réel, livrer une PR de corrections prouvées | 1. Hygiène de l'index · 2. Vague source : un sous-agent par fonctionnalité · 3. Réconciliation · 4. Passe live obligatoire (doctor, preuves conservées) · 5. Tri : doc / harnais / produit · 6. clean / changed / blocked |

## Templates

Utilisés par `/init-skills` (et `creating-verification-skills`), jamais installés tels quels. Le
contrat d'un template est dans [`templates/README.md`](templates/README.md).

| Template | Génère | Ce qu'il détecte |
|---|---|---|
| [`task-runner-and-tests`](templates/task-runner-and-tests/TEMPLATE.md) | `running-tasks`, `testing`, optionnel `writing-tests` | runner (moon, nx, make, npm…), gates exactes de la CI, boucle rapide, cache, infra de test, fichiers ignorés nécessaires à un checkout neuf, artefacts générés |
| [`git-and-pr`](templates/git-and-pr/TEMPLATE.md) | `pre-pr`, `syncing-branches`, `shipping-a-ticket`, `.claude/review-rules.md` (règles projet lues par `reviewing-code`), optionnels `placing-changelog-fragments`, `stacking-branches` | branche de base, conventions de branche/commit, outil de tickets, template et langue des PR, jobs CI et checks de fraîcheur, migrations, fragments, PR empilées |
| [`verification`](templates/verification/TEMPLATE.md) | `verifying-<surface>` + carte des fonctionnalités + `doctor` | services lançables, ports/hostnames, auth locale, état observable, isolation, dépendances payantes |

## Origine

Extrait et généralisé à partir des skills que j'utilise au quotidien. Plusieurs skills sont portés
de [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack) (Lauren Tan, MIT) —
la provenance est indiquée dans chacun.
