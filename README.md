# Projet Flutter DevMobile

Ce référentiel contient une application mobile développée dans Flutter ainsi qu'un serveur backend construit avec FastAPI. Le serveur backend gère les requêtes API pour l'application et utilise un ensemble de dépendances spécifiées dans `requirements.txt`.

## Table des matières
- [Structure du projet](#project-structure)
- [Prérequis](#prerequis)
- [Installation](#installation)
- [Exécution du serveur backend](#running-the-backend-server)
- [Exécution de l'application Flutter](#running-the-flutter-application)
- [Test de l'application](#testing-the-application)
- [Dépannage](#troubleshooting)

---

## Structure du projet

Les principaux dossiers et fichiers de ce projet incluent :
- `flutter_application/` : contient tout le code de l'application Flutter.
- `requirements.txt` : répertorie les dépendances Python pour le backend FastAPI.
- `README.md` : documentation du projet (ce fichier).

## Prérequis

Pour exécuter et tester cette application, assurez-vous que les éléments suivants sont installés :

- **Flutter** : suivez le [guide d'installation de Flutter](https://flutter.dev/docs/get-started/install) pour votre système d'exploitation.
- **Python 3.7+** : requis pour exécuter le backend FastAPI.
- **pip** : programme d'installation de package Python (fourni avec Python).
- **Git** : contrôle de version pour cloner le référentiel.

## Installation

### 1. Cloner le référentiel

```bash
git clone https://github.com/Linhkobe/Flutter-DevMobile.git
cd Flutter-DevMobile
```

### 2. Démarrer python backend

#### 2.1 Création de l'environnement virtuel de python

```bash
python -m venv venv
```

#### 2.2 Activez l'environnement virtuel de python

```bash
venv\Scrips\activate
``` 

#### 2.3 installer les dépendences de python

```bash
pip install -r requirements.txt 
```

#### 2.4 Lancement de fastapi (Ouvrez cmd - Invite de commandes)

#### 2.4.1 Naviguez en suivant ce chemin vers le projet

```bash
cd C:\Users\admin\OneDrive\Documents\dev_mobile\Flutter-DevMobile\flutter_application 
```
#### 2.4.2 Lancez le server
```bash
uvicorn app:app --reload
```

### 3. Lancement de flutter application

#### 3.1 Naviguez vers répertoire "flutter_application" du projet
```bash
cd flutter_application
```

#### 3.2 Installer les dépendences de flutter
```bash
flutter pub get 
```

#### 3.3 Lancer l'application
```bash
flutter run
```