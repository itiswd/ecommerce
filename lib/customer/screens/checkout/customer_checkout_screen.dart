// lib/customer/screens/checkout/customer_checkout_screen.dart
import 'package:ecommerce_dashboard/config/customer_constants.dart';
import 'package:ecommerce_dashboard/config/customer_routes.dart';
import 'package:ecommerce_dashboard/models/order.dart';
import 'package:ecommerce_dashboard/providers/cart_provider.dart';
import 'package:ecommerce_dashboard/providers/customer_auth_provider.dart';
import 'package:ecommerce_dashboard/providers/orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({super.key});

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGovernorate = 'القاهرة';
  String _selectedCity = '';
  bool _useCashback = false;
  double _cashbackToUse = 0;
  bool _isLoading = false;
  PaymentMethod _paymentMethod = PaymentMethod.cashOnDelivery;

  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الشرقية',
    'المنوفية',
    'القليوبية',
    'البحيرة',
    'الغربية',
    'كفر الشيخ',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'المنيا',
    'بني سويف',
    'الفيوم',
    'البحر الأحمر',
    'الوادي الجديد',
    'مطروح',
    'شمال سيناء',
    'جنوب سيناء',
    'بورسعيد',
    'السويس',
    'الإسماعيلية',
    'دمياط',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final auth = Provider.of<CustomerAuthProvider>(context, listen: false);
    if (auth.isAuthenticated && !auth.isGuest) {
      _nameController.text = auth.currentUser?.name ?? '';
      _phoneController.text = auth.currentUser?.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = Provider.of<CustomerAuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    // التحقق من أن السلة ليست فارغة
    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('إتمام الطلب')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('السلة فارغة'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تصفح المنتجات'),
              ),
            ],
          ),
        ),
      );
    }

    // إذا كان المستخدم زائر، يجب تسجيل الدخول
    if (auth.isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text('إتمام الطلب')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'يجب تسجيل الدخول لإتمام الطلب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'سجل الآن للاستفادة من الكاش باك ومتابعة طلباتك',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, CustomerRoutes.register);
                    },
                    child: const Text('إنشاء حساب'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, CustomerRoutes.login);
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ملخص السلة
              _buildCartSummary(cart, colorScheme),
              const SizedBox(height: 24),

              // بيانات التوصيل
              _buildDeliverySection(colorScheme),
              const SizedBox(height: 24),

              // طريقة الدفع
              _buildPaymentSection(colorScheme),
              const SizedBox(height: 24),

              // الكاش باك
              _buildCashbackSection(auth, cart, colorScheme),
              const SizedBox(height: 24),

              // الإجمالي
              _buildTotalSection(cart, colorScheme),
              const SizedBox(height: 24),

              // ملاحظات
              _buildNotesSection(),
              const SizedBox(height: 24),

              // أزرار التأكيد
              _buildConfirmButtons(cart, auth, colorScheme),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cart, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ملخص الطلب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '${cart.itemCount} منتج',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const Divider(height: 24),
            ...cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.productImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${item.price.toStringAsFixed(0)} × ${item.quantity}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.subtotal.toStringAsFixed(0)} جنيه',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'بيانات التوصيل',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            // الاسم
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم بالكامل *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // رقم الهاتف
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف *',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '01xxxxxxxxx',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                if (!RegExp(CustomerConstants.phoneRegex).hasMatch(value)) {
                  return 'رقم الهاتف غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // المحافظة والمدينة
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGovernorate,
                    decoration: const InputDecoration(labelText: 'المحافظة *'),
                    items: _governorates.map((gov) {
                      return DropdownMenuItem(value: gov, child: Text(gov));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGovernorate = value ?? 'القاهرة';
                        // تحديث رسوم الشحن
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).calculateShippingFee(_selectedGovernorate);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    onChanged: (value) => _selectedCity = value,
                    decoration: const InputDecoration(labelText: 'المدينة *'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال المدينة';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // العنوان بالتفصيل
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'العنوان بالتفصيل *',
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'الشارع - رقم العقار - الدور - الشقة',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال العنوان';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'طريقة الدفع',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            RadioListTile<PaymentMethod>(
              value: PaymentMethod.cashOnDelivery,
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              title: const Text('الدفع عند الاستلام'),
              subtitle: const Text('ادفع نقداً عند استلام الطلب'),
              secondary: const Icon(Icons.money),
            ),
            // يمكن إضافة طرق دفع أخرى لاحقاً
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'طرق دفع إلكترونية قريباً',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashbackSection(
    CustomerAuthProvider auth,
    CartProvider cart,
    ColorScheme colorScheme,
  ) {
    final cashbackBalance = auth.currentUser?.cashbackBalance ?? 0;
    final maxCashback = (cashbackBalance > cart.subtotal * 0.2)
        ? cart.subtotal * 0.2
        : cashbackBalance;

    if (cashbackBalance < CustomerConstants.minimumCashbackToUse) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'محفظة الكاش باك',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${cashbackBalance.toStringAsFixed(0)} جنيه',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _useCashback,
              onChanged: (value) {
                setState(() {
                  _useCashback = value;
                  _cashbackToUse = value ? maxCashback : 0;
                });
              },
              title: const Text('استخدام الكاش باك'),
              subtitle: Text(
                'يمكنك خصم حتى ${maxCashback.toStringAsFixed(0)} جنيه',
              ),
              contentPadding: EdgeInsets.zero,
            ),
            if (_useCashback)
              Slider(
                value: _cashbackToUse,
                min: 0,
                max: maxCashback,
                divisions: maxCashback.toInt(),
                label: '${_cashbackToUse.toStringAsFixed(0)} جنيه',
                onChanged: (value) {
                  setState(() {
                    _cashbackToUse = value;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(CartProvider cart, ColorScheme colorScheme) {
    final total = cart.getTotalWithCashback(_useCashback ? _cashbackToUse : 0);
    final cashbackEarned =
        cart.subtotal >= CustomerConstants.minimumOrderForCashback
        ? cart.subtotal * CustomerConstants.cashbackPercentage
        : 0.0;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow(
              'المجموع',
              '${cart.subtotal.toStringAsFixed(0)} جنيه',
            ),
            _buildTotalRow(
              'الشحن',
              '${cart.shippingFee.toStringAsFixed(0)} جنيه',
            ),
            if (_useCashback && _cashbackToUse > 0)
              _buildTotalRow(
                'خصم الكاش باك',
                '- ${_cashbackToUse.toStringAsFixed(0)} جنيه',
                color: Colors.green,
              ),
            const Divider(),
            _buildTotalRow(
              'الإجمالي',
              '${total.toStringAsFixed(0)} جنيه',
              isBold: true,
              size: 18,
            ),
            if (cashbackEarned > 0)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'ستكسب ${cashbackEarned.toStringAsFixed(0)} جنيه كاش باك!',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double size = 14,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: size,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: size,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'ملاحظات إضافية (اختياري)',
        hintText: 'أي تعليمات خاصة بالتوصيل...',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildConfirmButtons(
    CartProvider cart,
    CustomerAuthProvider auth,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // زر تأكيد الطلب
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _confirmOrder(cart, auth),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle),
            label: Text(_isLoading ? 'جاري التأكيد...' : 'تأكيد الطلب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // زر تأكيد عبر واتساب
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : () => _confirmViaWhatsApp(cart, auth),
            icon: const Icon(Icons.chat, color: Colors.green),
            label: const Text(
              'تأكيد عبر واتساب',
              style: TextStyle(color: Colors.green),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmOrder(
    CartProvider cart,
    CustomerAuthProvider auth,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _createOrder(cart, auth);

      if (order != null) {
        // مسح السلة
        cart.clearCart();

        // الانتقال لصفحة النجاح
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            CustomerRoutes.orderSuccess,
            arguments: order.id,
          );
        }
      } else {
        _showError('فشل في تأكيد الطلب');
      }
    } catch (e) {
      _showError('حدث خطأ: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Order?> _createOrder(
    CartProvider cart,
    CustomerAuthProvider auth,
  ) async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    final orderItems = cart.items.map((item) {
      return OrderItem(
        productId: item.productId,
        productName: item.productName,
        productImage: item.productImage,
        price: item.price,
        quantity: item.quantity,
      );
    }).toList();

    final total = cart.getTotalWithCashback(_useCashback ? _cashbackToUse : 0);
    final cashbackEarned =
        cart.subtotal >= CustomerConstants.minimumOrderForCashback
        ? cart.subtotal * CustomerConstants.cashbackPercentage
        : 0.0;

    final order = Order(
      id: '',
      customerId: auth.userId ?? '',
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      customerAddress: _addressController.text.trim(),
      city: '$_selectedGovernorate - $_selectedCity',
      items: orderItems,
      subtotal: cart.subtotal,
      shippingFee: cart.shippingFee,
      totalAmount: total,
      cashbackEarned: cashbackEarned,
      cashbackUsed: _useCashback ? _cashbackToUse : 0,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    return await ordersProvider.createOrder(order);
  }

  void _confirmViaWhatsApp(CartProvider cart, CustomerAuthProvider auth) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final total = cart.getTotalWithCashback(_useCashback ? _cashbackToUse : 0);

    final message = StringBuffer();
    message.writeln('🛒 *طلب جديد من مكنتي*');
    message.writeln('');
    message.writeln('👤 *بيانات العميل:*');
    message.writeln('الاسم: ${_nameController.text}');
    message.writeln('الهاتف: ${_phoneController.text}');
    message.writeln('العنوان: $_selectedGovernorate - $_selectedCity');
    message.writeln('التفاصيل: ${_addressController.text}');
    message.writeln('');
    message.writeln('📦 *المنتجات:*');

    for (final item in cart.items) {
      message.writeln(
        '• ${item.productName} × ${item.quantity} = ${item.subtotal.toStringAsFixed(0)} جنيه',
      );
    }

    message.writeln('');
    message.writeln('💰 *الإجمالي:*');
    message.writeln('المجموع: ${cart.subtotal.toStringAsFixed(0)} جنيه');
    message.writeln('الشحن: ${cart.shippingFee.toStringAsFixed(0)} جنيه');
    if (_useCashback && _cashbackToUse > 0) {
      message.writeln('خصم كاش باك: ${_cashbackToUse.toStringAsFixed(0)} جنيه');
    }
    message.writeln('*المطلوب: ${total.toStringAsFixed(0)} جنيه*');

    if (_notesController.text.isNotEmpty) {
      message.writeln('');
      message.writeln('📝 *ملاحظات:*');
      message.writeln(_notesController.text);
    }

    // رقم واتساب المتجر (يمكن تغييره)
    const whatsappNumber = '201000000000';
    final whatsappUrl =
        'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message.toString())}';

    launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
