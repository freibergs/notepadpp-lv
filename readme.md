# Notepad++ MSI Pakotnes Izveides Dokumentācija

## Apraksts
Šis PowerShell skripts `builder.ps1` izveido Notepad++ MSI instalācijas pakotni ar sekojošām funkcijām:

### Iekļautās funkcijas:
- ✅ Notepad++ x64
- ✅ Latviešu valodas saskarne (pēc noklusējuma)
- ✅ 99er tēma kā noklusējuma tēma
- ✅ Compare spraudnis
- ✅ Failu asociācijas (.txt, .log)
- ✅ Atjauninājumi atslēgti
- ✅ Instalācija uz C:\Apps\Notepad++
- ✅ Lokālā konfigurācija (bez AppData izmantošanas)

## Prasības
- Windows 10/11
- PowerShell 5.1 vai jaunāks
- Administratora tiesības (MSI izveidei)
- Interneta savienojums (lejupielādēm)

## Kā palaist

### 1. Atver PowerShell kā administrators
```powershell
# Spied Win+X un izvēlies "Windows PowerShell (Admin)"
# vai
# Meklē "PowerShell" Start izvēlnē, labais klikšķis, "Run as administrator"
```

### 2. Atļauj skriptu izpildi (ja nepieciešams)
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### 3. Navigē uz skriptu direktoriju
```powershell
cd "C:\Users\Tavs_Lietotajs\Desktop\Jauna mape"
```

### 4. Palaid skriptu
```powershell
.\apps_builder.ps1
```

## Ko skripts dara soli pa solim

### 1. Sagatavošana
- Izveido build direktorijas `C:\Build\NotepadPlusPlus_Apps` un `C:\Build\Final`
- Iztīra iepriekšējās build direktorijas

### 2. WiX Toolset lejupielāde
- Lejupielādē WiX 3.11.2 no GitHub
- Izpako `C:\Build\NotepadPlusPlus_Apps\wix\` direktorijā

### 3. Notepad++ lejupielāde
- Lejupielādē Notepad++ 8.8.2 x64 versiju
- Izpako `C:\Build\NotepadPlusPlus_Apps\NPP\` direktorijā

### 4. Tēmas uzstādīšana
- Lejupielādē 99er.xml tēmu no GitHub
- Saglabā `themes\99er.xml`
- **Kopē 99er.xml uz root direktoriju kā `stylers.xml`** (svarīgi!)

### 5. Valodas uzstādīšana
- **Kopē `localization\latvian.xml` uz root direktoriju kā `nativeLang.xml`** (svarīgi!)

### 6. Compare spraudņa uzstādīšana
- Lejupielādē Compare Plugin 2.0.2 x64
- Izpako un instalē `plugins\ComparePlugin\` direktorijā

### 7. Konfigurācijas failu izveide
- **config.xml** - galvenā konfigurācija ar:
  - Latviešu valoda
  - 99er tēma caur DarkMode konfigurāciju
  - Atslēgti atjauninājumi
  - Dažādi iestatījumi
- **doLocalConf.xml** - tukšs fails, kas liek izmantot lokālo konfigurāciju

### 8. MSI pakotnes izveide
- Izveido WiX source failus (product.wxs)
- Izmanto Heat.exe, lai apkopotu visus failus
- Kompilē ar candle.exe
- Izveido MSI ar light.exe
- Instalācijas mērķis: `C:\Apps\Notepad++`

### 9. Dokumentācijas un ZIP izveide
- Izveido Documentation.txt failu
- Saspiež MSI un dokumentāciju ZIP failā
- Iztīra build direktorijas

## Rezultāts
Skripts izveido:
- `C:\Build\Final\Notepad++.msi` - galveno instalācijas failu
- `C:\Build\Final\Documentation.txt` - instrukcijas
- `C:\Build\Final\Notepad++_Apps.zip` - finālā ZIP pakotne

## Instalācijas komandas

### Klusa instalācija:
```cmd
msiexec /i "Notepad++.msi" /qn
```

### Instalācija ar pamata UI:
```cmd
msiexec /i "Notepad++.msi" /qb
```

### Pilna UI instalācija:
```cmd
msiexec /i "Notepad++.msi"
```

## Atinstalēšana

### Klusa atinstalēšana:
```cmd
msiexec /x "Notepad++.msi" /qn
```

### Atinstalēšana ar pamata UI:
```cmd
msiexec /x "Notepad++.msi" /qb
```

## Svarīgas iezīmes

### Lokālā konfigurācija
- `doLocalConf.xml` liek Notepad++ izmantot lokālo konfigurāciju
- Visi iestatījumi glabājas `C:\Apps\Notepad++\` direktorijā
- Nav atkarības no AppData

### Valodas un tēmas
- `nativeLang.xml` - latviešu valodas fails root direktorijā
- `stylers.xml` - 99er tēma root direktorijā kā noklusējuma tēma
- DarkMode konfigurācija config.xml failā papildus kontrolei

### Failu asociācijas
- .txt faili tiek asociēti ar Notepad++
- .log faili tiek asociēti ar Notepad++

### Saīsnes
- Desktop: Notepad++ saīsne
- Start Menu: Programs\Notepad++\Notepad++

## Problēmu risināšana

### Ja skripts nepalaiža:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

### Ja WiX kļūdas:
- Pārbaudi, vai ir administratora tiesības
- Pārbaudi interneta savienojumu

### Ja MSI neizveido:
- Pārbaudi, vai `C:\Build\` direktorija ir pieejama rakstīšanai
- Pārbaudi antivīrusa iestatījumus

## Autors
Izveidots Claude Code palīdzībā 2025. gada janvārī.