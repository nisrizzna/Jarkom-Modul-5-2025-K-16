# Jarkom-Modul-5-2025-K-16

## Anggota

## Akses Soal

## MISI 1 

**Topik:** Infrastruktur Jaringan Aliansi (Routing VLSM, DHCP, DNS, & Web Server)  
**Domain:** `k16.com`  
**Base IP:** `192.219.0.0`  
**Environment:** GNS3 (Docker Image: `nevarre/gns3-debi:new`)

---

## 🗺️ I. Desain Jaringan & VLSM

Kami menerapkan teknik **Supernetting** pada jalur Kanan (Minastir) untuk menyederhanakan routing table di pusat (Osgiliath), dan **Fixed Subnetting** pada jalur Kiri dan Bawah.

### 📊 Tabel Pembagian IP Final

| Wilayah | Node / Subnet | Prefix | Network ID | Range IP | Gateway |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **MINASTIR** | **Supernet Area** | **/23** | **192.219.0.0** | `0.1` - `1.254` | **Osgiliath (.0.1)** |
| ├── | Elendil & Isildur | /24 | 192.219.0.0 | `0.1` - `0.254` | Minastir (.0.3) |
| ├── | Gilgalad & Cirdan | /25 | 192.219.1.0 | `1.1` - `1.126` | AnduinBanks (.1.1) |
| ├── | Link & Web Server 2 | /29 | 192.219.1.x | `1.129` - ... | (Pelargir Area) |
| | | | | | |
| **MORIA** | **Subnet Area** | **/25** | **192.219.2.0** | `2.1` - `2.126` | **Osgiliath (.2.1)** |
| ├── | Durin (Client) | /26 | 192.219.2.0 | `2.1` - `2.62` | Wilderland (.2.3) |
| ├── | Khamul (Client) | /29 | 192.219.2.64 | `2.65` - `2.70` | Wilderland (.2.65) |
| ├── | IronHills (Web) | /29 | 192.219.2.80 | `2.81` - `2.86` | Moria (.2.81) |
| | | | | | |
| **RIVENDELL**| **Server Farm** | **/25** | **192.219.2.128**| `2.129` - `2.254`| **Osgiliath (.2.129)**|
| └── | Vilya & Narya | /29 | 192.219.2.136| `2.137` - `2.142`| Rivendell (.2.137) |

---

## 🛠️ II. Konfigurasi Routing & Backbone

### 1. OSGILIATH (Router Pusat)
Berfungsi sebagai gerbang internet (NAT).
*   **NAT:** Menggunakan `SNAT` (Source NAT) tanpa Masquerade.
*   **MSS Clamping:** Diaktifkan (`iptables -t mangle ... TCPMSS`) untuk mencegah packet loss/timeout pada jaringan simulasi.
*   **Routing:** Mengarahkan Supernet Minastir (`0.0/23`) ke router Minastir dan Subnet Server ke Rivendell.

### 2. MORIA (Router Kiri)
*   **Problem:** Konflik VLSM (Longest Prefix Match) dimana IP Osgiliath (`2.1`) tertutup oleh Subnet Durin (`2.0/26`).
*   **Solusi:**
    *   Mengaktifkan **Proxy ARP**.
    *   Menambahkan **Exception Route /32** agar paket ke Osgiliath tidak dilempar balik ke Wilderland.

### 3. MINASTIR - PELARGIR (Router Kanan)
*   **Problem:** Routing Loop (Ping-Pong) paket nyasar antara router bertingkat.
*   **Solusi:** Menambahkan **Blackhole Route** (`ip route add blackhole ...`) untuk membuang paket yang tujuannya tidak valid, mencegah CPU Load 100%.

---

## 🖥️ III. Konfigurasi Service (Server)

### 1. VILYA (DHCP Server - ISC DHCP)
*   **Config:** Memberikan IP ke seluruh client via Relay.
*   **Fix:** Gateway untuk subnet Durin diarahkan ke **Wilderland (.2.3)**, bukan Osgiliath.
*   **Fix:** Gateway untuk subnet Elendil diarahkan ke **Minastir (.0.3)**.

### 2. NARYA (DNS Server - Bind9)
*   **Forwarder:** Google DNS (8.8.8.8).
*   **Fix SERVFAIL:** Menonaktifkan `dnssec-validation no;` agar domain lokal `k16.com` dapat di-resolve.
*   **Records:** `www` diarahkan ke Web Server (IronHills/Palantir).

### 3. IRONHILLS & PALANTIR (Web Server)
*   **Stack:** Nginx + PHP 8.4 (FPM).
*   **Fix 502 Bad Gateway:** Menyesuaikan konfigurasi `fastcgi_pass` Nginx agar mengarah ke socket PHP yang tepat (`php8.4-fpm.sock`).
*   **Fix 403 Forbidden:** Memastikan izin akses folder web dimiliki oleh user `www-data`.

---

## 🚑 IV. Dokumentasi Troubleshooting

### 🔴 Masalah 1: "Destination Host Unreachable" (Ping Osgiliath Gagal)
*   **Penyebab:** Router anak (Moria/Wilderland) mengira IP Osgiliath berada di subnet lokal (bawah) karena overlap VLSM.
*   **Solusi:** Menambahkan route spesifik: `ip route add 192.219.2.1/32 dev eth0`.

### 🔴 Masalah 2: Client Dapat IP Tapi Tidak Bisa Internet
*   **Penyebab:** DHCP Server memberikan Default Gateway yang salah (mengarah ke Router Pusat, bukan Relay terdekat).
*   **Solusi:** Edit `dhcpd.conf` di Vilya, ubah `option routers` sesuai IP Relay masing-masing wilayah.

### 🔴 Masalah 3: "Network Unreachable" saat apt update
*   **Penyebab:** IPv6 aktif (mencoba connect via IPv6 lalu timeout) dan MTU interface terlalu besar (1500).
*   **Solusi:**
    1.  Disable IPv6 via sysctl.
    2.  Set MTU interface ke 1280.
    3.  Ganti repository ke Kartolo (HTTP).

### 🔴 Masalah 4: DNS SERVFAIL
*   **Penyebab:** Validasi DNSSEC gagal karena domain `k16.com` tidak terdaftar resmi di internet.
*   **Solusi:** Set `dnssec-validation no;` pada konfigurasi Bind9.

---

## ✅ V. Hasil Akhir Misi 1

| Komponen | Status | Bukti |
| :--- | :---: | :--- |
| **Routing** | ✅ OK | Ping antar ujung (Durin -> Elendil) berhasil. |
| **Internet** | ✅ OK | `ping 8.8.8.8` reply dari semua node. |
| **DHCP** | ✅ OK | Client mendapatkan IP & Gateway yang valid. |
| **DNS** | ✅ OK | `nslookup k16.com` menghasilkan IP Web Server. |
| **Web** | ✅ OK | `lynx www.k16.com` menampilkan halaman "WELCOME". |

---
*Laporan dibuat oleh Kelompok 16 - Praktikum Jarkom Modul 5.*


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

   
