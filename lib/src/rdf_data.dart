import 'package:solid_encrypt/solid_encrypt.dart';

class EncProfile {
  String profileRdfStr = '';

  EncProfile(this.profileRdfStr);

  String getEncKeyHash() {
    String encKeyHash = '';

    if (profileRdfStr.contains('@prefix')) {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('sh-data:encKey')) {
          var itemList = dataItem.trim().split(' ');
          encKeyHash = itemList[1].trim().split('"')[1];
        }
      }
    } else {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains(encKeyPred)) {
          var itemList = dataItem.trim().split(' ');
          encKeyHash = itemList[1].trim().split('"')[1];
        }
      }
    }
    return encKeyHash;
  }

  String getEncFileHash() {
    String encFileHash = '';

    if (profileRdfStr.contains('@prefix')) {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('sh-data:encFiles')) {
          var itemList = dataItem.trim().split(' ');
          encFileHash = itemList[1].trim().split('"')[1];
        }
      }
    } else {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains(encFilePred)) {
          var itemList = dataItem.trim().split(' ');
          encFileHash = itemList[1].trim().split('"')[1];
        }
      }
    }
    return encFileHash;
  }

  String getEncFileCont() {
    String encFileCont = '';

    if (profileRdfStr.contains('@prefix')) {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('sh-data:encVal')) {
          var itemList = dataItem.trim().split(' ');
          encFileCont = itemList[1].trim().split('"')[1];
        }
      }
    } else {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains(encValPred)) {
          var itemList = dataItem.trim().split(' ');
          encFileCont = itemList[2].trim().split('"')[1];
        }
      }
    }
    return encFileCont;
  }
}

String genSparqlQuery(
    String action, String subject, String predicate, String object,
    {String? prevObject, String? format}) {
  String query = '';

  switch (action) {
    case "SELECT":
      {
        query =
            'SELECT ?subject ?predicate ?object WHERE {<$subject> <$predicate> ?object};';
      }
      break;

    case "INSERT":
      {
        query = 'INSERT DATA {<$subject> <$predicate> "$object".};';
      }
      break;

    case "DELETE":
      {
        query = 'DELETE DATA {<$subject> <$predicate> "$object".};';
      }
      break;

    case "UPDATE":
      {
        query =
            'DELETE DATA {<$subject> <$predicate> "$prevObject".}; INSERT DATA {<$subject> <$predicate> "$object".};';
      }
      break;

    case "READ":
      {
        query = "Invalid";
      }
      break;

    default:
      {
        query = "Invalid";
      }
      break;
  }

  return query;
}
