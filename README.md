# Jarkom-Modul-5-2025-K-16

## Anggota

## Akses Soal

## MISI 1
## Misi 2: Menemukan Jejak Kegelapan (Security Rules)
### 1
Agar jaringan Aliansi bisa terhubung ke luar (Valinor/Internet), konfigurasi routing menggunakan iptables (TIDAK DIPERBOLEHKAN menggunakan target MASQUERADE).

Karena perlu terhubung ke luar, maka kita lakukan SNAT di router yang terhubung langsung ke internet yaitu Osgiliath. Semua paket yang keluar menuju internet, alamat pengirimnya diganti (SNAT) menjadi alamat IP statis milik router Osgiliath.

```
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source [IP_Interface_Keluar]
```

Kemudian untuk mengecek apakah sudah terhubung ke luar, cek menggunakan `ping 8.8.8.8`

<img width="1198" height="679" alt="image" src="https://github.com/user-attachments/assets/f107ea02-fd16-4378-9301-b7b5ed231bbd" />

Di sini 0% packet loss, artinya ping berhasil yang mana menunjukkan bahwa jaringan aliansi sudah terhubung ke luar.

### 2
Karena Vilya (DHCP) menyimpan data vital, pastikan tidak ada perangkat lain yang bisa melakukan PING ke Vilya. Namun, Vilya tetap leluasa dapat mengakses/ping ke seluruh perangkat lain.

Kita harus memastikan Vilya (DHCP) tidak boleh di-PING orang lain, tapi Vilya boleh PING ke mana saja.

Di Vilya, jalankan:
```
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
```
INPUT adalah trafik masuk. Kita drop echo-request (permintaan ping). Namun, balasan ping (echo-reply) dari luar tetap bisa masuk karena kita tidak memblokirnya, jadi Vilya tetap bisa nge-ping keluar.

Untuk menguji keberhasilannya, lakukan:
- Dari Client lain (misal Durin): ping {IP_Vilya} (Harus Request Timed Out atau hang).
  (screenshot bukti)
- Dari Vilya: ping {IP_Durin} (Harus Reply/Connect).
  (screenshot bukti)

### 3
Agar lokasi pasukan tidak bocor, hanya Vilya yang dapat mengakses Narya (DNS).

Hanya Vilya yang boleh akses port 53 (DNS) di Narya. Sisanya tolak. Izinkan terlebih dahulu, kemudia blokir sisanya.

```
# 1. Izinkan Vilya akses UDP port 53
iptables -A INPUT -s {IP_Vilya} -p udp --dport 53 -j ACCEPT

# 2. Izinkan Vilya akses TCP port 53 (DNS kadang pakai TCP untuk zone transfer/paket besar)
iptables -A INPUT -s {IP_Vilya} -p tcp --dport 53 -j ACCEPT

# 3. Blokir akses port 53 dari SEMUA sumber lain
iptables -A INPUT -p udp --dport 53 -j DROP
iptables -A INPUT -p tcp --dport 53 -j DROP
```

Cara Uji (Gunakan nc / Netcat):
- Dari Vilya: nc -zv {IP_Narya} 53 (Harus Succeeded/Open).
(screenshot bukti)
- Dari Client lain: nc -zv {IP_Narya} 53 (Harus Connection Refused atau Timed Out).
  (screenshot bukti)

### 4
Aktivitas mencurigakan terdeteksi di IronHills. Berdasarkan dekrit Raja, IronHills hanya boleh diakses pada Akhir Pekan (Sabtu & Minggu).
- Akses hanya diizinkan untuk Faksi Kurcaci & Pengkhianat (Durin & Khamul) serta Faksi Manusia (Elendil & Isildur).
- Karena hari ini adalah Rabu (Simulasikan waktu server), mereka harusnya tertolak. Gunakan curl untuk membuktikan blokir waktu ini.

#### Simulasi waktu
Ubah jam di IronHills menjadi Rabu.

```
# Set tanggal ke Rabu, 26 Nov 2025
date -s "2025-11-26 10:00:00"

# Cek tanggal (Pastikan outputnya Wed)
date
```

#### Pasang Satpam Waktu (IPTables Rules) 
Izinkan akses Port 80 (Web) hanya untuk IP Subnet Pasukan (Durin, Khamul, Elendil, Isildur) DAN hanya pada hari Sabtu/Minggu.

```
# 1. Izinkan koneksi yang sudah nyambung (biar gak putus)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 2. Rule untuk Faksi KURCACI (Durin & Khamul) - HANYA SABTU MINGGU
# Subnet Durin (192.219.2.0/26) & Khamul (192.219.2.64/29)
iptables -A INPUT -p tcp --dport 80 -s 192.219.2.0/26 -m time --weekdays Sat,Sun -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 192.219.2.64/29 -m time --weekdays Sat,Sun -j ACCEPT

# 3. Rule untuk Faksi MANUSIA (Elendil & Isildur) - HANYA SABTU MINGGU
# Subnet Minastir Supernet (192.219.0.0/23)
iptables -A INPUT -p tcp --dport 80 -s 192.219.0.0/23 -m time --weekdays Sat,Sun -j ACCEPT

# 4. Blokir sisa akses Web (Port 80) selain yang diizinkan di atas
iptables -A INPUT -p tcp --dport 80 -j DROP
```

#### Pembuktian (Testing)
Skenario Gagal (Hari Rabu):
1. Tetap biarkan jam IronHills di hari Rabu.
2. Buka terminal Durin (atau client lain).
3. Coba akses web:
```
curl http://[IP_IRONHILLS]
# Atau telnet kalau gak ada curl
telnet [IP_IRONHILLS] 80
```

(screenshot hasil)

Skenario Berhasil (Ubah ke Sabtu):
1. Ubah hari menjadi Sabtu di IronHills
   ```
   date -s "2025-11-29 10:00:00"
   ```
2. Akses kembali dari Durin:
   ```
   curl http://[IP_IRONHILLS]
   ```
   (screenshot hasil)

   
