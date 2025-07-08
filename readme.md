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

### 8. MSI pakotnes izveide ar WiX Toolset

#### 8.1 WiX source failu izveide
Skripts izveido `product.wxs` failu ar:
- **Product**: Notepad++ Enterprise (versija 8.8.2.0)
- **Package**: x64 platforma, perMachine instalācija
- **Direktorijas struktūra**:
  - `TARGETDIR` → `WindowsVolume` → `APPSDIR` (Apps) → `INSTALLFOLDER` (Notepad++)
  - `ProgramMenuFolder` → `ApplicationProgramsFolder` (Notepad++)
  - `DesktopFolder` (Desktop)

#### 8.2 Failu apkopošana ar Heat.exe
```cmd
heat.exe dir "NPP" -cg HarvestedFiles -gg -scom -sreg -sfrag -srd -dr INSTALLFOLDER -out "files.wxs" -var var.SourceDir
```
- **Funkcija**: Automātiski apkopo visus failus no NPP direktorijas
- **Parametri**:
  - `-cg HarvestedFiles`: Izveido Component Group ar šo nosaukumu
  - `-gg`: Ģenerē GUIDs automātiski
  - `-scom`: Izslēdz COM reģistrāciju
  - `-sreg`: Izslēdz registry ierakstus
  - `-sfrag`: Izslēdz fragmentu ģenerēšanu
  - `-srd`: Izslēdz root direktoriju
  - `-dr INSTALLFOLDER`: Izmanto INSTALLFOLDER kā mērķa direktoriju
  - `-var var.SourceDir`: Izmanto mainīgo SourceDir

#### 8.3 Kompilēšana ar candle.exe
```cmd
candle.exe product.wxs files.wxs -dSourceDir="NPP" -arch x64 -out "OutputDir"
```
- **Funkcija**: Kompilē WiX source failus uz WiX objektu failiem
- **Parametri**:
  - `-dSourceDir="NPP"`: Definē SourceDir mainīgo
  - `-arch x64`: Norāda x64 arhitektūru
  - `-out "OutputDir"`: Izvades direktorija .wixobj failiem

#### 8.4 MSI izveide ar light.exe
```cmd
light.exe product.wixobj files.wixobj -out "Notepad++.msi" -sice:ICE38 -sice:ICE64 -sice:ICE91 -sice:ICE80 -sice:ICE30
```
- **Funkcija**: Izveido MSI failu no WiX objektiem
- **ICE brīdinājumu izslēgšana**:
  - `ICE38`: Komponenti bez failu
  - `ICE64`: Direktorijas bez komponentiem
  - `ICE91`: Īsā faila vārda problēmas
  - `ICE80`: Ikonu problēmas
  - `ICE30`: Instalācijas secības problēmas

#### 8.5 MSI sastāvs un funkcionalitāte
**Registry ieraksti** (Windows reģistrā):
- `.txt` failu asociācijas → `HKLM\SOFTWARE\Classes\.txt`
- `.log` failu asociācijas → `HKLM\SOFTWARE\Classes\.log`
- Atjauninājumu atslēgšana → `HKLM\SOFTWARE\Notepad++\noUpdate = 1`

**Saīsņu izveide**:
- Desktop saīsne → `DesktopFolder\Notepad++.lnk`
- Start Menu saīsne → `Programs\Notepad++\Notepad++.lnk`
- Ikona: `notepad++.exe` embedded ikona

**Komponenti**:
- `FileAssociations`: Failu asociācijas un ikonu iestatīšana
- `DisableUpdates`: Atjauninājumu atslēgšana reģistrā
- `ApplicationShortcut`: Start Menu saīsne
- `DesktopShortcut`: Desktop saīsne
- `HarvestedFiles`: Visi Notepad++ faili (no Heat.exe)

**Instalācijas mērķis**: `C:\Apps\Notepad++`

### 9. Dokumentācijas un ZIP izveide
- Izveido Documentation.txt failu ar pilnu instalācijas info
- Saspiež MSI un dokumentāciju ZIP failā kā `Notepad++_Apps.zip`
- Iztīra build direktorijas (`C:\Build\NotepadPlusPlus_Apps`)
- Saglabā finālos failus `C:\Build\Final\` direktorijā

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
- `nativeLang.xml` - latviešu valodas fails root direktorijā (kopēts no `localization\latvian.xml`)
- `stylers.xml` - 99er tēma root direktorijā kā noklusējuma tēma (kopēts no `themes\99er.xml`)
- DarkMode konfigurācija config.xml failā papildus kontrolei

### Failu asociācijas
- .txt faili tiek asociēti ar Notepad++
- .log faili tiek asociēti ar Notepad++

### Saīsnes
- Desktop: Notepad++ saīsne
- Start Menu: Programs\Notepad++\Notepad++

## Detalizēts failu izvietojums WiX Toolset procesā

### Build direktoriju struktūra
```
C:\Build\
├── NotepadPlusPlus_Apps\           # Galvenā build direktorija
│   ├── wix\                        # WiX Toolset binārie faili
│   │   ├── candle.exe             # WiX kompilators
│   │   ├── light.exe              # MSI builder
│   │   ├── heat.exe               # Failu harvester
│   │   └── [citi WiX faili]
│   ├── NPP\                        # Notepad++ faili
│   │   ├── notepad++.exe          # Galvenā programma
│   │   ├── config.xml             # Galvenā konfigurācija (ar latviešu + 99er)
│   │   ├── nativeLang.xml         # Latviešu valoda (kopēts no localization\)
│   │   ├── stylers.xml            # 99er tēma (kopēts no themes\)
│   │   ├── doLocalConf.xml        # Lokālās konfigurācijas triggers
│   │   ├── themes\
│   │   │   └── 99er.xml           # Oriģinālā 99er tēma
│   │   ├── localization\
│   │   │   └── latvian.xml        # Oriģinālā latviešu valoda
│   │   ├── plugins\
│   │   │   └── ComparePlugin\
│   │   │       └── ComparePlugin.dll
│   │   └── [citi Notepad++ faili]
│   ├── product.wxs                # WiX galvenais definīciju fails
│   ├── files.wxs                  # Heat.exe ģenerētās failu definīcijas
│   ├── product.wixobj            # Kompilēts objekts no product.wxs
│   └── files.wixobj              # Kompilēts objekts no files.wxs
└── Final\                         # Gatavie produkti
    ├── Notepad++.msi             # Galvenais MSI fails
    ├── Documentation.txt         # Instalācijas instrukcijas
    └── Notepad++_Apps.zip        # Finālā ZIP pakotne
```

### Svarīgo failu nozīme un izvietojums

#### Root direktorijā izvietotie faili (NPP\)
1. **nativeLang.xml** - Notepad++ meklē šo failu root direktorijā, lai noteiktu UI valodu
2. **stylers.xml** - Notepad++ meklē šo failu root direktorijā, lai noteiktu noklusējuma tēmu
3. **config.xml** - Galvenā konfigurācija ar visiem iestatījumiem
4. **doLocalConf.xml** - Tukšs fails, kas liek Notepad++ izmantot lokālo konfigurāciju

#### Themes direktorijā (NPP\themes\)
- **99er.xml** - Oriģinālā 99er tēmas definīcija (saglabāta references dēļ)

#### Localization direktorijā (NPP\localization\)
- **latvian.xml** - Oriģinālā latviešu valodas definīcija

#### Plugins direktorijā (NPP\plugins\ComparePlugin\)
- **ComparePlugin.dll** - Compare spraudņa galvenais fails

### WiX procesu secība
1. **Heat.exe** skenē `NPP\` direktoriju un izveido `files.wxs` ar visiem failu ierakstiem
2. **Candle.exe** kompilē `product.wxs` un `files.wxs` uz `.wixobj` failiem
3. **Light.exe** apvieno `.wixobj` failus un izveido `Notepad++.msi`
4. MSI satur visus failus un registry ierakstus instalācijai uz `C:\Apps\Notepad++`

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