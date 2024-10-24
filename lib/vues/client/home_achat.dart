import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sene_mobile/couleur.dart';
import 'package:sene_mobile/services/auth_controleur.dart';
import 'package:sene_mobile/vues/client/acheter.dart';
import 'package:sene_mobile/vues/client/mes_achat.dart';
import 'package:sene_mobile/vues/client/panier_vue.dart';
import 'package:sene_mobile/vues/client/profil_client.dart';

import '../../controleur/client_controleur.dart';
import '../../controleur/panier_controleur.dart';
import '../../controleur/produit_controleur.dart';
import '../../models/panier_produit.dart';
import '../../models/produit.dart';
import '../../services/produit_service.dart';

class HomeAchat extends StatefulWidget {
  @override
  _HomeAchatState createState() => _HomeAchatState();
}

class _HomeAchatState extends State<HomeAchat> {
  late ProduitController controller;
  List<Produit> produits = [];
  List<Produit> displayedProduits = [];
  String userIdP = AuthController.instance.userId.toString();
  Map<String, dynamic>? clientInfo;
  String? panierId; // Déclarez panierId ici
  bool isPanierIdFetched = false; // Drapeau pour contrôler l'appel
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ProduitController(ProduitService());
    _loadProduits();
    _fetchClientInfo();
    _fetchPanierId();
  }

  Future<void> _fetchPanierId() async {
    if (!isPanierIdFetched && userIdP.isNotEmpty) {
      try {
        panierId = await ClientController().fetchPanierId(userIdP);
        print("Panier ID récupéré : $panierId");
        isPanierIdFetched = true; // Marquez comme récupéré
        if (!mounted) return;
        setState(() {});
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la récupération de l\'ID du panier'),
          ),
        );
      }
    }
  }

  Future<void> _loadProduits() async {
    await controller.loadProduits();
    setState(() {
      produits = controller.getProduits();
      displayedProduits = produits;
    });
  }

  Future<void> _fetchClientInfo() async {
    if (userIdP.isNotEmpty) {
      try {
        clientInfo = await ClientController().fetchClientInfo(userIdP);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la récupération des informations'),
          ),
        );
      }
    }
  }

  void _filterProduits(String query) {
    if (query.isEmpty) {
      setState(() {
        displayedProduits = produits;
      });
    } else {
      final filtered = produits.where((produit) {
        return produit.nom.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        displayedProduits = filtered;
      });
    }
  }

  Future<void> _ajouterAuPanier(String produitId) async {
    if (panierId != null && panierId!.isNotEmpty) {
      try {
        // Remplacez 1 par la quantité désirée
        await PanierController()
            .addProduitToPanier(userIdP, produitId, panierId!, 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit ajouté au panier!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout au panier.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez d\'abord créer un panier.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Couleur.primary,
        title: Column(
          children: [
            Center(
              child: Text(
                "Salut ${clientInfo?['prenom'] ?? 'Client'} ${clientInfo?['nom'] ?? ''} 👋🏾",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Bienvenue dans votre espace!",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHome(),
          MesAchat(),
          PanierPage(userId: userIdP),
          ClientProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHome() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            _buildCarousel(),
            const SizedBox(height: 16),
            _buildProductGrid(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filterProduits,
      decoration: InputDecoration(
        hintText: 'Rechercher un produit',
        isDense: true,
        contentPadding: const EdgeInsets.all(12.0),
        border: const OutlineInputBorder(
          borderSide: BorderSide(),
          borderRadius: BorderRadius.all(Radius.circular(99)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(99)),
        ),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: displayedProduits.map((produit) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AcheterPage(produit: produit),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    children: [
                      produit.image != null
                          ? Image.memory(
                              base64Decode(produit.image!),
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produit.nom,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Prix: ${produit.prix} FCFA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      itemCount: displayedProduits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final produit = displayedProduits[index];
        return ProductCard(
          product: produit,
          onAddToCart: () => _ajouterAuPanier(produit.id.toString()),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: GNav(
          color: Couleur.secondary,
          activeColor: Colors.white,
          tabBackgroundColor: Couleur.primary,
          padding: const EdgeInsets.all(10),
          gap: 8,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Accueil',
            ),
            GButton(
              icon: Icons.shopping_bag,
              text: 'Achat',
            ),
            GButton(
              icon: Icons.shopping_cart,
              text: 'Panier',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// Nouveau widget ProductCard

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  final Produit product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AcheterPage(produit: product),
          ),
        );
      },
      child: Container(
        height: 200,
        width: 300,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 0.1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du produit
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  image: product.image != null
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(product.image!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton.filledTonal(
                      padding: EdgeInsets.zero,
                      onPressed: onAddToCart,
                      iconSize: 18,
                      icon: Icon(IconlyLight.bookmark),
                    ),
                  ),
                ),
              ),
              // Informations sur le produit
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        product.nom,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${product.prix} FCFA",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: IconButton.filled(
                            padding: EdgeInsets.zero,
                            onPressed: onAddToCart,
                            iconSize: 18,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            color: Colors.transparent,
                            style: IconButton.styleFrom(
                              backgroundColor: Couleur.primary,
                              shape: CircleBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
