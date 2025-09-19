# 🔐 Configuration des Environments GitHub pour Repository Privé

## 🎯 Pourquoi les Environments ?

Pour un repository **privé/secret**, l'utilisation d'**environments GitHub** est une bonne pratique de sécurité qui permet :

- 🔐 **Isolation des secrets** : Variables sensibles isolées par environnement
- 🛡️ **Contrôle d'accès** : Restrictions sur qui peut déclencher les déploiements
- 📊 **Audit et traçabilité** : Historique des déploiements par environnement
- ⏸️ **Protection des déploiements** : Approbations manuelles si nécessaire

## 🏗️ Configuration Requise

### 1. Créer l'Environment GitHub

1. **Navigation** : Repository → Settings → Environments
2. **Création** : Click "New environment"
3. **Nom** : `production`
4. **Configuration** : Voir sections ci-dessous

### 2. Variables d'Environment (`vars`)

Configurer dans l'environment `production` :

| Variable | Valeur par défaut | Description |
|----------|-------------------|-------------|
| `REGISTRY` | `ghcr.io` | Registre Docker à utiliser |
| `REGISTRY_PREFIX` | `ghcr.io/titom73` | Préfixe pour noms d'images |
| `REGISTRY_USERNAME` | `${{ github.actor }}` | Nom d'utilisateur registry |
| `CLEANUP_KEEP_VERSIONS` | `10` | Nombre de versions à conserver |

### 3. Secrets d'Environment (`secrets`)

Configurer dans l'environment `production` :

| Secret | Description | Requis |
|--------|-------------|---------|
| `REGISTRY_TOKEN` | Token d'accès au registre Docker | ✅ |

> **Note** : Si `REGISTRY_TOKEN` n'est pas défini, `GITHUB_TOKEN` sera utilisé par défaut.

## 🔧 Configuration Détaillée

### GitHub Container Registry (GHCR)

Si vous utilisez GitHub Container Registry (recommandé) :

```yaml
# Variables d'environment
REGISTRY=ghcr.io
REGISTRY_PREFIX=ghcr.io/your-username
REGISTRY_USERNAME=your-username

# Secrets d'environment
REGISTRY_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx  # Personal Access Token GitHub
```

**Création du Personal Access Token** :
1. GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Permissions requises :
   - `Contents: Read`
   - `Packages: Write`
   - `Metadata: Read`

### Harbor Registry

Si vous utilisez Harbor ou un autre registry :

```yaml
# Variables d'environment
REGISTRY=harbor.your-company.com
REGISTRY_PREFIX=harbor.your-company.com/docker-network-toolkit
REGISTRY_USERNAME=your-harbor-username

# Secrets d'environment
REGISTRY_TOKEN=your-harbor-password-or-token
```

### Docker Hub

Si vous utilisez Docker Hub :

```yaml
# Variables d'environment
REGISTRY=docker.io
REGISTRY_PREFIX=docker.io/your-dockerhub-username
REGISTRY_USERNAME=your-dockerhub-username

# Secrets d'environment
REGISTRY_TOKEN=your-dockerhub-access-token
```

## 🚦 Règles de Protection (Optionnelles)

Pour sécuriser davantage l'environment `production` :

### Protection Branches
- **Required reviewers** : 1-2 personnes
- **Wait timer** : 0-30 minutes avant déploiement
- **Required branches** : `main` uniquement

### Environment Rules
```yaml
# Dans l'interface GitHub
Environment name: production
Environment protection rules:
  ✅ Required reviewers: 1
  ✅ Deployment branches: Selected branches (main)
  ⚠️ Wait timer: 0 minutes (optionnel)
```

## 🔄 Fallback et Compatibilité

Les workflows sont conçus avec des **fallbacks** pour maintenir la compatibilité :

```yaml
# Si la variable d'environment n'existe pas, utilise la valeur par défaut
registry: ${{ vars.REGISTRY || env.REGISTRY }}
username: ${{ vars.REGISTRY_USERNAME || github.actor }}
token: ${{ secrets.REGISTRY_TOKEN || secrets.GITHUB_TOKEN }}
```

## 📋 Checklist de Configuration

### ✅ Étapes de Configuration

1. **Environment Creation**
   - [ ] Créer environment `production` dans GitHub
   - [ ] Configurer les variables d'environment
   - [ ] Ajouter les secrets nécessaires

2. **Registry Setup**
   - [ ] Choisir le registre Docker (GHCR/Harbor/Docker Hub)
   - [ ] Créer token d'accès approprié
   - [ ] Tester l'authentification manuellement

3. **Workflow Testing**
   - [ ] Déclencher un build de test
   - [ ] Vérifier les permissions d'environment
   - [ ] Valider le push des images

4. **Security Review**
   - [ ] Vérifier les permissions minimales
   - [ ] Configurer les règles de protection si nécessaire
   - [ ] Auditer les accès à l'environment

## 🛠️ Commandes de Test

### Test Local du Registry
```bash
# Test d'authentification
echo $REGISTRY_TOKEN | docker login $REGISTRY -u $REGISTRY_USERNAME --password-stdin

# Test de push
docker tag alpine:latest $REGISTRY_PREFIX/test:latest
docker push $REGISTRY_PREFIX/test:latest

# Nettoyage
docker rmi $REGISTRY_PREFIX/test:latest
```

### Test des Variables
```bash
# Simulation des variables d'environment
export REGISTRY="ghcr.io"
export REGISTRY_PREFIX="ghcr.io/titom73"
export REGISTRY_USERNAME="titom73"

# Test avec le Makefile
make build PROJECT=multitool REGISTRY_PREFIX=$REGISTRY_PREFIX --dry-run
```

## 🚨 Sécurité et Bonnes Pratiques

### ✅ Do's
- ✅ Utiliser des tokens avec permissions minimales
- ✅ Configurer l'expiration des tokens
- ✅ Séparer les environments (dev/staging/prod)
- ✅ Auditer régulièrement les accès
- ✅ Utiliser des secrets d'environment, pas des secrets de repository

### ❌ Don'ts
- ❌ Stocker des secrets dans le code source
- ❌ Utiliser des tokens avec permissions excessives
- ❌ Partager les secrets entre environments
- ❌ Ignorer les logs d'audit

## 🔍 Dépannage

### Erreurs Communes

**Error**: `authentication required`
- **Solution** : Vérifier `REGISTRY_TOKEN` et `REGISTRY_USERNAME`

**Error**: `forbidden: insufficient_scope`
- **Solution** : Vérifier les permissions du token

**Error**: `environment not found`
- **Solution** : S'assurer que l'environment `production` est créé

**Error**: `secret not found`
- **Solution** : Vérifier que `REGISTRY_TOKEN` est défini dans l'environment

### Logs de Debug
```yaml
# Ajouter temporairement dans les workflows pour debug
- name: Debug Environment
  run: |
    echo "Registry: ${{ vars.REGISTRY || env.REGISTRY }}"
    echo "Registry Prefix: ${{ vars.REGISTRY_PREFIX || env.REGISTRY_PREFIX }}"
    echo "Username: ${{ vars.REGISTRY_USERNAME || github.actor }}"
    echo "Token set: ${{ secrets.REGISTRY_TOKEN != '' }}"
```

Cette configuration assure une gestion sécurisée et flexible des credentials pour un repository privé ! 🔐