Fetch Code
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AsFetchScreen extends StatefulWidget {
  @override
  _AsFetchScreenState createState() => _AsFetchScreenState();
}

class _AsFetchScreenState extends State<AsFetchScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref("categories");
  List<Map<String, String>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      final dataSnapshot = await _databaseReference.get();
      if (dataSnapshot.exists) {
        final Map<dynamic, dynamic> categoriesMap = dataSnapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, String>> loadedCategories = categoriesMap.entries.map((entry) {
          final Map<String, dynamic> value = entry.value as Map<String, dynamic>;
          return {
            "category_name": value["category_name"] ?? "",
            "category_desc": value["category_desc"] ?? "",
          };
        }).toList();
        setState(() {
          _categories = loadedCategories;
        });
      }
    } catch (error) {
      debugPrint("Error fetching categories: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories Table"),
      ),
      body: _categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text("Category Name")),
                  DataColumn(label: Text("Category Description")),
                ],
                rows: _categories.map((category) {
                  return DataRow(cells: [
                    DataCell(Text(category["category_name"]!)),
                    DataCell(Text(category["category_desc"]!)),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}
========================================================================================================================
Create Screen
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AsCreateCategoryScreen extends StatefulWidget {
  @override
  _AsCreateCategoryScreenState createState() => _AsCreateCategoryScreenState();
}

class _AsCreateCategoryScreenState extends State<AsCreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref("categories");

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newCategoryRef = _databaseReference.push();
        await newCategoryRef.set({
          "category_name": _nameController.text,
          "category_desc": _descController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category added successfully!")),
        );
        _nameController.clear();
        _descController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Category"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Category Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the category name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: "Category Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the category description";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveCategory,
                child: Text("Save Category"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
