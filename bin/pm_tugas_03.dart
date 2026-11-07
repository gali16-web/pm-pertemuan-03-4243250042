import 'dart:io';

/// Tipe data Record untuk menyimpan data mata kuliah (Nama, SKS, dan Nilai Huruf).
/// Materi: Record dan Typedef (Dart 3).
typedef MataKuliah = ({String nama, int sks, String nilai});

/// Fungsi 1: Mengubah nilai huruf menjadi bobot angka menggunakan switch expression.
/// Spesifikasi 3: Nilai huruf diubah ke bobot (A=4, B=3, C=2, D=1, E=0).
/// Melempar [FormatException] jika huruf bukan A, B, C, D, atau E.
double bobot(String huruf) {
  final h = huruf.trim().toUpperCase();
  return switch (h) {
    'A' => 4.0,
    'B' => 3.0,
    'C' => 2.0,
    'D' => 1.0,
    'E' => 0.0,
    _ => throw FormatException('Nilai harus berupa huruf A, B, C, D, atau E, bukan "$huruf".'),
  };
}

/// Fungsi bantu untuk memvalidasi input SKS (Spesifikasi 4).
/// Melempar [FormatException] jika bukan angka atau tidak berada dalam rentang 1-6.
int validasiSks(String teks) {
  final angka = int.tryParse(teks.trim());
  if (angka == null || angka < 1 || angka > 6) {
    throw FormatException('SKS harus berupa angka 1-6, bukan "$teks".');
  }
  return angka;
}

/// Fungsi 2: Menghitung Indeks Prestasi (IP) satu semester.
/// Spesifikasi 5: Menggunakan higher-order function `fold` (Σ SKS × bobot ÷ Σ SKS).
double hitungIp(List<MataKuliah> data) {
  if (data.isEmpty) return 0.0;

  // Higher-order function: fold untuk menjumlahkan (SKS * bobot)
  final totalBobot = data.fold<double>(
    0.0,
    (total, mk) => total + (mk.sks * bobot(mk.nilai)),
  );

  // Higher-order function: fold untuk menjumlahkan total SKS
  final totalSks = data.fold<int>(
    0,
    (total, mk) => total + mk.sks,
  );

  if (totalSks == 0) return 0.0;
  return totalBobot / totalSks;
}

/// Fungsi 3: Menentukan predikat kelulusan berdasarkan nilai IP.
/// Materi: Switch expression dengan relational pattern (Dart 3).
String predikat(double ip) {
  return switch (ip) {
    >= 3.51 => 'Dengan Pujian (Cumlaude)',
    >= 3.00 => 'Memuaskan',
    >= 2.76 => 'Cukup Memuaskan',
    >= 2.00 => 'Cukup',
    _ => 'Kurang',
  };
}

/// Fungsi 4: Mencetak Kartu Hasil Studi (KHS).
/// Spesifikasi 2: Menggunakan parameter bernama `{bool urutkan = false}`.
/// Spesifikasi 5 & 6: Menggunakan `sort` (fungsi pembanding) dan `where`.
void cetakKhs(List<MataKuliah> data, {bool urutkan = false}) {
  if (data.isEmpty) {
    print('\nTidak ada data mata kuliah yang valid untuk dicetak.');
    return;
  }

  // Membuat salinan list agar data asli tidak teracak
  final dataTampil = List<MataKuliah>.from(data);

  // Spesifikasi 6: Mengurutkan KHS dari nilai tertinggi dengan higher-order function sort
  if (urutkan) {
    dataTampil.sort((a, b) => bobot(b.nilai).compareTo(bobot(a.nilai)));
  }

  print('\n--------------------------------------');
  print('Mata Kuliah            SKS Nilai');
  print('--------------------------------------');
  for (final mk in dataTampil) {
    // Merapikan tampilan kolom teks
    final namaMk = mk.nama.padRight(22);
    final sksMk = mk.sks.toString().padLeft(3);
    final nilaiMk = mk.nilai.padLeft(5);
    print('$namaMk $sksMk $nilaiMk');
  }
  print('--------------------------------------');

  // Menghitung total SKS dan IP
  final totalSks = data.fold<int>(0, (total, mk) => total + mk.sks);
  final ip = hitungIp(data);
  final predikatIp = predikat(ip);

  print('Total SKS : $totalSks');
  print('IP        : ${ip.toStringAsFixed(2)} ($predikatIp)');

  // Spesifikasi 5: Menggunakan higher-order function where untuk memfilter bobot < 2 (D dan E)
  final perluDiperbaiki = data.where((mk) => bobot(mk.nilai) < 2.0).toList();

  if (perluDiperbaiki.isNotEmpty) {
    final namaDiperbaiki = perluDiperbaiki.map((mk) => mk.nama).join(', ');
    print('Perlu diperbaiki: $namaDiperbaiki');
  } else {
    print('Perlu diperbaiki: - (Semua mata kuliah lulus)');
  }
  print('--------------------------------------\n');
}

/// Fungsi bantu untuk membaca input dari keyboard via console (seperti di modul B.1).
String baca(String label) {
  stdout.write('$label : ');
  return (stdin.readLineSync() ?? '').trim();
}

void main() {
  final List<MataKuliah> daftarMk = [];

  print('=== PROGRAM KALKULATOR IP SEMESTER ===');
  print('Masukkan data mata kuliah. Kosongkan nama untuk selesai.\n');

  // Spesifikasi 1: Perulangan input dengan while
  var lanjutInput = true;
  while (lanjutInput) {
    final nama = baca('Nama MK');

    // Jika input nama kosong, hentikan perulangan
    if (nama.isEmpty) {
      lanjutInput = false;
      break;
    }

    // Spesifikasi 4: Input tidak valid melempar exception dan ditangkap dengan try-catch
    try {
      final teksSks = baca('SKS    ');
      final sks = validasiSks(teksSks);

      final nilai = baca('Nilai  ');
      // Memvalidasi nilai huruf (akan melempar FormatException jika tidak valid)
      bobot(nilai);

      // Simpan data record ke dalam list jika semua input valid
      daftarMk.add((nama: nama, sks: sks, nilai: nilai.toUpperCase()));
    } on FormatException catch (e) {
      // Data yang salah diabaikan dan program tetap berjalan
      print('Data diabaikan: ${e.message}');
    }
  }

  // Mencetak KHS dengan opsi urutkan nilai tertinggi (parameter bernama)
  cetakKhs(daftarMk, urutkan: true);
}
