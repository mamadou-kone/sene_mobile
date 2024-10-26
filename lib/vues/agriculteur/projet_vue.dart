import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/vues/agriculteur/detail_projet.dart';
import 'package:sene_mobile/vues/agriculteur/projet_from.dart';
import '../../controleur/projet_controleur.dart';
import '../../models/projet.dart';
import '../../services/auth_controleur.dart';
import '../../services/projet_service.dart';
import 'ajout_projet.dart';

class ProjetPage extends StatefulWidget {
  const ProjetPage({Key? key}) : super(key: key);

  @override
  State<ProjetPage> createState() => _ProjetPageState();
}

class _ProjetPageState extends State<ProjetPage> {
  static const double _cardPadding = 16.0;
  static const double _imageSize = 120.0;
  static const double _borderRadius = 20.0;

  late ProjetController controller;
  final String currentUserId = AuthController.instance.userId ?? '';
  int selectedIndex = 0;
  late List<Projet> projetsToDisplay = [];

  final List<String> _projectCategories = ['Tous les projets', 'Mes projets'];

  @override
  void initState() {
    super.initState();
    controller = ProjetController(ProjetService(), currentUserId);
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await controller.loadProjets();
    setState(() {
      projetsToDisplay = controller.getProjets();
    });
  }

  Future<void> _loadMyProjets() async {
    await controller.loadMyProjets();
    setState(() {
      projetsToDisplay = controller.getMyProjets();
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un projet...',
          prefixIcon: Icon(Icons.search, color: Couleur.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _projectCategories.length,
          (index) => _buildCategoryItem(index),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          index == 1 ? _loadMyProjets() : _loadProjects();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Couleur.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Couleur.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          _projectCategories[index],
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Projet projet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: () => Navigator.push(
            context,
            PageTransition(
              child: DetailProjetPage(projet: projet),
              type: PageTransitionType.bottomToTop,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(_borderRadius - 5),
                      child: _buildProjectImage(projet),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            projet.titre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            projet.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressIndicator(projet),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountInfo(
                      'Objectif',
                      '${_formatAmount(projet.montantNecessaire ?? 0)} FCFA', // Gestion de la valeur nulle
                      Couleur.primary,
                    ),
                    _buildAmountInfo(
                      'Collecté',
                      '${_formatAmount(projet.montantCollecte ?? 0)} FCFA', // Gestion de la valeur nulle
                      Couleur.secondary,
                    ),
                  ],
                ),
                if (selectedIndex == 1) _buildEditButton(projet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  Widget _buildProgressIndicator(Projet projet) {
    final progress = projet.montantNecessaire != 0
        ? (projet.montantCollecte ?? 0) / projet.montantNecessaire
        : 0.0; // Éviter la division par zéro
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Couleur.secondary),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% atteint',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectImage(Projet projet) {
    return Container(
      height: _imageSize,
      width: _imageSize,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(_borderRadius - 5),
      ),
      child: projet.image != null
          ? Image.memory(
              base64Decode(projet.image!),
              fit: BoxFit.cover,
            )
          : Icon(
              Icons.image,
              size: 40,
              color: Colors.grey[400],
            ),
    );
  }

  Widget _buildEditButton(Projet projet) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: FormulaireProjet(projet: projet),
              type: PageTransitionType.bottomToTop,
            ),
          ).then((_) => _loadMyProjets());
        },
        icon: Icon(Icons.edit, color: Couleur.primary, size: 20),
        label: Text(
          'Modifier',
          style: TextStyle(color: Couleur.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          'Projets',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Couleur.primary,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            selectedIndex == 1 ? _loadMyProjets() : _loadProjects(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildCategoryList(),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildProjectCard(projetsToDisplay[index]),
                childCount: projetsToDisplay.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: ProjetForm(),
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        backgroundColor: Couleur.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouveau projet',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
