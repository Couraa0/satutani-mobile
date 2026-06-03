# -*- coding: utf-8 -*-
"""
SatuTani AI Microservice
FastAPI wrapper untuk SatuTani LangChain Agent.
Dikonversi dari satutani_chatbot.py (Colab Notebook).

Endpoints:
  POST /chat      — kirim pesan ke agent, dapat reply AI
  GET  /health    — status service
  GET  /wilayah   — daftar wilayah yang didukung
  GET  /komoditas — daftar komoditas knowledge base
"""
#Import
import os
import json
import math
import time
import logging
import requests

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Optional

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# ── LangChain ────────────────────────────────────────────────────────────────
from langchain_core.tools import tool
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_groq import ChatGroq
from langchain.agents import create_openai_tools_agent, AgentExecutor

# ── Logging ───────────────────────────────────────────────────────────────────
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("satutani-ai")

# ── Load env ──────────────────────────────────────────────────────────────────
load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "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")
os.environ["GROQ_API_KEY"] = GROQ_API_KEY

# =============================================================================
# KNOWLEDGE BASE KOMODITAS (FAO + Kementan)
# =============================================================================
KNOWLEDGE_BASE = [
    # ── Hortikultura ─────────────────────────────────────────────────────────
    {"commodity":"cabai",          "nama_lokal":"Cabai Merah",    "temp_min":18,"temp_max":27,"rain_min":600, "rain_max":1250,"humidity_min":60,"humidity_max":80,"growing_days":120,"yield_ton_per_ha":15,"harga_base":35000},
    {"commodity":"cabai_rawit",    "nama_lokal":"Cabai Rawit",    "temp_min":20,"temp_max":30,"rain_min":500, "rain_max":1200,"humidity_min":60,"humidity_max":80,"growing_days":110,"yield_ton_per_ha":10,"harga_base":40000},
    {"commodity":"tomat",          "nama_lokal":"Tomat",          "temp_min":18,"temp_max":25,"rain_min":400, "rain_max":800, "humidity_min":60,"humidity_max":80,"growing_days":100,"yield_ton_per_ha":20,"harga_base":8000},
    {"commodity":"terong",         "nama_lokal":"Terong Ungu",    "temp_min":22,"temp_max":30,"rain_min":500, "rain_max":1000,"humidity_min":65,"humidity_max":80,"growing_days":90, "yield_ton_per_ha":25,"harga_base":6000},
    {"commodity":"timun",          "nama_lokal":"Mentimun",       "temp_min":21,"temp_max":30,"rain_min":200, "rain_max":400, "humidity_min":60,"humidity_max":80,"growing_days":45, "yield_ton_per_ha":20,"harga_base":4500},
    {"commodity":"buncis",         "nama_lokal":"Buncis",         "temp_min":16,"temp_max":24,"rain_min":300, "rain_max":500, "humidity_min":60,"humidity_max":75,"growing_days":60, "yield_ton_per_ha":12,"harga_base":7000},
    {"commodity":"kacang_panjang", "nama_lokal":"Kacang Panjang", "temp_min":24,"temp_max":32,"rain_min":500, "rain_max":1000,"humidity_min":60,"humidity_max":80,"growing_days":60, "yield_ton_per_ha":10,"harga_base":7000},
    # ── Sayuran daun ─────────────────────────────────────────────────────────
    {"commodity":"kangkung",       "nama_lokal":"Kangkung",       "temp_min":25,"temp_max":30,"rain_min":500, "rain_max":900, "humidity_min":75,"humidity_max":85,"growing_days":27, "yield_ton_per_ha":8, "harga_base":3000},
    {"commodity":"bayam",          "nama_lokal":"Bayam",          "temp_min":18,"temp_max":25,"rain_min":100, "rain_max":200, "humidity_min":60,"humidity_max":75,"growing_days":30, "yield_ton_per_ha":6, "harga_base":4000},
    {"commodity":"sawi",           "nama_lokal":"Sawi Hijau",     "temp_min":20,"temp_max":28,"rain_min":200, "rain_max":400, "humidity_min":60,"humidity_max":80,"growing_days":40, "yield_ton_per_ha":10,"harga_base":4000},
    {"commodity":"selada",         "nama_lokal":"Selada",         "temp_min":15,"temp_max":20,"rain_min":250, "rain_max":500, "humidity_min":60,"humidity_max":80,"growing_days":45, "yield_ton_per_ha":15,"harga_base":8000},
    # ── Umbi ─────────────────────────────────────────────────────────────────
    {"commodity":"wortel",         "nama_lokal":"Wortel",         "temp_min":15,"temp_max":22,"rain_min":200, "rain_max":400, "humidity_min":60,"humidity_max":75,"growing_days":100,"yield_ton_per_ha":25,"harga_base":6000},
    {"commodity":"kentang",        "nama_lokal":"Kentang",        "temp_min":15,"temp_max":20,"rain_min":500, "rain_max":700, "humidity_min":60,"humidity_max":80,"growing_days":100,"yield_ton_per_ha":20,"harga_base":10000},
    {"commodity":"bawang_merah",   "nama_lokal":"Bawang Merah",   "temp_min":18,"temp_max":25,"rain_min":350, "rain_max":550, "humidity_min":50,"humidity_max":70,"growing_days":90, "yield_ton_per_ha":10,"harga_base":25000},
    # ── Pangan ───────────────────────────────────────────────────────────────
    {"commodity":"jagung",         "nama_lokal":"Jagung",         "temp_min":21,"temp_max":30,"rain_min":500, "rain_max":1200,"humidity_min":50,"humidity_max":80,"growing_days":75, "yield_ton_per_ha":12,"harga_base":4000},
    {"commodity":"padi",           "nama_lokal":"Padi Sawah",     "temp_min":22,"temp_max":30,"rain_min":1200,"rain_max":2000,"humidity_min":70,"humidity_max":90,"growing_days":120,"yield_ton_per_ha":6, "harga_base":5000},
    # ── Buah ─────────────────────────────────────────────────────────────────
    {"commodity":"stroberi",       "nama_lokal":"Stroberi",       "temp_min":14,"temp_max":24,"rain_min":600, "rain_max":1200,"humidity_min":70,"humidity_max":85,"growing_days":90, "yield_ton_per_ha":15,"harga_base":45000},
    {"commodity":"semangka",       "nama_lokal":"Semangka",       "temp_min":22,"temp_max":32,"rain_min":300, "rain_max":600, "humidity_min":60,"humidity_max":80,"growing_days":80, "yield_ton_per_ha":20,"harga_base":5000},
    {"commodity":"melon",          "nama_lokal":"Melon",          "temp_min":20,"temp_max":30,"rain_min":200, "rain_max":400, "humidity_min":60,"humidity_max":80,"growing_days":75, "yield_ton_per_ha":18,"harga_base":9000},
    {"commodity":"pisang",         "nama_lokal":"Pisang",         "temp_min":25,"temp_max":35,"rain_min":1200,"rain_max":2500,"humidity_min":70,"humidity_max":90,"growing_days":300,"yield_ton_per_ha":30,"harga_base":3000},
]

KB_DICT        = {k["commodity"]: k for k in KNOWLEDGE_BASE}
df_kb          = pd.DataFrame(KNOWLEDGE_BASE)
KOMODITAS_UTAMA = [k["commodity"] for k in KNOWLEDGE_BASE]

# =============================================================================
# KONFIGURASI WILAYAH
# =============================================================================
WILAYAH_TARGET = [
    {"nama":"Lembang",      "adm4":"32.17.06.2003","lat":-6.8100,"lon":107.6100},
    {"nama":"Bandung Kota", "adm4":"32.73.04.1001","lat":-6.9147,"lon":107.6098},
    {"nama":"Bekasi",       "adm4":"32.16.01.2001","lat":-6.2383,"lon":106.9756},
    {"nama":"Tasikmalaya",  "adm4":"32.78.01.1001","lat":-7.3274,"lon":108.2207},
    {"nama":"Cianjur",      "adm4":"32.03.01.2001","lat":-6.8200,"lon":107.1400},
    {"nama":"Sukabumi",     "adm4":"32.02.32.2003","lat":-6.9200,"lon":106.9300},
]
WILAYAH_DICT  = {w["nama"]: w for w in WILAYAH_TARGET}
WILAYAH_NAMES = [w["nama"] for w in WILAYAH_TARGET]
MINGGU_KE_DEPAN = 8

# =============================================================================
# IKLIM FALLBACK (jika BMKG tidak tersedia)
# =============================================================================
IKLIM_WILAYAH = {
    "Lembang":      {"suhu":(16,21),"hujan":(15,40),"lembab":(80,93)},
    "Bandung Kota": {"suhu":(19,26),"hujan":(8, 28),"lembab":(68,84)},
    "Bekasi":       {"suhu":(27,35),"hujan":(3, 18),"lembab":(55,72)},
    "Tasikmalaya":  {"suhu":(20,28),"hujan":(10,32),"lembab":(70,86)},
    "Cianjur":      {"suhu":(18,27),"hujan":(8, 28),"lembab":(72,88)},
    "Sukabumi":     {"suhu":(19,28),"hujan":(10,30),"lembab":(70,87)},
}

# =============================================================================
# HARGA & DEMAND DATASET (dibangun saat startup)
# =============================================================================
HARGA_BASE = {k["commodity"]: k["harga_base"] for k in KNOWLEDGE_BASE}
PRICE_MODIFIER = {
    "Lembang":      {"cabai":1.05,"cabai_rawit":1.05,"tomat":0.90,"terong":0.95,"timun":1.00,"buncis":0.90,"kacang_panjang":1.00,"kangkung":1.00,"bayam":0.95,"sawi":0.90,"selada":0.90,"wortel":0.90,"kentang":0.90,"bawang_merah":1.00,"jagung":1.00,"padi":1.00,"stroberi":0.85,"semangka":1.10,"melon":1.10,"pisang":1.05},
    "Bandung Kota": {"cabai":1.10,"cabai_rawit":1.10,"tomat":1.05,"terong":1.05,"timun":1.05,"buncis":1.00,"kacang_panjang":1.05,"kangkung":1.05,"bayam":1.00,"sawi":1.00,"selada":1.05,"wortel":1.05,"kentang":1.05,"bawang_merah":1.10,"jagung":1.05,"padi":1.05,"stroberi":1.00,"semangka":1.10,"melon":1.10,"pisang":1.05},
    "Bekasi":       {"cabai":1.20,"cabai_rawit":1.20,"tomat":1.15,"terong":1.10,"timun":1.10,"buncis":1.10,"kacang_panjang":1.10,"kangkung":1.15,"bayam":1.10,"sawi":1.15,"selada":1.15,"wortel":1.15,"kentang":1.15,"bawang_merah":1.20,"jagung":1.10,"padi":1.10,"stroberi":1.30,"semangka":1.05,"melon":1.10,"pisang":1.10},
    "Tasikmalaya":  {"cabai":0.95,"cabai_rawit":0.95,"tomat":0.95,"terong":0.90,"timun":0.95,"buncis":0.95,"kacang_panjang":0.90,"kangkung":0.95,"bayam":0.90,"sawi":0.95,"selada":1.00,"wortel":0.95,"kentang":1.00,"bawang_merah":0.95,"jagung":0.95,"padi":0.90,"stroberi":1.10,"semangka":1.00,"melon":1.00,"pisang":0.90},
    "Cianjur":      {"cabai":0.90,"cabai_rawit":0.90,"tomat":0.85,"terong":0.90,"timun":0.90,"buncis":0.90,"kacang_panjang":0.90,"kangkung":0.90,"bayam":0.90,"sawi":0.90,"selada":0.90,"wortel":0.85,"kentang":0.90,"bawang_merah":0.90,"jagung":0.90,"padi":0.90,"stroberi":0.90,"semangka":0.95,"melon":0.95,"pisang":0.95},
    "Sukabumi":     {"cabai":0.95,"cabai_rawit":0.95,"tomat":0.90,"terong":0.90,"timun":0.90,"buncis":0.90,"kacang_panjang":0.90,"kangkung":0.90,"bayam":0.90,"sawi":0.90,"selada":0.95,"wortel":0.90,"kentang":0.95,"bawang_merah":0.90,"jagung":0.90,"padi":0.90,"stroberi":0.95,"semangka":0.95,"melon":0.95,"pisang":0.90},
}

# =============================================================================
# KNOWLEDGE BASE HAMA & PENYAKIT (static fallback — RAG dinonaktifkan)
# =============================================================================
INFO_HAMA_STATIC = {
    "thrips": "Hama Thrips: semprot spinosad/abamectin tiap 7 hari. Gunakan mulsa perak.",
    "antraknosa": "Antraknosa Cabai: fungisida mankozeb, sanitasi kebun, panen serempak.",
    "ulat": "Ulat Grayak/Buah: semprot Bacillus thuringiensis (Bt) atau klorantraniliprol.",
    "layu": "Layu Fusarium: varietas tahan, solarisasi tanah, aplikasi trichoderma.",
    "bulai": "Bulai Jagung: seed treatment metalaxyl, semprot mankozeb tiap 7 hari.",
    "default": "Untuk info hama & penyakit spesifik, konsultasikan ke penyuluh pertanian setempat.",
}

# =============================================================================
# FUNGSI HELPER
# =============================================================================

def gaussian(value: float, ideal_min: float, ideal_max: float, penalty: float = 3.5) -> float:
    if ideal_min <= value <= ideal_max:
        return 1.0
    spread   = (ideal_max - ideal_min) / 2 + 1e-9
    distance = min(abs(value - ideal_min), abs(value - ideal_max))
    return round(math.exp(-penalty * (distance / spread) ** 2), 3)


def hitung_cuaca_score(row: dict, kb: dict) -> float:
    rain_annual = row["rainfall_mm"] * 52
    s_temp  = gaussian(row["temperature_avg"], kb["temp_min"],     kb["temp_max"])
    s_rain  = gaussian(rain_annual,            kb["rain_min"],     kb["rain_max"])
    s_humid = gaussian(row["humidity"],        kb["humidity_min"], kb["humidity_max"])
    return round(s_rain*0.40 + s_temp*0.35 + s_humid*0.25, 3)


def ambil_cuaca_bmkg(adm4: str, nama: str) -> list:
    url = f"https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4={adm4}"
    try:
        r = requests.get(url, headers={"User-Agent":"SatuTani/2.0"}, timeout=15)
        r.raise_for_status()
        cuaca_list = r.json().get("data",[{}])[0].get("cuaca",[])
        semua = []
        for g in cuaca_list:
            semua.extend(g) if isinstance(g, list) else semua.append(g)
        df_raw = pd.DataFrame(semua)
        if df_raw.empty: return []
        df_raw["datetime"] = pd.to_datetime(df_raw["local_datetime"], errors="coerce")
        df_raw["week_num"] = ((df_raw["datetime"] - datetime.now()) / np.timedelta64(1,"W")).astype(int) + 1
        df_raw = df_raw[df_raw["week_num"].between(1, MINGGU_KE_DEPAN)]
        hasil = []
        for week, grp in df_raw.groupby("week_num"):
            hasil.append({
                "region":nama, "adm4":adm4, "week":int(week),
                "week_start":(datetime.now()+timedelta(weeks=int(week)-1)).strftime("%Y-%m-%d"),
                "temperature_avg":round(pd.to_numeric(grp.get("t",  pd.Series()), errors="coerce").mean(),1),
                "temperature_min":round(pd.to_numeric(grp.get("t",  pd.Series()), errors="coerce").min(), 1),
                "temperature_max":round(pd.to_numeric(grp.get("t",  pd.Series()), errors="coerce").max(), 1),
                "rainfall_mm":    round(pd.to_numeric(grp.get("tp", pd.Series(dtype=float)), errors="coerce").sum(),1),
                "humidity":       round(pd.to_numeric(grp.get("hu", pd.Series()), errors="coerce").mean(),1),
                "wind_speed":     round(pd.to_numeric(grp.get("ws", pd.Series()), errors="coerce").mean(),1),
                "source":         "BMKG_API",
            })
        return hasil
    except Exception as e:
        logger.warning(f"BMKG {nama}: {e}")
        return []


def cuaca_fallback(nama: str) -> list:
    iklim = IKLIM_WILAYAH[nama]
    rows = []
    for week in range(1, MINGGU_KE_DEPAN+1):
        f = 1 - week*0.04
        rows.append({
            "region":nama, "adm4":WILAYAH_DICT[nama]["adm4"], "week":week,
            "week_start":(datetime.now()+timedelta(weeks=week-1)).strftime("%Y-%m-%d"),
            "temperature_avg":round(np.random.uniform(*iklim["suhu"])+week*0.3,1),
            "temperature_min":round(iklim["suhu"][0]-2,1),
            "temperature_max":round(iklim["suhu"][1]+2,1),
            "rainfall_mm":    round(max(3, np.random.uniform(*iklim["hujan"])*f),1),
            "humidity":       round(max(50,np.random.uniform(*iklim["lembab"])*f),1),
            "wind_speed":     round(np.random.uniform(3,12),1),
            "source":         "SIMULASI_KLIMATOLOGI",
        })
    return rows


def fetch_cuaca_sekarang(nama_wilayah: str) -> dict:
    mask = (df_weather["region"] == nama_wilayah) & (df_weather["week"] == 1)
    row  = df_weather[mask]
    r = row.iloc[0].to_dict() if not row.empty else {
        "region":nama_wilayah,"week":1,
        "week_start":datetime.now().strftime("%Y-%m-%d"),
        "temperature_avg":24.0,"temperature_min":20.0,"temperature_max":30.0,
        "rainfall_mm":15.0,"humidity":75.0,"wind_speed":7.0,"source":"DEFAULT",
    }
    r["scores_per_komoditas"] = {k: hitung_cuaca_score(r, KB_DICT[k]) for k in KOMODITAS_UTAMA}
    r["cuaca_score_avg"] = round(np.mean(list(r["scores_per_komoditas"].values())), 3)
    return r


# =============================================================================
# BUILD DATASETS (dijalankan sekali saat startup)
# =============================================================================

def build_weather_dataset() -> pd.DataFrame:
    logger.info("Membangun dataset cuaca...")
    semua_cuaca = []
    try:
        t = requests.get("https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=32.17.06.2003", timeout=10)
        use_real = t.status_code == 200 and bool(t.json().get("data"))
    except Exception:
        use_real = False

    logger.info(f"BMKG: {'real API' if use_real else 'fallback klimatologi'}")
    for w in WILAYAH_TARGET:
        hasil = ambil_cuaca_bmkg(w["adm4"], w["nama"]) if use_real else []
        semua_cuaca.extend(hasil if hasil else cuaca_fallback(w["nama"]))
    df = pd.DataFrame(semua_cuaca)
    logger.info(f"Dataset cuaca: {len(df)} baris")
    return df


def build_demand_dataset() -> pd.DataFrame:
    logger.info("Membangun dataset demand...")
    np.random.seed(42)
    rows = []
    for wilayah in WILAYAH_NAMES:
        for komoditas in KOMODITAS_UTAMA:
            rows.append({
                "region":             wilayah,
                "komoditas":          komoditas,
                "demand_score":       round(np.random.uniform(0.4, 1.0), 2),
                "harga_pasar_per_kg": int(HARGA_BASE[komoditas]
                                          * PRICE_MODIFIER[wilayah][komoditas]
                                          * np.random.uniform(0.90, 1.10)),
                "stok_level":         np.random.choice(["rendah","sedang","tinggi"], p=[0.25,0.50,0.25]),
                "tren_harga":         np.random.choice(["naik","stabil","turun"], p=[0.35,0.40,0.25]),
                "bulan":              datetime.now().strftime("%Y-%m"),
            })
    df = pd.DataFrame(rows)
    logger.info(f"Dataset demand: {len(df)} baris")
    return df


# build_vectorstore() dihapus — RAG dinonaktifkan untuk mengurangi dependency berat


# =============================================================================
# GLOBAL STATE — diisi saat lifespan startup
# =============================================================================
df_weather: pd.DataFrame = pd.DataFrame()
df_demand:  pd.DataFrame = pd.DataFrame()
agent_executor = None


# =============================================================================
# LANGCHAIN TOOLS
# =============================================================================

@tool
def get_cuaca_realtime(wilayah: str) -> str:
    """Ambil data cuaca real-time dari BMKG untuk wilayah tertentu.
    Menghasilkan suhu, curah hujan, kelembaban, dan cuaca_score per komoditas.
    Gunakan tool ini PERTAMA sebelum tool lainnya.
    Input: nama wilayah, contoh 'Lembang' atau 'Bekasi'."""
    wilayah = wilayah.strip().title()
    if wilayah not in WILAYAH_DICT:
        match = [w for w in WILAYAH_NAMES if wilayah.lower() in w.lower()]
        wilayah = match[0] if match else WILAYAH_NAMES[0]
    c = fetch_cuaca_sekarang(wilayah)
    out  = f"=== CUACA {wilayah.upper()} ({c['week_start']}) ===\n"
    out += f"Suhu   : {c['temperature_avg']}°C (min {c['temperature_min']} / max {c['temperature_max']})\n"
    out += f"Hujan  : {c['rainfall_mm']} mm/minggu (~{c['rainfall_mm']*52:.0f} mm/tahun)\n"
    out += f"Lembab : {c['humidity']}%  |  Angin: {c.get('wind_speed','?')} km/jam\n"
    out += f"Sumber : {c['source']}\n\ncuaca_score per komoditas:\n"
    for k, v in sorted(c['scores_per_komoditas'].items(), key=lambda x: -x[1]):
        bar   = "█" * int(v*10)
        emoji = "✅" if v >= 0.7 else "⚠️" if v >= 0.45 else "❌"
        out  += f"  {k:<20} {bar:<10} {v} {emoji}\n"
    return out.strip()


@tool
def rekomendasikan_komoditas(wilayah: str) -> str:
    """Rekomendasikan 10 komoditas diurutkan berdasarkan kesesuaian cuaca
    dengan syarat tumbuh optimal menggunakan Gaussian scoring.
    Input: nama wilayah, contoh 'Lembang' atau 'Tasikmalaya'."""
    wilayah = wilayah.strip().title()
    if wilayah not in WILAYAH_DICT:
        match = [w for w in WILAYAH_NAMES if wilayah.lower() in w.lower()]
        wilayah = match[0] if match else WILAYAH_NAMES[0]
    c = fetch_cuaca_sekarang(wilayah)
    mask  = (df_weather["region"] == wilayah) & (df_weather["week"] <= 4)
    df_w  = df_weather[mask]
    scores = {}
    for kom in KOMODITAS_UTAMA:
        kb = KB_DICT[kom]
        if not df_w.empty:
            scores[kom] = round(np.mean([hitung_cuaca_score(r, kb) for _, r in df_w.iterrows()]), 3)
        else:
            scores[kom] = c["scores_per_komoditas"].get(kom, 0)
    ranking = sorted(scores.items(), key=lambda x: -x[1])
    out  = f"=== REKOMENDASI KOMODITAS — {wilayah.upper()} ===\n"
    out += f"Cuaca: suhu {c['temperature_avg']}°C | hujan {c['rainfall_mm']}mm/minggu | lembab {c['humidity']}%\n\n"
    medals = ["🥇","🥈","🥉","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟"]
    for i, (kom, skor) in enumerate(ranking[:10]):
        kb    = KB_DICT[kom]
        label = "SANGAT COCOK" if skor>=0.75 else "COCOK" if skor>=0.55 else "CUKUP" if skor>=0.40 else "HINDARI"
        out  += f"{medals[i]} {kom.replace('_',' ').title():<20} {skor}  [{label}]\n"
        out  += f"   Suhu ideal {kb['temp_min']}–{kb['temp_max']}°C | Panen {kb['growing_days']} hari | Yield {kb['yield_ton_per_ha']} ton/ha\n"
    return out.strip()


@tool
def jadwal_tanam_terbaik(input_str: str) -> str:
    """Tentukan minggu optimal tanam berdasarkan proyeksi cuaca 8 minggu ke depan.
    Input format: 'wilayah,komoditas'
    Contoh: 'Lembang,cabai' atau 'Bekasi,jagung'."""
    parts     = [p.strip() for p in input_str.split(",")]
    wilayah   = parts[0].title() if parts else "Lembang"
    komoditas = parts[1].lower().replace(" ","_") if len(parts) > 1 else "jagung"
    if wilayah not in WILAYAH_DICT:
        match = [w for w in WILAYAH_NAMES if wilayah.lower() in w.lower()]
        wilayah = match[0] if match else WILAYAH_NAMES[0]
    if komoditas not in KB_DICT:
        komoditas = "jagung"
    kb   = KB_DICT[komoditas]
    df_w = df_weather[df_weather["region"] == wilayah].sort_values("week")
    minggu = [{"week":int(r["week"]),"week_start":r["week_start"],
               "score":hitung_cuaca_score(r.to_dict(),kb),
               "temp":r["temperature_avg"],"rain":r["rainfall_mm"]}
              for _,r in df_w.iterrows()]
    if not minggu:
        return f"Data cuaca untuk {wilayah} tidak tersedia."
    best = max(minggu, key=lambda x: x["score"])
    est_panen = (datetime.strptime(best["week_start"],"%Y-%m-%d")+timedelta(days=kb["growing_days"])).strftime("%Y-%m-%d")
    out  = f"=== JADWAL TANAM — {komoditas.replace('_',' ').title()} di {wilayah} ===\n"
    out += f"Lama tanam : ±{kb['growing_days']} hari\n\n"
    out += f"✅ MINGGU TERBAIK: Minggu ke-{best['week']} (mulai {best['week_start']})\n"
    out += f"   Skor: {best['score']} | Suhu: {best['temp']}°C | Hujan: {best['rain']}mm\n"
    out += f"   Estimasi panen: ~{est_panen}\n\n"
    out += "📊 Proyeksi 8 minggu ke depan:\n"
    for m in sorted(minggu, key=lambda x: x["week"]):
        bar   = "█" * int(m["score"]*10)
        emoji = "✅" if m["score"]>=0.65 else "⚠️" if m["score"]>=0.45 else "❌"
        out  += f"  Minggu {m['week']:>2} ({m['week_start']}): {bar:<10} {m['score']} {emoji}\n"
    return out.strip()


@tool
def info_hama_penyakit(query: str) -> str:
    """Cari info hama, penyakit tanaman, atau teknik budidaya.
    Contoh input: 'hama thrips cabai', 'penyakit layu tomat', 'pupuk organik'."""
    query_lower = query.lower()
    for kunci, info in INFO_HAMA_STATIC.items():
        if kunci in query_lower:
            return f"=== INFO: {query.upper()} ===\n\n{info}"
    return f"=== INFO: {query.upper()} ===\n\n{INFO_HAMA_STATIC['default']}"


@tool
def estimasi_hasil_panen(input_str: str) -> str:
    """Estimasi hasil panen dan proyeksi pendapatan petani.
    Input format: 'wilayah,komoditas,luas_ha'
    Contoh: 'Lembang,cabai,0.5' atau 'Bekasi,jagung,2'."""
    parts     = [p.strip() for p in input_str.split(",")]
    wilayah   = parts[0].title() if parts else "Lembang"
    komoditas = parts[1].lower().replace(" ","_") if len(parts)>1 else "jagung"
    try:    luas_ha = float(parts[2]) if len(parts)>2 else 1.0
    except: luas_ha = 1.0
    if wilayah not in WILAYAH_DICT:
        match = [w for w in WILAYAH_NAMES if wilayah.lower() in w.lower()]
        wilayah = match[0] if match else WILAYAH_NAMES[0]
    if komoditas not in KB_DICT: komoditas = "jagung"
    kb = KB_DICT[komoditas]
    mask_d = (df_demand["region"]==wilayah) & (df_demand["komoditas"]==komoditas)
    d_row  = df_demand[mask_d]
    harga  = int(d_row["harga_pasar_per_kg"].values[0]) if not d_row.empty else kb["harga_base"]
    c       = fetch_cuaca_sekarang(wilayah)
    c_score = c["scores_per_komoditas"].get(komoditas, 0.6)
    yield_potensi   = kb["yield_ton_per_ha"] * luas_ha
    yield_realistis = round(yield_potensi * (0.7 + 0.3*c_score), 2)
    pendapatan      = int(yield_realistis * 1000 * harga)
    out  = f"=== ESTIMASI PANEN — {komoditas.replace('_',' ').title()} | {wilayah} ===\n"
    out += f"Luas lahan : {luas_ha} hektar  |  Lama tanam: ±{kb['growing_days']} hari\n"
    out += f"Cuaca score: {c_score} (koreksi yield: {(0.7+0.3*c_score):.2f}x)\n\n"
    out += f"📦 PRODUKSI:\n"
    out += f"  Potensi    : {yield_potensi:.2f} ton\n"
    out += f"  Realistis  : {yield_realistis:.2f} ton\n\n"
    out += f"💰 KEUANGAN:\n"
    out += f"  Harga pasar : Rp {harga:,}/kg\n"
    out += f"  Pendapatan  : Rp {pendapatan:,}\n"
    out += f"  Biaya (~35%): Rp {int(pendapatan*0.35):,}\n"
    out += f"  Laba bersih : Rp {int(pendapatan*0.65):,}\n"
    out += f"\n⚠️ Proyeksi. Hasil aktual dipengaruhi OPT dan praktik budidaya."
    return out.strip()


@tool
def cek_harga_pasar(input_str: str) -> str:
    """Cek harga pasar terkini dan demand score dari platform SatuTani.
    Input format: 'wilayah,komoditas' atau hanya 'wilayah' untuk semua komoditas.
    Contoh: 'Lembang,cabai' atau 'Bekasi' atau 'Tasikmalaya,jagung'."""
    parts     = [p.strip() for p in input_str.split(",")]
    wilayah   = parts[0].title() if parts else "Lembang"
    komoditas = parts[1].lower().replace(" ","_") if len(parts)>1 else None
    if wilayah not in WILAYAH_DICT:
        match = [w for w in WILAYAH_NAMES if wilayah.lower() in w.lower()]
        wilayah = match[0] if match else WILAYAH_NAMES[0]
    mask = df_demand["region"] == wilayah
    if komoditas and komoditas in KB_DICT:
        mask = mask & (df_demand["komoditas"] == komoditas)
    df_h = df_demand[mask].sort_values("demand_score", ascending=False)
    if df_h.empty: return f"Data pasar tidak ditemukan untuk {wilayah}."
    out  = f"=== HARGA PASAR — {wilayah.upper()} ({df_h['bulan'].iloc[0]}) ===\n"
    out += f"{'Komoditas':<22}{'Harga/kg':>11}{'Demand':>8}{'Stok':>9}{'Tren':>9}\n"
    out += "-"*60 + "\n"
    for _, r in df_h.head(10).iterrows():
        icon = "📈" if r["tren_harga"]=="naik" else "📉" if r["tren_harga"]=="turun" else "➡️"
        out += (f"{r['komoditas'].replace('_',' ').title():<22}"
                f"Rp {r['harga_pasar_per_kg']:>7,}"
                f"{r['demand_score']:>8.2f}"
                f"{r['stok_level']:>9}"
                f"  {icon}{r['tren_harga']}\n")
    return out.strip()


SATUTANI_TOOLS = [
    get_cuaca_realtime,
    rekomendasikan_komoditas,
    jadwal_tanam_terbaik,
    info_hama_penyakit,
    estimasi_hasil_panen,
    cek_harga_pasar,
]


def build_agent(wilayah_names: list):
    llm = ChatGroq(
        model="llama-3.3-70b-versatile",
        temperature=0.3,
        max_tokens=2048,
    )
    prompt = ChatPromptTemplate.from_messages([
        ("system", """Kamu adalah SatuTani Assistant, teman cerdas petani Indonesia yang paham pertanian.

Wilayah yang kamu layani: {wilayah_list}

PRINSIP DASAR:
- Fokus jawab APA yang ditanya dulu, sampaikan dengan kalimat yang sangat pendek dan sederhana agar mudah dipahami petani.
- Bahasa santai, ramah, dan natural seperti ngobrol dengan teman.
- Gunakan stiker/emoji yang relevan (seperti 🌡️, 🍅, 💰, 🌧️, 🚜) agar menarik, terstruktur, dan unik.
- Wajib gunakan markdown BOLD (huruf tebal) untuk hal-hal penting seperti **Nama Komoditas**, **Suhu/Cuaca**, **Harga**, dan **Angka/Hasil Panen** agar menonjol.
- Maksimal 150 kata. Singkat, padat, dan langsung ke intinya.

ATURAN FORMAT:
1. Jika ada DAFTAR/LIST (rekomendasi tanaman, harga, jadwal):
   Gunakan format bullet atau nomor yang rapi. Contoh:
   🌱 **[Judul singkat]**
   - 🍅 **Tomat** — Harga: **Rp 8.000/kg** (Tumbuh baik di suhu **22°C**)
   - 🌽 **Jagung** — Harga: **Rp 4.000/kg** (Panen dalam **75 hari**)
   
   💡 **Saran:** [1 kalimat saran aksi konkret]

2. Jika pertanyaan SPESIFIK (estimasi panen, harga 1 komoditas, jadwal tanam):
   Jawab langsung dengan poin-poin singkat. Gunakan emoji dan bold. Contoh:
   🌡️ Suhu saat ini: **24°C**
   💰 Harga **Cabai Merah**: **Rp 35.000/kg**
   Lalu tambahkan 1 kalimat saran penutup.

3. Jika SALAM/UMUM:
   Balas ramah 1-2 kalimat dengan emoji 👋🌾, lalu tawarkan bantuan spesifik.

DILARANG:
- Jangan menggunakan kalimat panjang, formal, atau istilah teknis yang rumit.
- Jangan ulang pertanyaan petani di jawaban.
- Jangan bertele-tele.
"""),
        ("human", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ]).partial(wilayah_list=", ".join(wilayah_names))

    agent = create_openai_tools_agent(llm=llm, tools=SATUTANI_TOOLS, prompt=prompt)
    return AgentExecutor(agent=agent, tools=SATUTANI_TOOLS, verbose=False)


# =============================================================================
# FASTAPI APP
# =============================================================================

from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    global df_weather, df_demand, agent_executor
    logger.info("🚀 SatuTani AI Service starting up...")
    df_weather     = build_weather_dataset()
    df_demand      = build_demand_dataset()
    agent_executor = build_agent(WILAYAH_NAMES)
    logger.info("✅ SatuTani AI Service siap! (RAG dinonaktifkan)")
    yield
    logger.info("🛑 SatuTani AI Service shutting down.")


app = FastAPI(
    title="SatuTani AI Service",
    description="LangChain ReAct Agent untuk petani Indonesia",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# =============================================================================
# SCHEMAS
# =============================================================================

class ChatRequest(BaseModel):
    message: str
    wilayah: Optional[str] = "Lembang"
    farmer_id: Optional[str] = None

class ChatResponse(BaseModel):
    reply: str
    wilayah: str
    tools_used: list[str] = []


# =============================================================================
# ENDPOINTS
# =============================================================================

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "satutani-ai",
        "version": "2.0.0",
        "wilayah_count": len(WILAYAH_NAMES),
        "komoditas_count": len(KNOWLEDGE_BASE),
        "timestamp": datetime.now().isoformat(),
    }


@app.get("/wilayah")
def list_wilayah():
    return {
        "wilayah": WILAYAH_NAMES,
        "total": len(WILAYAH_NAMES),
    }


@app.get("/komoditas")
def list_komoditas():
    return {
        "komoditas": KNOWLEDGE_BASE,
        "total": len(KNOWLEDGE_BASE),
    }


@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    if not req.message.strip():
        raise HTTPException(status_code=400, detail="Pesan tidak boleh kosong.")

    # Sertakan wilayah dalam konteks pesan jika disebutkan
    wilayah = req.wilayah.strip().title() if req.wilayah else "Lembang"
    if wilayah not in WILAYAH_DICT:
        match = [w for w in WILAYAH_NAMES if wilayah.lower() in w.lower()]
        wilayah = match[0] if match else WILAYAH_NAMES[0]

    pesan = req.message
    # Injeksi konteks wilayah ke pesan jika belum ada
    if not any(w.lower() in pesan.lower() for w in WILAYAH_NAMES):
        pesan = f"[Wilayah: {wilayah}] {pesan}"

    try:
        result = agent_executor.invoke({"input": pesan})
        reply  = result.get("output", "Maaf, saya tidak bisa memproses pertanyaan Anda saat ini.")
        return ChatResponse(reply=reply, wilayah=wilayah)
    except Exception as e:
        logger.error(f"Agent error: {e}")
        raise HTTPException(status_code=500, detail=f"AI error: {str(e)}")


# =============================================================================
# ENTRY POINT
# =============================================================================
if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)
