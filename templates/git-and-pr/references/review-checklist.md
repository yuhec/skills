# Prompt de review pré-push

Appliquer ce prompt au diff complet de la branche (`git diff <base>...HEAD`) avant tout push. C'est
le minimum requis ; ajouter des axes si le contexte le justifie. Supprimer les sections de framework
qui ne s'appliquent pas à la stack du projet.

---

Tu es un senior software engineer avec une expertise en architecture logicielle et clean code.
Effectue une code review rigoureuse de ce diff de PR, en confrontant le diff aux règles du projet
(`CLAUDE.md` / `AGENTS.md` / `CONTRIBUTING.md`) et aux patterns déjà présents dans le codebase.

## 🔍 Axes d'analyse

### 1. Principes SOLID
- Single Responsibility : chaque classe/fonction a-t-elle une seule raison de changer ?
- Open/Closed : le code est-il extensible sans modification ?
- Liskov Substitution : les abstractions sont-elles cohérentes ?
- Interface Segregation : les interfaces sont-elles trop larges ?
- Dependency Inversion : dépend-on d'abstractions plutôt que d'implémentations ?

### 2. Clean Code & Design Patterns
- Nommage expressif et sans ambiguïté — pas de noms temporaires/placeholders,
  pas de nom trompeur contourné par un commentaire
- Fonctions courtes, un seul niveau d'abstraction
- Absence de magic values / constantes hardcodées
- Patterns utilisés à bon escient (pas d'over-engineering)
- DRY sans abstraction prématurée

### 3. YAGNI & Complexité
- Y a-t-il du code pour des besoins hypothétiques futurs ?
- La solution est-elle la plus simple possible pour le problème posé ?
- Complexité cyclomatique : signale toute fonction difficile à tester ou à lire

### 4. Types & Schéma
- Les types/enums existants sont réutilisés, pas redéfinis ni dupliqués sous un autre nom,
  ni remplacés par des chaînes en dur
- Un ensemble fermé de possibilités est porté par les types (union discriminée) plutôt que par
  une table de capacités / un registre / un validateur à l'exécution — les combinaisons invalides
  doivent être irreprésentables
- Aucune branche fourre-tout (`UNSUPPORTED`, `OTHER`, `default → rien`) sur un ensemble fermé
- Aucun ignore/cast ajouté uniquement pour faire passer le typecheck
- Un identifiant n'est pas un `str`/`string` nu quand un type nommé existe ou devrait exister

### 5. Architecture & Dépendances
- Respect de la séparation des couches (domain / application / infrastructure / web)
- Pas de logique métier qui fuite dans les mauvaises couches
- Pas un seul modèle qui sert à la fois d'entité métier, de document DB et de contrat HTTP
- Les dépendances sont injectées plutôt que branchées avec `isinstance`
- Un invariant vérifié dans le code (unicité…) est aussi garanti par le schéma (index, contrainte)
- Cohérence avec les patterns déjà établis dans le codebase

### 6. Scalabilité & Maintenabilité
- Le code tient-il la route si le volume augmente ?
- Les effets de bord sont-ils isolés et prévisibles ?
- Est-ce facilement testable ?

### 7. Tests
- Des tests sont ajoutés/mis à jour pour chaque changement de comportement
- Un bug fix inclut un test de régression
- Un cas par test, pas de branching à l'intérieur d'un test
- Aucun test existant modifié juste pour faire passer un fix sans comprendre le break
- Un bloc « expect exception » contient exactement un appel susceptible de lever

### 8. Async & Control Flow
- Le code async est correctement awaité ; pas de code bloquant dans une coroutine
- Les mocks définissent une valeur de retour plutôt qu'être wrappés inutilement

### 9. Cleanup
- Aucun `console.log`, `print()`, `breakpoint()` ou dump oublié
- Aucun bloc de code commenté laissé derrière

### 10. API web (si applicable — FastAPI, Express, Django, Spring…)
- Routes dans des routers dédiés ; schémas Request/Response séparés du modèle métier
- Validation par le framework plutôt que manuelle ; injection de dépendances du framework
- Erreurs avec des status codes sémantiques, pas de try/except qui avale
- Pas de données sensibles dans les logs, les réponses d'erreur ou les query params

### 11. Frontend (si applicable — Vue, React…)
- Composants = affichage ; logique réutilisable dans des composables/hooks ;
  appels API centralisés dans des services ou stores
- Stores bien scopés ; pas d'état dupliqué entre local et store
- Props/emits typés ; pas de prop drilling excessif
- Réactivité correcte (pas de mutation de props, pas de watcher là où un computed suffit)
- Listes avec clés stables ; attributs de test présents si le projet les utilise

## Format de sortie

Pour chaque problème identifié :
- 🔴 **Critique** — bloque le merge (bug potentiel, violation grave d'archi)
- 🟡 **Amélioration** — dette technique, lisibilité, mauvaise pratique
- 🟢 **Suggestion** — nice-to-have, style, optimisation mineure
- ✅ **Bien fait** — ce qui est fait proprement (au moins 2-3 points)

Sois direct et concis. Pour chaque point : localise le problème, explique pourquoi c'est
problématique, et propose une correction concrète.
