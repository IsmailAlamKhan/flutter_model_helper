const String FromJSONHead = ' %s.fromJson(Map<String, dynamic> json) {';
const String FromJSONMiddle = '\n     %s = json[\'%s\'];';

const String ToJSONHead =
    ' Map<String, dynamic> toJson() {\nfinal Map<String, dynamic> data = Map<String, dynamic>();';
const String ToJSONMiddle = '\n     data[\'%s\'] = this.%s;';
const String ToStringHead = '@override\n'
    ' String toString() {\n'
    ' return '
    '\'\'\' '
    '%s:{\n';

const String ToStrMiddle = r'            %s = ${this.%s};' '\n';
const String FromDocumentSnapshotHead =
    '%s.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {\n';

const String FromDocumentSnapshotMiddleID =
    r'            %s = documentSnapshot.%s;' '\n';
const String FromDocumentSnapshotMiddle =
    '            %s = documentSnapshot.data()[\'%s\' ];' '\n';

const String StreamHead = ' Stream<List<%s>> %sStream() {';
const String StreamMIddle = '\n    return _firestore'
    '\n     .collection('
    '%s'
    ')'
    '\n     .snapshots()'
    '\n     .map((QuerySnapshot query) {'
    '\n       List<%s> retVal = List();'
    '\n        query.docs.forEach((element) async {'
    '\n          retVal.add('
    '\n            %s.fromDocumentSnapshot('
    '\n              documentSnapshot: element,'
    '\n            ),'
    '\n          );'
    '\n       });'
    '\n     return retVal;'
    '\n   });';

const String AddHead = ' void add%s({%s %s}) {';
const String AddMIddle = '\n  _firestore'
    '\n    .collection('
    '%s'
    ').doc().set({'
    '\n    '
    '\'dateCreated\''
    ': Timestamp.now(),';
const String AddEnd = '\n    })'
    '\n    .then((value) => print('
    'success'
    '))'
    '\n    .catchError((err) {'
    '\n        print(err.message);'
    '\n        print(err.code);'
    '\n      });'
    '\n    }';
const String UpdateHead = ' void update%s({%s %s}) {';
const String UpdateMIddle = '\n  _firestore'
    '\n    .collection('
    '%s'
    ').doc(%s.id).update({'
    '\n    '
    'dateCreated'
    ': Timestamp.now(),';
const String UpdateEnd = '\n    })'
    '\n    .then((value) => print('
    'success'
    '))'
    '\n    .catchError((err) {'
    '\n        print(err.message);'
    '\n        print(err.code);'
    '\n      });'
    '\n    }';

const String Delete = ' void delete%s({int id}) {'
    '\n  _firestore'
    '\n    .collection('
    '%s'
    ').doc(id).delete()'
    '\n    .then((value) => print('
    'success'
    '))'
    '\n    .catchError((err) {'
    '\n        print(err.message);'
    '\n        print(err.code);'
    '\n      });'
    '\n    }';
