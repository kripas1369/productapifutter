import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Product List'),
        ),
        body: ProductList(),
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final String baseUrls = "https://fakestoreapi.com/products";

  Future<List<ProductModel>> fetchData() async {
    final response = await http.get(Uri.parse(baseUrls));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<ProductModel> products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(products[index].title ?? ""),
                subtitle: Text(products[index].description ?? ""),
                leading: Image.network(products[index].image ?? ""),
                trailing: Text("Rate: ${products[index].rating?.rate}"),
              );
            },
          );
        }
      },
    );
  }
}

class ProductModel {
  int? id;
  String? title;
  double? price;
  String? description;
  String? category;
  String? image;
  Rating? rating;

  ProductModel({
    this.id,
    this.title,
    this.price,
    this.description,
    this.category,
    this.image,
    this.rating,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'].toDouble();
    description = json['description'];
    category = json['category'];
    image = json['image'];
    rating = json['rating'] != null ? Rating.fromJson(json['rating']) : null;
  }
}

class Rating {
  double? rate;
  int? count;

  Rating({this.rate, this.count});

  Rating.fromJson(Map<String, dynamic> json) {
    rate = json['rate'].toDouble();
    count = json['count'];
  }
}
