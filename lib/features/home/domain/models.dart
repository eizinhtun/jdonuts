class Member {
  const Member({
    required this.id,
    required this.name,
    required this.tier,
    required this.points,
    required this.pointsToGold,
    required this.notifications,
    this.image = 'member.svg',
  });

  final String id;
  final String name;
  final String tier;
  final int points;
  final int pointsToGold;
  final int notifications;
  final String image;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'] as String,
    name: json['name'] as String,
    tier: json['tier'] as String,
    points: json['points'] as int,
    pointsToGold: json['pointsToGold'] as int,
    notifications: json['notifications'] as int,
    image: json['image'] as String? ?? 'member.svg',
  );
}

class Product {
  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.isNew,
    required this.image,
    required this.description,
    this.discountPercent,
  });

  final String id;
  final String code;
  final String name;
  final String image;
  final String description;
  final int priceMmk;
  final bool isNew;
  final int? discountPercent;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    priceMmk: json['priceMmk'] as int,
    isNew: json['isNew'] as bool,
    image: json['image'] as String,
    description: json['description'] as String,
    discountPercent: json['discountPercent'] as int?,
  );
}

class PromoBanner {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String image;

  factory PromoBanner.fromJson(Map<String, dynamic> json) => PromoBanner(
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    image: json['image'] as String,
  );
}

class HomeSection {
  HomeSection({
    required this.id,
    required this.title,
    required List<String> productIds,
  }) : productIds = List.unmodifiable(productIds);

  final String id;
  final String title;
  final List<String> productIds;

  factory HomeSection.fromJson(Map<String, dynamic> json) => HomeSection(
    id: json['id'] as String,
    title: json['title'] as String,
    productIds: (json['productIds'] as List).cast<String>(),
  );
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.points,
    required this.kind,
  });

  final String id;
  final String title;
  final String kind;
  final int progress;
  final int target;
  final int points;

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'] as String,
    title: json['title'] as String,
    progress: json['progress'] as int,
    target: json['target'] as int,
    points: json['points'] as int,
    kind: json['kind'] as String,
  );
}

class AppData {
  AppData({
    required this.member,
    required List<Product> products,
    required List<HomeSection> sections,
    required List<PromoBanner> banners,
    required List<String> shops,
    required List<Challenge> challenges,
  }) : products = List.unmodifiable(products),
       sections = List.unmodifiable(sections),
       banners = List.unmodifiable(banners),
       shops = List.unmodifiable(shops),
       challenges = List.unmodifiable(challenges);

  final Member member;
  final List<Product> products;
  final List<HomeSection> sections;
  final List<PromoBanner> banners;
  final List<String> shops;
  final List<Challenge> challenges;

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
    member: Member.fromJson(json['member'] as Map<String, dynamic>),
    products: (json['products'] as List)
        .map((value) => Product.fromJson(value as Map<String, dynamic>))
        .toList(),
    sections: (json['sections'] as List)
        .map((value) => HomeSection.fromJson(value as Map<String, dynamic>))
        .toList(),
    banners: (json['banners'] as List)
        .map((value) => PromoBanner.fromJson(value as Map<String, dynamic>))
        .toList(),
    shops: (json['shops'] as List).cast<String>(),
    challenges: (json['challenges'] as List)
        .map((value) => Challenge.fromJson(value as Map<String, dynamic>))
        .toList(),
  );

  Product? product(String id) =>
      products.where((item) => item.id == id).firstOrNull;
}
