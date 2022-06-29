import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:io';
import "package:gql/ast.dart" as ast;
import "package:gql/language.dart" as lang;

final HttpLink mLink = HttpLink("https://rickandmortyapi.com/graphql/");
void main() {
  runApp(Home());
}

ValueNotifier<GraphQLClient> client =
    ValueNotifier(GraphQLClient(cache: GraphQLCache(), link: mLink));

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final ast.DocumentNode doc = lang.parseString("""
query  {
characters(page:5) {
results {
name
species
gender
image
type
}
}
}""");

    return GraphQLProvider(
        client: client,
        child: MaterialApp(
          home: Scaffold(
              backgroundColor: Colors.white,
              body: Query(
                options: QueryOptions(document: doc),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.isLoading) {
                    return const Center(child:  CircularProgressIndicator());
                  }

                  if (result.hasException) {
                    return Column();
                  }

                  return ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.all(5),
                  onTap: ()=>{},
                  title:
                      Text(result.data!['characters']['results'][index]['name']),
                  leading: Image.network(result.data!['characters']['results'][index]['image']),
                  subtitle: Text(result.data!['characters']['results'][index]['species']),
                );
              },
              itemCount: result.data!['characters']['results'].length,
            );
                },
              )),
        ));
  }
}
