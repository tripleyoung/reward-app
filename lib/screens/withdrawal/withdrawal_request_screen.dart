import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WithdrawalRequestScreen extends StatefulWidget {
  const WithdrawalRequestScreen({super.key});

  @override
  State<WithdrawalRequestScreen> createState() => _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _accountHolder = '';
  String _bank = '';
  String _accountNumber = '';
  String _amount = '';

  final List<int> _amountOptions = [
    10000, 20000, 30000, 40000, 50000, 
    60000, 70000, 80000, 90000, 100000
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출금신청'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormField(
                label: '예금주',
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: '예금주명 입력',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _accountHolder = value),
                  validator: (value) => 
                    value?.isEmpty ?? true ? '예금주명을 입력해주세요' : null,
                ),
              ),
              
              _buildFormField(
                label: '은행',
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('은행선택'),
                  value: _bank.isEmpty ? null : _bank,
                  items: [
                    '신한은행',
                    '국민은행',
                    '우리은행',
                    '하나은행',
                    '농협은행',
                  ].map((bank) => DropdownMenuItem(
                    value: bank,
                    child: Text(bank),
                  )).toList(),
                  onChanged: (value) => setState(() => _bank = value ?? ''),
                  validator: (value) => 
                    value?.isEmpty ?? true ? '은행을 선택해주세요' : null,
                ),
              ),
              
              _buildFormField(
                label: '계좌번호',
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: '계좌번호 입력',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _accountNumber = value),
                  validator: (value) => 
                    value?.isEmpty ?? true ? '계좌번호를 입력해주세요' : null,
                ),
              ),
              
              _buildFormField(
                label: '금액',
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('금액 선택'),
                  value: _amount.isEmpty ? null : _amount,
                  items: _amountOptions.map((amount) => DropdownMenuItem(
                    value: amount.toString(),
                    child: Text('${amount.toStringAsFixed(0)}원'),
                  )).toList(),
                  onChanged: (value) => setState(() => _amount = value ?? ''),
                  validator: (value) => 
                    value?.isEmpty ?? true ? '금액을 선택해주세요' : null,
                ),
              ),

              const SizedBox(height: 24),
              
              // 출금안내 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '출금안내',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGuideText('출금 요청은 평일 영업시간(오전 9시~오후 6시) 내에 처리됩니다.'),
                      _buildGuideText('출금 금액은 3.3% 수수료와 500원의 추가 수수료를 제외한 금액으로 지급됩니다.'),
                      _buildGuideText('예금주 정보가 가입 시 입력한 실명과 일치하지 않으면 출금 처리가 불가능할 수 있습니다.'),
                      _buildGuideText('단, 처리 시간은 상황에 따라 달라질 수 있습니다.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('출금신청'),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
          child,
        ],
      ),
    );
  }

  Widget _buildGuideText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: 출금 신청 API 호출
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('출금 신청이 완료되었습니다')),
      );
    }
  }
} 