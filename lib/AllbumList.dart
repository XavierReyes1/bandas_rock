import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlbumList extends StatefulWidget {
  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  int _votos = 0;

  void _votosAlbum(String albumId) {
    setState(() {
      _votos++;
    });
    // Guardar el voto en Firestore
    FirebaseFirestore.instance.collection('albums').doc(albumId).update({
      'votos': FieldValue.increment(1),
    }).then((_) {
      print('Voto registrado en Firestore');
    }).catchError((error) {
      print('Error al registrar el voto: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Álbumes'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('albums').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot album = snapshot.data!.docs[index];
              return GestureDetector(
                onTap: () => _votosAlbum(album.id),
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (album['imagen_url'] != null &&
                          album['imagen_url'] != '')
                        Image.network(
                          album['imagen_url'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      if (album['imagen_url'] == null ||
                          album['imagen_url'] == '')
                        Image.asset(
                          'assets/imagen/imagen.jpg', // Ruta de la imagen local predeterminada
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(height: 8.0),
                      Center(
                        child: Text(
                          'Banda: ${album['banda']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text('Álbum: ${album['album']}'),
                      ),
                      Center(
                        child: Text('Año: ${album['ano']}'),
                      ),
                      Center(
                        child: Text('Votos: ${album['votos'] ?? 0}'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
