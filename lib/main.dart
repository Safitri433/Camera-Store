import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const CameraStoreApp());
}

const Color navy = Color(0xFF172B4D);
const Color blue = Color(0xFF4169E1);
const Color background = Color(0xFFF5F7FB);

// Akun permanen: tidak terpengaruh oleh perubahan akun hasil registrasi.
const String permanentUserName = 'Novia Safitri';
const String permanentEmail = 'noviasafitri@gmail.com';
const String permanentPassword = '123456';

// ================= APLIKASI =================

class CameraStoreApp extends StatelessWidget {
  const CameraStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camera Store',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= SPLASH SCREEN =================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startApp();
  }

  Future<void> startApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('camera_store_logged_in') ?? false;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn
            ? DashboardPage(
                userName: prefs.getString('camera_store_user_name') ?? permanentUserName,
              )
            : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 75,
                color: navy,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CAMERA STORE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture Your Best Moments',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ================= REGISTER =================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage(context, 'Semua kolom wajib diisi.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showMessage(context, 'Masukkan email yang valid.');
      return;
    }

    if (password.length < 6) {
      showMessage(context, 'Password minimal 6 karakter.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('password', password);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Buat Akun',
      subtitle: 'Bergabung dengan Camera Store',
      children: [
        const Text('Nama lengkap'),
        const SizedBox(height: 8),
        TextField(
          controller: nameController,
          decoration: inputDecoration(
            'Masukkan nama',
            Icons.person_outline,
          ),
        ),
        const SizedBox(height: 18),
        const Text('Email'),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: inputDecoration(
            'Masukkan email',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 18),
        const Text('Password'),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: hidePassword,
          decoration: inputDecoration(
            'Minimal 6 karakter',
            Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => hidePassword = !hidePassword);
              },
              icon: Icon(
                hidePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: navy),
            onPressed: register,
            child: const Text('Daftar Sekarang'),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Sudah punya akun? Login'),
          ),
        ),
      ],
    );
  }
}

// ================= LOGIN =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(context, 'Email dan password wajib diisi.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final isPermanentAccount =
        email == permanentEmail && password == permanentPassword;
    final isRegisteredAccount =
        email == prefs.getString('email') &&
        password == prefs.getString('password') &&
        prefs.getString('email') != null;

    if (isPermanentAccount || isRegisteredAccount) {
      final loggedInName = isPermanentAccount
          ? permanentUserName
          : (prefs.getString('name') ?? 'Pengguna');
      await prefs.setBool('camera_store_logged_in', true);
      await prefs.setString('camera_store_user_name', loggedInName);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(userName: loggedInName),
        ),
      );
    } else {
      showMessage(context, 'Email atau password salah.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Selamat Datang!',
      subtitle: 'Login untuk mulai berbelanja kamera',
      children: [
        const Text('Email'),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: inputDecoration(
            'Masukkan email',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 18),
        const Text('Password'),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: hidePassword,
          decoration: inputDecoration(
            'Masukkan password',
            Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => hidePassword = !hidePassword);
              },
              icon: Icon(
                hidePassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: navy),
            onPressed: login,
            child: const Text('Login'),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            child: const Text('Belum punya akun? Daftar'),
          ),
        ),
      ],
    );
  }
}

// ================= LAYOUT LOGIN =================

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 75,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= DATA PRODUK =================

class Product {
  final String name;
  final String category;
  final String description;
  final int price;
  final String image;
  final double rating;

  const Product({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    this.rating = 4.8,
  });
}

const List<Product> products = [
  Product(
    name: 'Canon EOS R50',
    category: 'Mirrorless Camera',
    description:
        'Kamera mirrorless Canon dengan desain ringkas untuk fotografi, '
        'pembuatan konten, dan dokumentasi sehari-hari.',
    price: 12500000,
    image: 'assets/images/cameracanon.jpg',
    rating: 4.9,
  ),
  Product(
    name: 'Fujifilm X Series',
    category: 'Mirrorless Camera',
    description:
        'Kamera Fujifilm dengan desain klasik yang cocok untuk fotografi '
        'jalanan, perjalanan, dan dokumentasi momen spesial.',
    price: 16000000,
    image: 'assets/images/camerafujifilm.jpg',
    rating: 4.9,
  ),
  Product(
    name: 'Nikon Z Series',
    category: 'Mirrorless Camera',
    description:
        'Kamera Nikon untuk berbagai kebutuhan fotografi dengan desain '
        'ergonomis dan pengoperasian yang nyaman.',
    price: 13500000,
    image: 'assets/images/cameranikon.jpg',
    rating: 4.8,
  ),
  Product(
    name: 'Sony Alpha',
    category: 'Mirrorless Camera',
    description:
        'Kamera Sony untuk fotografi dan pembuatan video. Cocok untuk '
        'dokumentasi, perjalanan, serta pembuatan konten.',
    price: 14500000,
    image: 'assets/images/camerasony.jpg',
    rating: 4.8,
  ),
  Product(
    name: 'Lensa Kamera',
    category: 'Aksesori',
    description:
        'Lensa kamera untuk mendukung berbagai kebutuhan fotografi. '
        'Pastikan kompatibel dengan tipe kamera yang digunakan.',
    price: 3200000,
    image: 'assets/images/lensa_kamera.jpg',
    rating: 4.7,
  ),
  Product(
    name: 'Tripod Kamera',
    category: 'Aksesori',
    description:
        'Tripod untuk membantu menjaga kamera tetap stabil saat '
        'mengambil foto maupun merekam video.',
    price: 450000,
    image: 'assets/images/tripod.jpg',
    rating: 4.7,
  ),
];

// ================= KERANJANG BELANJA =================

class CartStore {
  static final Map<Product, int> items = <Product, int>{};

  static void add(Product product, {int quantity = 1}) {
    items[product] = (items[product] ?? 0) + quantity;
  }

  static void remove(Product product) => items.remove(product);

  static int get totalItems => items.values.fold(0, (sum, qty) => sum + qty);

  static int get totalPrice => items.entries.fold(
        0,
        (sum, entry) => sum + entry.key.price * entry.value,
      );
}

// ================= DASHBOARD =================

class DashboardPage extends StatefulWidget {
  final String userName;

  const DashboardPage({super.key, required this.userName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void _openCheckout() {
    if (CartStore.items.isEmpty) {
      showMessage(context, 'Pilih gambar kamera untuk menambahkan produk ke penjualan.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          initialItems: Map<Product, int>.from(CartStore.items),
          clearCartAfterOrder: true,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  static const String _callCenterNumber = '087777777777';
  static const String _smsCenterNumber = '087777777777';
  static final Uri _nearbyCameraStoresUri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=toko+kamera+near+me',
  );

  Future<void> _openExternal(Uri uri, String failureMessage) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) showMessage(context, failureMessage);
    } catch (_) {
      if (mounted) showMessage(context, failureMessage);
    }
  }

  Future<void> _menuAction(String value) async {
    switch (value) {
      case 'Call Center':
        await _openExternal(
          Uri(scheme: 'tel', path: _callCenterNumber),
          'Tidak bisa membuka menu telepon. Pastikan perangkat mendukung panggilan.',
        );
        break;
      case 'SMS Center':
        await _openExternal(
          Uri(scheme: 'sms', path: _smsCenterNumber),
          'Tidak bisa membuka aplikasi SMS pada perangkat ini.',
        );
        break;
      case 'Lokasi/Maps':
        await _openExternal(
          _nearbyCameraStoresUri,
          'Tidak bisa membuka Google Maps. Periksa koneksi internet.',
        );
        break;
      case 'Riwayat Pembelian':
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PurchaseHistoryPage()),
        );
        break;
      case 'Update User & Password':
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UpdateUserPasswordPage()),
        ).then((_) {
          if (mounted) setState(() {});
        });
        break;
      case 'Logout':
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('camera_store_logged_in', false);
        await prefs.remove('camera_store_user_name');
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.camera_alt_rounded, color: blue, size: 28),
            SizedBox(width: 9),
            Text('Camera Store', style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            icon: Badge(
              isLabelVisible: CartStore.totalItems > 0,
              label: Text(CartStore.totalItems.toString()),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()))
                  .then((_) { if (mounted) setState(() {}); });
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Menu lainnya',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _menuAction,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Call Center', child: ListTile(leading: Icon(Icons.headset_mic_outlined), title: Text('Call Center'), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'SMS Center', child: ListTile(leading: Icon(Icons.sms_outlined), title: Text('SMS Center'), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'Lokasi/Maps', child: ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Lokasi / Maps'), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'Riwayat Pembelian', child: ListTile(leading: Icon(Icons.history_rounded), title: Text('Riwayat Pembelian'), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'Update User & Password', child: ListTile(leading: Icon(Icons.manage_accounts_outlined), title: Text('Update User & Password'), contentPadding: EdgeInsets.zero)),
              PopupMenuDivider(),
              PopupMenuItem(value: 'Logout', child: ListTile(leading: Icon(Icons.logout_rounded), title: Text('Logout'), contentPadding: EdgeInsets.zero)),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, ${widget.userName} 👋', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: navy)),
                    const SizedBox(height: 6),
                    const Text('Temukan kamera terbaik untuk setiap momen.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(23),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [navy, blue]),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CAMERA COLLECTION', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5)),
                                SizedBox(height: 12),
                                Text('Capture Every Beautiful Moment', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                                SizedBox(height: 10),
                                Text('Kamera dan aksesori pilihan.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.camera_alt_rounded, color: Colors.white, size: 70),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text('Koleksi Kamera', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
                    const SizedBox(height: 5),
                    const Text('Ketuk nama untuk deskripsi. Ketuk gambar untuk menambahkan penjualan.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onImageTap: () {
                        setState(() => CartStore.add(product));
                        showMessage(context, '${product.name} ditambahkan ke Total Penjualan.');
                      },
                      onNameTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                        );
                      },
                    );
                  },
                  childCount: products.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  mainAxisExtent: 330,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Material(
          color: blue,
          child: InkWell(
            onTap: _openCheckout,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Penjualan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(formatPrice(CartStore.totalPrice), style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text('Pembayaran  ›', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= PENGATURAN TOKO =================

class StoreSettingsPage extends StatefulWidget {
  const StoreSettingsPage({super.key});

  @override
  State<StoreSettingsPage> createState() => _StoreSettingsPageState();
}

class _StoreSettingsPageState extends State<StoreSettingsPage> {
  final callController = TextEditingController();
  final smsController = TextEditingController();
  final addressController = TextEditingController();
  final mapController = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    callController.text = prefs.getString('store_call_center') ?? '';
    smsController.text = prefs.getString('store_sms_center') ?? '';
    addressController.text = prefs.getString('store_address') ?? '';
    mapController.text = prefs.getString('store_map_url') ?? '';
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    callController.dispose();
    smsController.dispose();
    addressController.dispose();
    mapController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_call_center', callController.text.trim());
    await prefs.setString('store_sms_center', smsController.text.trim());
    await prefs.setString('store_address', addressController.text.trim());
    await prefs.setString('store_map_url', mapController.text.trim());
    if (!mounted) return;
    showMessage(context, 'Pengaturan toko berhasil disimpan. Data tetap tersimpan sampai kamu mengubahnya.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Toko')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Informasi Kontak dan Lokasi', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
                const SizedBox(height: 8),
                const Text('Isi data asli toko. Data akan disimpan di perangkat dan tetap ada meskipun aplikasi ditutup.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 22),
                const Text('Nomor Call Center', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: callController, keyboardType: TextInputType.phone, decoration: inputDecoration('Contoh: 081234567890', Icons.headset_mic_outlined)),
                const SizedBox(height: 18),
                const Text('Nomor SMS Center', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: smsController, keyboardType: TextInputType.phone, decoration: inputDecoration('Masukkan nomor SMS toko', Icons.sms_outlined)),
                const SizedBox(height: 18),
                const Text('Alamat Toko', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: addressController, maxLines: 3, decoration: inputDecoration('Masukkan alamat lengkap toko', Icons.location_on_outlined)),
                const SizedBox(height: 18),
                const Text('Tautan Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: mapController, keyboardType: TextInputType.url, decoration: inputDecoration('Tempel tautan Google Maps toko', Icons.map_outlined)),
                const SizedBox(height: 8),
                const Text('Cara mengambil tautan: buka Google Maps, cari lokasi toko, pilih Bagikan, lalu Salin link dan tempel di kolom ini.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 26),
                SizedBox(height: 52, child: FilledButton.icon(
                  onPressed: _saveSettings,
                  style: FilledButton.styleFrom(backgroundColor: navy),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Pengaturan'),
                )),
              ],
            ),
    );
  }
}

// ================= UPDATE USER & PASSWORD =================

class UpdateUserPasswordPage extends StatefulWidget {
  const UpdateUserPasswordPage({super.key});

  @override
  State<UpdateUserPasswordPage> createState() => _UpdateUserPasswordPageState();
}

class _UpdateUserPasswordPageState extends State<UpdateUserPasswordPage> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final prefs = await SharedPreferences.getInstance();
    userController.text = prefs.getString('email') ?? '';
    passwordController.text = prefs.getString('password') ?? '';
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    final email = userController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      showMessage(context, 'Masukkan email/username yang valid.');
      return;
    }
    if (password.length < 6) {
      showMessage(context, 'Password minimal 6 karakter.');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('email') == null || prefs.getString('password') == null) {
      showMessage(
        context,
        'Belum ada akun registrasi. Silakan daftar terlebih dahulu untuk mengubah email dan password.',
      );
      return;
    }
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    if (!mounted) return;
    showMessage(context, 'Akun registrasi berhasil diperbarui. Akun permanen tetap sama.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User & Password')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.manage_accounts_outlined, size: 56, color: navy),
                          const SizedBox(height: 18),
                          const Text('User / Email', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: userController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: inputDecoration('Masukkan email baru', Icons.person_outline),
                          ),
                          const SizedBox(height: 18),
                          const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            decoration: inputDecoration('Minimal 6 karakter', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => hidePassword = !hidePassword),
                                icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: FilledButton(onPressed: _saveAccount, style: FilledButton.styleFrom(backgroundColor: navy), child: const Text('Update'))),
                              const SizedBox(width: 12),
                              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ================= KARTU PRODUK =================

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onImageTap;
  final VoidCallback onNameTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onImageTap,
    required this.onNameTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Material(
              color: const Color(0xFFEDF1F7),
              child: InkWell(
                onTap: onImageTap,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.camera_alt_rounded, size: 65, color: blue),
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 4,
                        bottom: 4,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: blue,
                          child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 17),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.category, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: blue, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onNameTap,
                  child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navy, decoration: TextDecoration.underline)),
                ),
                const SizedBox(height: 8),
                Text(formatPrice(product.price), maxLines: 1,
                  style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.orange, size: 17),
                    const SizedBox(width: 3),
                    Text(product.rating.toString(), style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    const Icon(Icons.touch_app_outlined, size: 18, color: navy),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= DETAIL PRODUK =================

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 100,
                      color: blue,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE5ECFA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                product.category,
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatPrice(product.price),
              style: const TextStyle(
                color: blue,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Colors.orange,
                ),
                const SizedBox(width: 5),
                Text(product.rating.toString()),
                const SizedBox(width: 10),
                const Text(
                  '• Produk pilihan',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              'Deskripsi Produk',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.description,
              style: const TextStyle(
                height: 1.7,
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        CartStore.add(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} ditambahkan ke keranjang.')),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Keranjang'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: navy,
                        side: const BorderSide(color: navy),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              initialItems: <Product, int>{product: 1},
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(backgroundColor: navy),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Beli Sekarang'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= HALAMAN KERANJANG =================

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final entries = CartStore.items.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: entries.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Keranjang masih kosong'),
                  SizedBox(height: 5),
                  Text('Pilih kamera yang ingin kamu beli.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(entry.key.image, width: 82, height: 82, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(width: 82, height: 82, child: Icon(Icons.camera_alt, size: 36))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key.name, style: const TextStyle(fontWeight: FontWeight.bold, color: navy)),
                            const SizedBox(height: 5),
                            Text(formatPrice(entry.key.price), style: const TextStyle(color: blue, fontWeight: FontWeight.bold)),
                            Row(children: [
                              IconButton(onPressed: () { if (entry.value > 1) { CartStore.items[entry.key] = entry.value - 1; } else { CartStore.remove(entry.key); } refresh(); }, icon: const Icon(Icons.remove_circle_outline)),
                              Text('${entry.value}'),
                              IconButton(onPressed: () { CartStore.items[entry.key] = entry.value + 1; refresh(); }, icon: const Icon(Icons.add_circle_outline)),
                              const Spacer(),
                              IconButton(tooltip: 'Hapus', onPressed: () { CartStore.remove(entry.key); refresh(); }, icon: const Icon(Icons.delete_outline, color: Colors.red)),
                            ]),
                          ],
                        )),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 8),
                Row(children: [const Expanded(child: Text('Total belanja', style: TextStyle(fontSize: 17))), Text(formatPrice(CartStore.totalPrice), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: blue))]),
                const SizedBox(height: 18),
                SizedBox(height: 52, child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: navy),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage(initialItems: Map<Product, int>.from(CartStore.items), clearCartAfterOrder: true))),
                  child: const Text('Checkout'),
                )),
              ],
            ),
    );
  }
}

// ================= CHECKOUT =================

class CheckoutPage extends StatefulWidget {
  final Map<Product, int> initialItems;
  final bool clearCartAfterOrder;

  const CheckoutPage({super.key, required this.initialItems, this.clearCartAfterOrder = false});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final addressController = TextEditingController();
  String paymentMethod = 'DANA';
  String shippingMethod = 'Reguler (2–4 hari)';

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  int get subtotal => widget.initialItems.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);
  int get shippingCost => shippingMethod.startsWith('Express') ? 50000 : 20000;

  @override
  Widget build(BuildContext context) {
    final entries = widget.initialItems.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Alamat Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 10),
          TextField(controller: addressController, maxLines: 3, decoration: inputDecoration('Nama penerima, nomor HP, alamat lengkap', Icons.location_on_outlined)),
          const SizedBox(height: 22),
          const Text('Produk yang dibeli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 8),
          ...entries.map((entry) => Card(child: ListTile(
            leading: Image.asset(entry.key.image, width: 55, height: 55, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.camera_alt)),
            title: Text(entry.key.name),
            subtitle: Text('${entry.value} barang × ${formatPrice(entry.key.price)}'),
            trailing: Text(formatPrice(entry.key.price * entry.value), style: const TextStyle(fontWeight: FontWeight.bold)),
          ))),
          const SizedBox(height: 18),
          const Text('Pilih Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
          RadioListTile<String>(contentPadding: EdgeInsets.zero, value: 'Reguler (2–4 hari)', groupValue: shippingMethod, onChanged: (v) => setState(() => shippingMethod = v!), title: const Text('Reguler (2–4 hari)'), subtitle: const Text('Rp20.000')),
          RadioListTile<String>(contentPadding: EdgeInsets.zero, value: 'Express (1 hari)', groupValue: shippingMethod, onChanged: (v) => setState(() => shippingMethod = v!), title: const Text('Express (1 hari)'), subtitle: const Text('Rp50.000')),
          const SizedBox(height: 12),
          const Text('Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 6),
          ...['DANA', 'OVO', 'GoPay', 'ShopeePay', 'QRIS', 'Transfer Bank', 'Tunai / Cash'].map((method) => RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: method,
            groupValue: paymentMethod,
            onChanged: (value) => setState(() => paymentMethod = value!),
            title: Text(method),
            secondary: Icon(_paymentIcon(method), color: blue),
          )),
          const Divider(height: 28),
          _summaryRow('Subtotal produk', formatPrice(subtotal)),
          const SizedBox(height: 8),
          _summaryRow('Ongkos kirim', formatPrice(shippingCost)),
          const SizedBox(height: 12),
          _summaryRow('Total pembayaran', formatPrice(subtotal + shippingCost), bold: true),
          const SizedBox(height: 20),
          SizedBox(height: 54, child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: navy),
            onPressed: () async {
              if (addressController.text.trim().isEmpty) {
                showMessage(context, 'Isi alamat pengiriman terlebih dahulu.');
                return;
              }
              if (entries.isEmpty) {
                showMessage(context, 'Tidak ada produk untuk dibeli.');
                return;
              }
              final orderItems = Map<Product, int>.from(widget.initialItems);
              final orderNumber = 'CS${DateTime.now().millisecondsSinceEpoch}';
              final orderData = <String, dynamic>{
                'orderNumber': orderNumber,
                'date': DateTime.now().toIso8601String(),
                'items': orderItems.entries.map((entry) => <String, dynamic>{
                  'name': entry.key.name,
                  'price': entry.key.price,
                  'quantity': entry.value,
                }).toList(),
                'address': addressController.text.trim(),
                'paymentMethod': paymentMethod,
                'shippingMethod': shippingMethod,
                'shippingCost': shippingCost,
                'subtotal': subtotal,
                'total': subtotal + shippingCost,
              };
              final prefs = await SharedPreferences.getInstance();
              final savedOrders = prefs.getStringList('purchase_history') ?? <String>[];
              savedOrders.insert(0, jsonEncode(orderData));
              await prefs.setStringList('purchase_history', savedOrders);

              if (widget.clearCartAfterOrder) {
                for (final product in orderItems.keys) { CartStore.remove(product); }
              }
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ReceiptPage(
                items: orderItems,
                address: addressController.text.trim(),
                paymentMethod: paymentMethod,
                shippingMethod: shippingMethod,
                shippingCost: shippingCost,
                orderNumber: orderNumber,
              )));
            },
            child: const Text('Buat Pesanan'),
          )),
          const SizedBox(height: 10),
          const Text('Catatan: pembayaran ini merupakan simulasi aplikasi, belum memproses uang sungguhan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

Widget _summaryRow(String label, String value, {bool bold = false}) {
  return Row(children: [Expanded(child: Text(label, style: TextStyle(fontSize: bold ? 17 : 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal))), Text(value, style: TextStyle(fontSize: bold ? 19 : 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? blue : navy))]);
}

IconData _paymentIcon(String method) {
  switch (method) {
    case 'DANA': return Icons.account_balance_wallet_outlined;
    case 'OVO': return Icons.wallet_outlined;
    case 'GoPay': return Icons.phone_android_outlined;
    case 'ShopeePay': return Icons.shopping_bag_outlined;
    case 'QRIS': return Icons.qr_code_2;
    case 'Transfer Bank': return Icons.account_balance_outlined;
    default: return Icons.payments_outlined;
  }
}

// ================= NOTA PESANAN =================

class ReceiptPage extends StatelessWidget {
  final Map<Product, int> items;
  final String address;
  final String paymentMethod;
  final String shippingMethod;
  final int shippingCost;
  final String orderNumber;

  const ReceiptPage({super.key, required this.items, required this.address, required this.paymentMethod, required this.shippingMethod, required this.shippingCost, required this.orderNumber});

  Future<void> _printReceipt() async {
    final subtotal = items.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(child: pw.Text('CAMERA STORE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 6),
        pw.Center(child: pw.Text('STRUK PEMBELIAN')),
        pw.Divider(),
        pw.Text('Nomor Pesanan: $orderNumber'),
        pw.Text('Tanggal: ${DateTime.now().toLocal()}'),
        pw.SizedBox(height: 8),
        pw.Text('Alamat: $address'),
        pw.SizedBox(height: 12),
        pw.Text('RINCIAN PRODUK', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        ...items.entries.map((entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Text('${entry.key.name} x ${entry.value}')),
            pw.Text(formatPrice(entry.key.price * entry.value)),
          ]),
        )),
        pw.Divider(),
        pw.Text('Pengiriman: $shippingMethod'),
        pw.Text('Pembayaran: $paymentMethod'),
        pw.SizedBox(height: 8),
        pw.Row(children: [pw.Expanded(child: pw.Text('Subtotal')), pw.Text(formatPrice(subtotal))]),
        pw.Row(children: [pw.Expanded(child: pw.Text('Ongkos kirim')), pw.Text(formatPrice(shippingCost))]),
        pw.Divider(),
        pw.Row(children: [pw.Expanded(child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))), pw.Text(formatPrice(subtotal + shippingCost), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
        pw.SizedBox(height: 20),
        pw.Center(child: pw.Text('Terima kasih telah berbelanja di Camera Store.')),
      ],
    )));
    await Printing.layoutPdf(onLayout: (_) async => pdf.save(), name: 'Struk_$orderNumber.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = items.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);
    return Scaffold(
      appBar: AppBar(title: const Text('Nota Pesanan'), automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 76),
        const SizedBox(height: 10),
        const Text('Pesanan berhasil dibuat!', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 6),
        const Text('Berikut ringkasan pesanan kamu.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 22),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nomor Pesanan', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          SelectableText(orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 28),
          const Text('Produk', style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 8),
          ...items.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text('${entry.key.name} × ${entry.value}')), Text(formatPrice(entry.key.price * entry.value))]))),
          const Divider(height: 24),
          const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 5),
          Text(address),
          const SizedBox(height: 16),
          _summaryRow('Pengiriman', shippingMethod),
          const SizedBox(height: 8),
          _summaryRow('Metode pembayaran', paymentMethod),
          const Divider(height: 24),
          _summaryRow('Subtotal', formatPrice(subtotal)),
          const SizedBox(height: 8),
          _summaryRow('Ongkos kirim', formatPrice(shippingCost)),
          const SizedBox(height: 12),
          _summaryRow('Total', formatPrice(subtotal + shippingCost), bold: true),
        ]))),
        const SizedBox(height: 18),
        SizedBox(height: 50, child: OutlinedButton.icon(
          onPressed: _printReceipt,
          icon: const Icon(Icons.print_outlined),
          label: const Text('Cetak / Simpan Struk'),
        )),
        const SizedBox(height: 10),
        SizedBox(height: 50, child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: navy),
          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginOrDashboardReturn()), (route) => false),
          child: const Text('Selesai'),
        )),
      ]),
    );
  }
}

// ================= RIWAYAT PEMBELIAN =================

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<Map<String, dynamic>>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList('purchase_history') ?? <String>[];
    return values.map((value) => Map<String, dynamic>.from(jsonDecode(value) as Map)).toList();
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    final date = DateTime.tryParse(raw.toString())?.toLocal();
    if (date == null) return raw.toString();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pembelian')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? <Map<String, dynamic>>[];
          if (history.isEmpty) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada riwayat pembelian', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: navy)),
                SizedBox(height: 6),
                Text('Pesanan yang berhasil dibuat akan muncul di sini.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              ]),
            ));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final order = history[index];
              final orderItems = (order['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
              final names = orderItems.map((e) => '${e['name']} × ${e['quantity']}').join(', ');
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.receipt_long, color: blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(order['orderNumber']?.toString() ?? 'Pesanan', style: const TextStyle(fontWeight: FontWeight.bold, color: navy))),
                    ]),
                    const SizedBox(height: 5),
                    Text(_formatDate(order['date']), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const Divider(height: 20),
                    Text(names.isEmpty ? 'Produk' : names, maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('Pembayaran: ${order['paymentMethod'] ?? '-'}'),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600))),
                      Text(formatPrice((order['total'] as num?)?.toInt() ?? 0), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: blue)),
                    ]),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Kembali ke katalog tanpa menghapus sesi login.
class LoginOrDashboardReturn extends StatelessWidget {
  const LoginOrDashboardReturn({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return DashboardPage(
          userName: snapshot.data!.getString('camera_store_user_name') ??
              snapshot.data!.getString('name') ??
              permanentUserName,
        );
      },
    );
  }
}

// ================= FUNGSI BANTUAN =================

InputDecoration inputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: blue, width: 1.5),
    ),
  );
}

String formatPrice(int price) {
  final value = price.toString();
  final result = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    result.write(value[i]);

    final remaining = value.length - i - 1;

    if (remaining > 0 && remaining % 3 == 0) {
      result.write('.');
    }
  }

  return 'Rp$result';
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}