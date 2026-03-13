/// Constantes de textes pour l'application SunuTask
class AppStrings {
  AppStrings._();

  // Général
  static const String appName = 'SunuTask';
  static const String tagline = 'Gérez vos projets efficacement';

  // Onboarding
  static const String onboarding1Title = 'Organisez vos projets';
  static const String onboarding1Subtitle =
      'Créez et gérez tous vos projets en un seul endroit. Restez organisé et productif.';

  static const String onboarding2Title = 'Suivez vos tâches';
  static const String onboarding2Subtitle =
      'Créez des tâches, définissez des priorités et suivez l\'avancement de chaque projet.';

  static const String onboarding3Title = 'Collaborez ensemble';
  static const String onboarding3Subtitle =
      'Travaillez en équipe, ajoutez des commentaires et restez synchronisé avec votre équipe.';

  static const String getStarted = 'Commencer';
  static const String next = 'Suivant';
  static const String skip = 'Passer';

  // Authentification
  static const String login = 'Se connecter';
  static const String register = 'S\'inscrire';
  static const String logout = 'Déconnexion';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String confirmPassword = 'Confirmer le mot de passe';
  static const String name = 'Nom complet';
  static const String noAccount = 'Pas de compte ? S\'inscrire';
  static const String hasAccount = 'Déjà un compte ? Se connecter';
  static const String forgotPassword = 'Mot de passe oublié ?';

  // Validation
  static const String fieldRequired = 'Ce champ est obligatoire';
  static const String emailInvalid = 'Email invalide';
  static const String passwordMin = 'Minimum 6 caractères';
  static const String nameMin = 'Minimum 2 caractères';
  static const String passwordMismatch = 'Les mots de passe ne correspondent pas';
  static const String emailExists = 'Cet email est déjà utilisé';
  static const String invalidCredentials = 'Email ou mot de passe incorrect';

  // Navigation
  static const String dashboard = 'Tableau de bord';
  static const String projects = 'Projets';
  static const String tasks = 'Tâches';
  static const String profile = 'Profil';

  // Projets
  static const String newProject = 'Nouveau projet';
  static const String editProject = 'Modifier le projet';
  static const String deleteProject = 'Supprimer le projet';
  static const String projectName = 'Nom du projet';
  static const String projectDescription = 'Description';
  static const String projectColor = 'Couleur du projet';
  static const String noProjects = 'Aucun projet';
  static const String noProjectsSubtitle = 'Créez votre premier projet pour commencer';
  static const String createProject = 'Créer un projet';
  static const String projectDetails = 'Détails du projet';
  static const String deleteProjectConfirm =
      'Supprimer ce projet supprimera aussi toutes ses tâches. Cette action est irréversible.';

  // Tâches
  static const String newTask = 'Nouvelle tâche';
  static const String editTask = 'Modifier la tâche';
  static const String deleteTask = 'Supprimer la tâche';
  static const String taskTitle = 'Titre de la tâche';
  static const String taskDescription = 'Description (optionnel)';
  static const String taskStatus = 'Statut';
  static const String taskPriority = 'Priorité';
  static const String taskDueDate = 'Date d\'échéance';
  static const String noTasks = 'Aucune tâche';
  static const String noTasksSubtitle = 'Ajoutez une tâche à ce projet';
  static const String deleteTaskConfirm =
      'Êtes-vous sûr de vouloir supprimer cette tâche ?';

  // Statuts
  static const String statusTodo = 'À faire';
  static const String statusInProgress = 'En cours';
  static const String statusDone = 'Terminée';

  // Priorités
  static const String priorityHigh = 'Haute';
  static const String priorityMedium = 'Moyenne';
  static const String priorityLow = 'Basse';

  // Commentaires
  static const String comments = 'Commentaires';
  static const String addComment = 'Ajouter un commentaire';
  static const String commentHint = 'Écrire un commentaire…';
  static const String noComments = 'Aucun commentaire';
  static const String noCommentsSubtitle = 'Soyez le premier à commenter';
  static const String deleteComment = 'Supprimer le commentaire';

  // Profil
  static const String myProfile = 'Mon profil';
  static const String editProfile = 'Modifier le profil';
  static const String memberSince = 'Membre depuis';
  static const String myStats = 'Mes statistiques';

  // Dashboard
  static const String welcomeMorning = 'Bonjour';
  static const String welcomeAfternoon = 'Bon après-midi';
  static const String welcomeEvening = 'Bonsoir';
  static const String recentProjects = 'Projets récents';
  static const String statistics = 'Statistiques';
  static const String totalProjects = 'Projets';
  static const String todoTasks = 'À faire';
  static const String inProgressTasks = 'En cours';
  static const String doneTasks = 'Terminées';

  // Actions
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String save = 'Enregistrer';
  static const String create = 'Créer';
  static const String edit = 'Modifier';
  static const String delete = 'Supprimer';
  static const String search = 'Rechercher';
  static const String filter = 'Filtrer';
  static const String clearFilters = 'Effacer les filtres';
  static const String refresh = 'Actualiser';
  static const String preview = 'Aperçu';

  // Messages
  static const String projectCreated = 'Projet créé avec succès';
  static const String projectUpdated = 'Projet mis à jour';
  static const String projectDeleted = 'Projet supprimé';
  static const String taskCreated = 'Tâche créée avec succès';
  static const String taskUpdated = 'Tâche mise à jour';
  static const String taskDeleted = 'Tâche supprimée';
  static const String commentAdded = 'Commentaire ajouté';
  static const String commentDeleted = 'Commentaire supprimé';
  static const String profileUpdated = 'Profil mis à jour';
}
