class RegisterUserDto{
  String email;
  String password;
  String username;

  RegisterUserDto({
    required this.email,
    required this.password,
    required this.username
  });

  factory RegisterUserDto.fromJson(Map<String,dynamic> json){
    return RegisterUserDto(
        email: json['email'],
        password: json['password'],
        username: json['username']
    );
  }//fromJson

  Map<String,dynamic> toJson() =>{
    'email':email,
    'password': password,
    'username': username
  };//toJson

  @override
  String toString(){
    return email;
  }
}