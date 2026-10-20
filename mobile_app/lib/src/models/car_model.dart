// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CarModel {
  String? name;
  String? image;
  String? imagesecond;
  String? id;
  String? smallbagcount;
  String? largebagcount;
  String? pickuptime;
  CarModel({
    this.name,
    this.image,
    this.imagesecond,
    this.id,
    this.smallbagcount,
    this.largebagcount,
    this.pickuptime,
  });

  CarModel copyWith({
    String? name,
    String? image,
    String? imagesecond,
    String? id,
    String? smallbagcount,
    String? largebagcount,
    String? pickuptime,
  }) {
    return CarModel(
      name: name ?? this.name,
      image: image ?? this.image,
      imagesecond: imagesecond ?? this.imagesecond,
      id: id ?? this.id,
      smallbagcount: smallbagcount ?? this.smallbagcount,
      largebagcount: largebagcount ?? this.largebagcount,
      pickuptime: pickuptime ?? this.pickuptime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'image': image,
      'imagesecond': imagesecond,
      'id': id,
      'smallbagcount': smallbagcount,
      'largebagcount': largebagcount,
      'pickuptime': pickuptime,
    };
  }

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      name: map['name'] != null ? map['name'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      imagesecond: map['imagesecond'] != null ? map['imagesecond'] as String : null,
      id: map['id'] != null ? map['id'] as String : null,
      smallbagcount: map['smallbagcount'] != null ? map['smallbagcount'] as String : null,
      largebagcount: map['largebagcount'] != null ? map['largebagcount'] as String : null,
      pickuptime: map['pickuptime'] != null ? map['pickuptime'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CarModel.fromJson(String source) => CarModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CarModel(name: $name, image: $image, imagesecond: $imagesecond, id: $id, smallbagcount: $smallbagcount, largebagcount: $largebagcount, pickuptime: $pickuptime)';
  }

  @override
  bool operator ==(covariant CarModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.image == image &&
      other.imagesecond == imagesecond &&
      other.id == id &&
      other.smallbagcount == smallbagcount &&
      other.largebagcount == largebagcount &&
      other.pickuptime == pickuptime;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      image.hashCode ^
      imagesecond.hashCode ^
      id.hashCode ^
      smallbagcount.hashCode ^
      largebagcount.hashCode ^
      pickuptime.hashCode;
  }
 }
