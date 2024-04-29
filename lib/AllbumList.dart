import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlbumList extends StatefulWidget {
  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State
{
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
        builder: (context, AsyncSnapshot
        <QuerySnapshot> snapshot) {
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
            Text(
              'Banda: ${album['banda']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Álbum: ${album['album']}'),
            Text('Año: ${album['ano']}'),
            Text('Votos: ${album['votos'] ?? 0}'),
            if (album['imagen_url'] != null && album['imagen_url'] != '')
              Image.network(
                album['imagen_url'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                
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
