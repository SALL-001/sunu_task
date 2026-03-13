import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/cards/project_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Écran de création / modification d'un projet
class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;

  const ProjectFormScreen({
    super.key,
    this.project,
    required this.authProvider,
    required this.projectProvider,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Color _selectedColor = AppColors.projectColors.first;
  bool _isLoading = false;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.project!.name;
      _descCtrl.text = widget.project!.description;
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updated = widget.project!.copyWith(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          color: _selectedColor,
          updatedAt: DateTime.now(),
        );
        await widget.projectProvider.updateProject(updated);
      } else {
        final project = Project(
          id: const Uuid().v4(),
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          color: _selectedColor,
          ownerId: widget.authProvider.currentUser!.id,
          createdAt: DateTime.now(),
        );
        await widget.projectProvider.createProject(project);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Projet mis à jour ✓' : 'Projet créé avec succès ✓'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le projet' : 'Nouveau projet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Nom du projet',
                controller: _nameCtrl,
                hint: 'Mon super projet',
                prefixIcon: Icons.folder_outlined,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nom obligatoire';
                  if (value.trim().length < 3) return 'Minimum 3 caractères';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Description (optionnel)',
                controller: _descCtrl,
                hint: 'Décrivez votre projet…',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 24),

              Text('Couleur du projet', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppColors.projectColors.map((c) {
                  final selected = _selectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected ? 44 : 38,
                      height: selected ? 44 : 38,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: selected
                            ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              Text('Aperçu', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ProjectCard(
                project: Project(
                  id: 'preview',
                  name: _nameCtrl.text.isEmpty ? 'Nom du projet' : _nameCtrl.text,
                  description: _descCtrl.text,
                  color: _selectedColor,
                  ownerId: '',
                  createdAt: DateTime.now(),
                ),
                showMenu: false,
              ),

              const SizedBox(height: 28),

              CustomButton(
                text: _isEditing ? 'Modifier' : 'Créer le projet',
                onPressed: _submit,
                isLoading: _isLoading,
                icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}