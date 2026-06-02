# 🌾 SatuTani AI Service

Python FastAPI microservice yang menjalankan LangChain ReAct Agent untuk rekomendasi pertanian cerdas.

## Arsitektur
```
NestJS (port 4000) ──HTTP──▶ FastAPI AI Service (port 8000)
                                      │
                              LangChain ReAct Agent
                              (llama-3.3-70b via Groq)
                                      │
                    ┌─────────────────┼─────────────────┐
               BMKG API          Gaussian           ChromaDB
             (cuaca real)        Scoring            (RAG hama)
```

## Setup

### 1. Buat virtual environment
```bash
cd backend/ai
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/macOS
source venv/bin/activate
```

### 2. Install dependencies
```bash
pip install -r requirements.txt
```

### 3. Konfigurasi environment
```bash
cp .env.example .env
# Edit .env jika perlu mengganti API key
```

### 4. Jalankan service
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Service akan berjalan di `http://localhost:8000`.

## Endpoints

| Method | Path | Deskripsi |
|--------|------|-----------|
| `GET` | `/health` | Status service |
| `GET` | `/wilayah` | Daftar wilayah (6 kota Jabar) |
| `GET` | `/komoditas` | Daftar 20 komoditas knowledge base |
| `POST` | `/chat` | Kirim pesan ke AI agent |

### Contoh POST /chat
```json
// Request
{
  "message": "Komoditas apa yang cocok ditanam di Lembang bulan ini?",
  "wilayah": "Lembang",
  "farmer_id": "uuid-petani"
}

// Response
{
  "reply": "🌤️ Kondisi Saat Ini:\n...",
  "wilayah": "Lembang",
  "tools_used": []
}
```

## 6 LangChain Tools

| Tool | Input | Fungsi |
|------|-------|--------|
| `get_cuaca_realtime` | `wilayah` | BMKG API + cuaca_score Gaussian |
| `rekomendasikan_komoditas` | `wilayah` | Ranking 10 komoditas |
| `jadwal_tanam_terbaik` | `wilayah,komoditas` | Proyeksi 8 minggu |
| `info_hama_penyakit` | `query` | RAG ChromaDB (pest & disease) |
| `estimasi_hasil_panen` | `wilayah,komoditas,luas_ha` | Yield & revenue projection |
| `cek_harga_pasar` | `wilayah[,komoditas]` | Demand & harga SatuTani |

## Wilayah yang Didukung
- Lembang
- Bandung Kota
- Bekasi
- Tasikmalaya
- Cianjur
- Sukabumi

## Notes
- Service melakukan startup init (~30-60 detik): scraping BMKG, build ChromaDB, load embeddings
- Jika BMKG tidak tersedia, otomatis fallback ke data klimatologi historis
- Model LLM: `llama-3.3-70b-versatile` via Groq Cloud
