import 'package:flutter/material.dart';
import 'package:noviindus_round_two_task/presentation/providers/auth_provider.dart';
import 'package:noviindus_round_two_task/presentation/screens/home_screen/home_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedCode = '+91';
  TextEditingController _phoneController = TextEditingController();

  bool get _isValid {
    if (_phoneController.text.trim().length >= 6) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    var provider = Provider.of<AuthProvider>(context, listen: false);
    String phone = _phoneController.text.trim();

    if (phone == '') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter mobile number')));
      return;
    }

    await provider.login(countryCode: _selectedCode, phone: phone);

    if (provider.state == AuthState.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login success')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false,
      );
    } else if (provider.state == AuthState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${provider.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 36),
              Text(
                "Enter Your\nMobile Number",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Lorem ipsum dolor sit amet consectetur. Porta at id hac vitae. Et tortor at vehicula euismod mi viverra.",
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCode,
                        dropdownColor: Colors.black,
                        style: TextStyle(color: Colors.white),
                        items: [
                          DropdownMenuItem(value: '+91', child: Text('+91')),
                          DropdownMenuItem(value: '+1', child: Text('+1')),
                          DropdownMenuItem(value: '+44', child: Text('+44')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedCode = v;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter Mobile Number',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        setState(() {}); // update _isValid and UI
                      },
                    ),
                  ),
                ],
              ),
              Spacer(),
              Center(
                child: Container(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: provider.loading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade900,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: provider.loading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
