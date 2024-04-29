import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AlbumState extends StatefulWidget {
  @override
  _AlbumState createState() => _AlbumState();
}

class _AlbumState extends State<AlbumState> {
  final TextEditingController bandaController = TextEditingController();
  final TextEditingController albumController = TextEditingController();
  final TextEditingController anoController = TextEditingController();
  File? _selectedFile;
  final int id = 0;
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? url; // Definir url aquí

      try {
        if (_selectedFile != null) {
          final storageRef = FirebaseStorage.instance.ref();
          final fotoref = storageRef.child('albums').child('${id + 1}.jpg');
          final uploadTask = await fotoref.putFile(_selectedFile!);
          url = await uploadTask.ref.getDownloadURL(); // Asignar valor a url
          print('Imagen subida y URL guardada exitosamente');
        }

        DocumentReference document =
            await FirebaseFirestore.instance.collection('albums').add({
          'banda': bandaController.text,
          'album': albumController.text,
          'ano': int.parse(anoController.text),
          'votos': 0,
          'imagen_url': url ?? '', // Usar url aquí
        });

        print('Datos guardados en Firestore');

        Navigator.pushNamed(context, '/albumList');
      } catch (error) {
        print('Error al guardar datos: $error');
      }
    }
  }

  Future<void> _selectFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildPreviewImage() {
    if (_selectedFile != null) {
      return Image.file(_selectedFile!);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creación de Bandas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildTextField(bandaController, 'Nombre de la banda'),
              _buildTextField(albumController, 'Nombre del álbum'),
              _buildNumberField(anoController, 'Año de lanzamiento'),
              ElevatedButton(
                onPressed: _selectFile,
                child: Text('Seleccionar Foto'),
              ),
              _buildPreviewImage(),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Guardar Banda'),
              ),
              SizedBox(height: 16), // Espacio entre el botón y el ElevatedButton
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/albumList');
                },
                child: Text('Ver Álbumes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el $label';
        }
        return null;
      },
    );
  }

  Widget _buildNumberField(
      TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el $label';
        }
        if (int.tryParse(value) == null) {
          return 'Por favor ingresa un año válido';
        }
        int ano = int.parse(value);
        if (ano < 1900 || ano > DateTime.now().year) {
          return 'Por favor ingresa un año válido';
        }
        return null;
      },
    );
  }
}
