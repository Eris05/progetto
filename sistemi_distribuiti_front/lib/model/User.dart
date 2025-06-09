
class User{
  int id;
  String username;
  String email;
  String password;
  String role;


  User({required this.id,required this.username,required this.email, required this.password, required this.role});

  factory User.fromJson(Map<String,dynamic> json){
    return User(
        id:json['id'],
        username: json['username'],
        email: json['email'],
        password: json['password'],
        role: json['role']
    );
  }//fromJson

  Map<String,dynamic> toJson() => {
    'id':id,
    'username':username,
    'email':email,
    'password': password,
    'role':role
  }; //toJson

  @override
  String toString(){
    return email;
  }//toString

}//User