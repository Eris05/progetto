class LoginUserDto{
  String email;
  String password;

  LoginUserDto({
    required this.email,
    required this.password
});

  factory LoginUserDto.fromJson(Map<String,dynamic> json){
    return LoginUserDto(
        email: json['email'],
        password: json['password']
    );
  }//fromJson

  Map<String,dynamic> toJson() =>{
    'email':email,
    'password': password
  };//toJson

  @override
  String toString(){
    return email;
  }
}