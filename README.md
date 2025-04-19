# Déploiement Kubernetes : Rolling Updates & Stratégie Blue-Green

## Projet Universitaire DevOps

Ce projet démontre les stratégies de déploiement Kubernetes, spécifiquement **Rolling Updates** et **Blue-Green Deployment**, en utilisant des outils open-source. Il inclut Docker pour la conteneurisation, Minikube pour un cluster Kubernetes local, et GitHub Actions pour la simulation CI/CD. En raison des contraintes d'abonnement Azure, le projet a été réalisé localement, avec une simulation manuelle CI/CD et une utilisation locale de Git au lieu d'une collaboration basée sur le cloud. L'application est testée sur les ports 8083 (Blue-Green) et 8084 (Rolling Updates avec CI/CD).

---

## Structure du Projet

Le projet est organisé dans le dossier `deployment-demo` :

- **Racine (**`deployment-demo`**)** :
  - `index.html` : Contenu de l'application web.
  - `Dockerfile` : Configuration de l'image Docker.
  - `README.md` : Ce fichier de documentation.
  - `update-locally.sh` : Script pour les mises à jour locales du déploiement.
  - `test.sh` : Script pour les tests automatisés.
- **Sous-dossier (**`kubernetes`**)** :
  - `myapp-blue.yaml` : Configuration du déploiement Blue (version 1).
  - `myapp-green.yaml` : Configuration du déploiement Green (version 2).
  - `rolling-deployment.yaml` : Configuration du déploiement Rolling Update et du service.
  - `service.yaml` : Configuration du service pour les déploiements Blue-Green.
- **Sous-dossier (**`.github/workflows`**)** :
  - `deploy.yml` : Workflow GitHub Actions pour la simulation CI/CD.

---

## Pile Technologique

- **Système d'exploitation** : Windows 10 Pro
- **Conteneurisation** : Docker Desktop
- **Kubernetes** : Minikube (v1.35.0, Kubernetes v1.32.0)
- **CI/CD** : GitHub Actions (simulé localement)
- **Contrôle de version** : Git (dépôt local)
- **Registre d'images** : Docker Hub (`docker.io/20031114/myapp:v1`, `v2`)
- **Scripting** : Bash (via Git Bash pour Windows)

---

## Images Docker

Les images sont disponibles sur Docker Hub :

- `docker.io/20031114/myapp:v1` (SHA : `e2b0464769d2e97dfaf80c98d28f0f8ca9415315eaaa783853258591d63512c5`)
- `docker.io/20031114/myapp:v2` (SHA : `5784ee7789ee89a31f806775e054ac6d1d7086c44bfcea590ed41647bbee9fe5`)

---

## Instructions de Configuration

### Prérequis

1. Installer **Docker Desktop** sur Windows 10 Pro.
2. Installer **Minikube** (`v1.35.0`).
3. Installer **Git Bash** pour exécuter les scripts Bash.
4. S'assurer que `kubectl` est configuré pour interagir avec Minikube.

### Étape 1 : Démarrer Minikube

```bash
minikube start --driver=docker
```

- Vérifie : Crée un cluster Kubernetes local avec 2 CPU, 4000 Mo de mémoire, et les addons (`default-storageclass`, `storage-provisioner`).
- Dépannage : En cas d'erreurs de tunnel SSH (par exemple, demandes de mot de passe), redémarrez Minikube ou utilisez `kubectl port-forward`.

### Étape 2 : Construire et Pousser les Images Docker

1. Construire les images :

```bash
docker build -t 20031114/myapp:v1 .
docker build -t 20031114/myapp:v2 .
```

2. Pousser vers Docker Hub :

```bash
docker push 20031114/myapp:v1
docker push 20031114/myapp:v2
```

---

## Instructions de Déploiement

### Rolling Updates

1. **Déployer l'Application (v1)** :

```bash
kubectl apply -f kubernetes/rolling-deployment.yaml
```

- Crée le déploiement `myapp` avec 3 réplicas et l'image `20031114/myapp:v1`, ainsi qu'un service `LoadBalancer` `myapp-service`.

2. **Accéder à l'Application** :

```bash
kubectl port-forward service/myapp-service 8084:80
```

- Ouvre `http://localhost:8084` pour vérifier l'application.

3. **Effectuer une Mise à Jour Rolling vers v2** :

```bash
kubectl set image deployment/myapp myapp=20031114/myapp:v2
kubectl rollout status deployment/myapp
```

- Vérifie : Met à jour les pods vers `v2` sans interruption (`maxSurge: 1`, `maxUnavailable: 1`).

4. **Rollback (si nécessaire)** :

```bash
kubectl rollout undo deployment/myapp
kubectl rollout status deployment/myapp
```

- Revient à `v1`.

5. **Tester avec un SHA d'Image Spécifique** :

```bash
kubectl set image deployment/myapp myapp=20031114/myapp:3d61d2e63da2f341c7e5ab68066ff67e491dbab3
kubectl rollout status deployment/myapp
```

### Déploiement Blue-Green

1. **Déployer les Environnements Blue et Green** :

```bash
kubectl apply -f kubernetes/myapp-blue.yaml
kubectl apply -f kubernetes/myapp-green.yaml
```

- Crée les déploiements `myapp-blue` (v1) et `myapp-green` (v2), chacun avec 3 réplicas.

2. **Appliquer le Service** :

```bash
kubectl apply -f kubernetes/service.yaml
```

- Crée `myapp-service` avec le sélecteur `app: myapp, version: blue`.

3. **Accéder à l'Environnement Blue** :

```bash
kubectl port-forward service/myapp-service 8083:80
```

- Ouvre `http://localhost:8083` pour vérifier le contenu "Version 1".

4. **Bascule vers l'Environnement Green** :

```bash
kubectl edit svc myapp-service
```

- Change le sélecteur à `version: green` et enregistre.
- Vérifie avec `curl http://localhost:8083`, attendant "Version 2: Hello, Green !".

5. **Vérifier les Déploiements et Pods** :

```bash
kubectl get deployments
kubectl get pods
```

- Exemple de sortie :

```
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
myapp-blue    3/3     3            3           69s
myapp-green   3/3     3            3           44s
```

```
NAME                           READY   STATUS    RESTARTS   AGE
myapp-blue-6666c56869-842wg    1/1     Running   0          53s
myapp-green-5bf49b6b77-45t6v   1/1     Running   0          28s
```

---

## Simulation CI/CD

### Workflow GitHub Actions

Le fichier `deploy.yml` dans `.github/workflows` définit un pipeline CI/CD :

- Déclenché lors d'un push sur la branche `main`.
- Construit et pousse les images Docker vers Docker Hub avec des tags SHA.
- Simule le déploiement Kubernetes (Minikube local inaccessible).

**Note** : En raison de la nature locale de Minikube, le déploiement est simulé manuellement avec `update-locally.sh`.

### Mise à Jour du Déploiement Local

1. Rendre les scripts exécutables (dans Git Bash) :

```bash
chmod +x update-locally.sh
```

2. Exécuter la mise à jour avec un SHA d'image :

```bash
./update-locally.sh 3d61d2e63da2f341c7e5ab68066ff67e491dbab3
```

- Tire l'image, met à jour le déploiement, surveille le rollout, et redirige le port vers `localhost:8084`.
- Exemple de sortie :

```
Pulling latest image: 20031114/myapp:3d61d2e63da2f341c7e5ab68066ff67e491dbab3 ...
deployment "myapp" successfully rolled out
```

---

## Tests Automatisés

1. Rendre le script de test exécutable :

```bash
chmod +x test.sh
```

2. Exécuter le test (après redirection vers 8084) :

```bash
./test.sh
```

- Vérifie la présence de "Version" dans la réponse de `http://localhost:8084`.
- Exemple de sortie :

```
Running app test...
App responds with version message
```

- Dépannage : Assurez-vous que `kubectl port-forward service/myapp-service 8084:80` est actif.

---

## Contrôle de Version

- **Dépôt Git Local** :
  - Initialisé avec `git init` dans `deployment-demo`.
  - Validé les modifications avec `git add .` et `git commit -m "message"`.
- **Limitation de Collaboration** : Git basé sur le cloud (par exemple, GitHub) non utilisé en raison de la configuration locale. Collaboration simulée via des commits locaux et un journal des modifications dans `README.md`.

---

## Exploration du Déploiement Cloud

- **Tentative Azure** : Prévu d'utiliser Azure Kubernetes Service (AKS), mais le compte universitaire manquait d'accès à l'abonnement.
- **Alternative Locale** : Minikube a reproduit les fonctionnalités de Kubernetes.
- **Justification** : Les outils open-source et la simulation manuelle CI/CD ont atteint les objectifs du projet, assurant la reproductibilité.

---

## Dépannage

- **Problèmes de Tunnel Minikube** : Délais d'attente SSH/demandes de mot de passe résolus en redémarrant Minikube ou en utilisant `kubectl port-forward`.
- **Conflits de Ports** : Vérifié que les ports 8083/8084 étaient libres avant la redirection.
- **Erreurs de Sélecteur** : Corrigé les problèmes de sélecteur immuable en supprimant et réappliquant les déploiements (`kubectl delete deployment myapp-blue`).
- **Exécution de Scripts** : Utilisé Git Bash pour `chmod` et l'exécution des scripts, car CMD Windows échouait (`chmod not recognized`).

---

## Références

- Documentation Minikube : https://minikube.sigs.k8s.io/docs/
- Documentation Kubernetes : https://kubernetes.io/docs/
- Documentation Docker : https://docs.docker.com/
- GitHub Actions : https://docs.github.com/fr/actions