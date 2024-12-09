import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';

class ModifyUserInfo {
  String userId;
  String userPassword;
  String userName;
  String userNickname;
  String userPhone;
  String accountHolder;
  String bankName;
  String accountNumber;

  ModifyUserInfo({
    required this.userId,
    this.userPassword = '',
    required this.userName,
    required this.userNickname,
    required this.userPhone,
    required this.accountHolder,
    required this.bankName,
    required this.accountNumber,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userPassword': userPassword,
    'userName': userName,
    'userNickname': userNickname,
    'userPhone': userPhone,
    'accountHolder': accountHolder,
    'bankName': bankName,
    'accountNumber': accountNumber,
  };
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String _confirmPassword = '';
  late ModifyUserInfo _formData = ModifyUserInfo(
    userId: '',
    userName: '',
    userNickname: '',
    userPhone: '',
    accountHolder: '',
    bankName: '',
    accountNumber: '',
  );

  // 그룹별 편집 상태
  bool _passwordGroupEditing = false;
  bool _bankGroupEditing = false;
  bool _nicknameEditing = false;
  bool _phoneEditing = false;

  @override
  void initState() {
    super.initState();
    _initFormData();
  }

  Future<void> _initFormData() async {
    try {
      final authProvider = context.read<AuthProvider>();
         final user = await authProvider.user;
      final userId = user?.userId;
      
      if (userId != null) {
        final dio = DioService.instance;
        final response = await dio.post('api/v1/user/info', data: {'userId': userId});
        
        if (response.data != null) {
          setState(() {
            _formData = ModifyUserInfo(
              userId: response.data['userId'] ?? '',
              userName: response.data['userName'] ?? '',
              userNickname: response.data['userNickname'] ?? '',
              userPhone: response.data['userPhone'] ?? '',
              accountHolder: response.data['accountHolder'] ?? '',
              bankName: response.data['bankName'] ?? '',
              accountNumber: response.data['accountNumber'] ?? '',
            );
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final dio = DioService.instance;
        await dio.post('/my/info/modify', data: _formData.toJson());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('정보가 수정되었습니다')),
          );
          await _initFormData(); // 정보 새로고침
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('정보 수정에 실패했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원정보 수정'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 기본 정보 (수정 불)
              _buildSection(
                children: [
                  _buildReadOnlyField(
                    label: '아이디',
                    value: _formData.userId,
                  ),
                  _buildReadOnlyField(
                    label: '이름',
                    value: _formData.userName,
                  ),
                ],
              ),

              // 비밀번호 그룹
              _buildSection(
                children: [
                  _buildPasswordField(),
                  _buildConfirmPasswordField(),
                  _buildEditButton(
                    isEditing: _passwordGroupEditing,
                    onPressed: _handlePasswordGroupEdit,
                  ),
                ],
              ),

              // 닉네임
              _buildSection(
                children: [
                  _buildTextField(
                    label: '닉네임',
                    value: _formData.userNickname,
                    enabled: _nicknameEditing,
                    onChanged: (value) => _formData.userNickname = value,
                  ),
                  _buildEditButton(
                    isEditing: _nicknameEditing,
                    onPressed: _handleNicknameEdit,
                  ),
                ],
              ),

              // 전화번호
              _buildSection(
                children: [
                  _buildTextField(
                    label: '핸드폰 번호',
                    value: _formData.userPhone,
                    enabled: _phoneEditing,
                    onChanged: (value) => _formData.userPhone = value,
                  ),
                  _buildEditButton(
                    isEditing: _phoneEditing,
                    onPressed: _handlePhoneEdit,
                  ),
                ],
              ),

              // 은행 정보 그룹
              _buildSection(
                children: [
                  _buildTextField(
                    label: '예금주 이름',
                    value: _formData.accountHolder,
                    enabled: _bankGroupEditing,
                    onChanged: (value) => _formData.accountHolder = value,
                  ),
                  _buildTextField(
                    label: '은행',
                    value: _formData.bankName,
                    enabled: _bankGroupEditing,
                    onChanged: (value) => _formData.bankName = value,
                  ),
                  _buildTextField(
                    label: '계좌번호',
                    value: _formData.accountNumber,
                    enabled: _bankGroupEditing,
                    onChanged: (value) => _formData.accountNumber = value,
                  ),
                  _buildEditButton(
                    isEditing: _bankGroupEditing,
                    onPressed: _handleBankGroupEdit,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('수정'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // UI 헬퍼 메서드들...
  Widget _buildSection({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return _buildTextField(
      label: label,
      value: value,
      enabled: false,
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            enabled: enabled,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      label: '비밀번호',
      value: _formData.userPassword,
      enabled: _passwordGroupEditing,
      onChanged: (value) => _formData.userPassword = value,
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      label: '비밀번호 확인',
      value: _confirmPassword,
      enabled: _passwordGroupEditing,
      onChanged: (value) => _confirmPassword = value,
    );
  }

  Widget _buildEditButton({
    required bool isEditing,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child: Text(isEditing ? '완료' : '변경'),
      ),
    );
  }

  // 편집 상태 핸들러들
  void _handlePasswordGroupEdit() {
    if (!_passwordGroupEditing) {
      setState(() => _passwordGroupEditing = true);
    } else if (_formData.userPassword.isNotEmpty && _confirmPassword.isNotEmpty) {
      if (_formData.userPassword == _confirmPassword) {
        setState(() => _passwordGroupEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
        );
      }
    }
  }

  void _handleBankGroupEdit() {
    if (!_bankGroupEditing) {
      setState(() => _bankGroupEditing = true);
    } else if (_formData.accountHolder.isNotEmpty &&
        _formData.bankName.isNotEmpty &&
        _formData.accountNumber.isNotEmpty) {
      setState(() => _bankGroupEditing = false);
    }
  }

  void _handleNicknameEdit() {
    if (!_nicknameEditing) {
      setState(() => _nicknameEditing = true);
    } else if (_formData.userNickname.isNotEmpty) {
      setState(() => _nicknameEditing = false);
    }
  }

  void _handlePhoneEdit() {
    if (!_phoneEditing) {
      setState(() => _phoneEditing = true);
    } else if (_formData.userPhone.isNotEmpty) {
      setState(() => _phoneEditing = false);
    }
  }
} 