class Member {
  const Member({
    required this.id,
    required this.name,
    required this.tier,
    required this.points,
    required this.pointsToGold,
    required this.notifications,
  });
  final String id, name, tier;
  final int points, pointsToGold, notifications;
  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'] as String,
    name: json['name'] as String,
    tier: json['tier'] as String,
    points: json['points'] as int,
    pointsToGold: json['pointsToGold'] as int,
    notifications: json['notifications'] as int,
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
  final String id, code, name, image, description;
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

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.points,
    required this.kind,
  });
  final String id, title, kind;
  final int progress, target, points;
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
  const AppData({
    required this.member,
    required this.products,
    required this.sections,
    required this.banners,
    required this.shops,
    required this.challenges,
  });
  final Member member;
  final List<Product> products;
  final List<Map<String, dynamic>> sections, banners;
  final List<String> shops;
  final List<Challenge> challenges;
  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
    member: Member.fromJson(json['member'] as Map<String, dynamic>),
    products: (json['products'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList(),
    sections: (json['sections'] as List).cast<Map<String, dynamic>>(),
    banners: (json['banners'] as List).cast<Map<String, dynamic>>(),
    shops: (json['shops'] as List).cast<String>(),
    challenges: (json['challenges'] as List)
        .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  Product? product(String id) => products.where((p) => p.id == id).firstOrNull;
}
