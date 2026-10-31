#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=false
usage() {
  echo 'Usage: bash scripts/init_app.sh [--dry-run] "<App Name>" <dart_package_name> <android.applicationId>'
  echo 'Example: bash scripts/init_app.sh "Lifebit" lifebit com.squiraldot.lifebit'
}
if [ "$#" -gt 0 ] && { [ "$1" = "--help" ] || [ "$1" = "-h" ]; }; then usage; exit 0; fi
if [ "$#" -gt 0 ] && [ "$1" = "--dry-run" ]; then DRY_RUN=true; shift; fi
if [ "$#" -ne 3 ]; then usage >&2; exit 2; fi
APP_NAME="$1"; DART_PACKAGE="$2"; ANDROID_ID="$3"
if [ -z "$APP_NAME" ] || [ "$(printf %s "$APP_NAME" | wc -m)" -gt 50 ] || [[ "$APP_NAME" == *$'\n'* ]]; then
  echo "Error: app name must be 1-50 characters and contain no line breaks." >&2; exit 2
fi
[[ "$DART_PACKAGE" =~ ^[a-z][a-z0-9_]*$ ]] || { echo "Error: invalid Dart package name." >&2; exit 2; }
[[ "$ANDROID_ID" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]] || { echo "Error: invalid Android applicationId." >&2; exit 2; }
export INIT_APP_ROOT="$ROOT_DIR" INIT_APP_NAME="$APP_NAME" INIT_DART_PACKAGE="$DART_PACKAGE" INIT_ANDROID_ID="$ANDROID_ID" INIT_DRY_RUN="$DRY_RUN"
python3 <<'PY'
import os, re, sys, tempfile
from pathlib import Path
from xml.sax.saxutils import escape as xml_escape
root = Path(os.environ["INIT_APP_ROOT"])
app, package, app_id = (os.environ[k] for k in ("INIT_APP_NAME","INIT_DART_PACKAGE","INIT_ANDROID_ID"))
dry = os.environ["INIT_DRY_RUN"] == "true"
if any(ord(ch) < 32 or ord(ch) == 127 for ch in app): raise ValueError("App name cannot contain control characters.")
dart_app = app.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
xml_app = xml_escape(app, {'"': "&quot;"})
pubspec=root/"pubspec.yaml"; spec_file=root/"docs/APP_SPEC.md"
manifest=root/"android/app/src/main/AndroidManifest.xml"
android=root/"android/app"; tests=root/"test"
gradles=[p for p in (android/"build.gradle.kts",android/"build.gradle") if p.is_file()]
required=[pubspec,spec_file,root/"lib/app.dart",root/"lib/features/home/presentation/home_page.dart",manifest]
missing=[str(p.relative_to(root)) for p in required if not p.is_file()]
if not tests.is_dir(): missing.append("test/")
if len(gradles)!=1: missing.append("exactly one android/app Gradle file")
if missing:
 print("Missing required scaffold: "+", ".join(missing),file=sys.stderr)
 print("Run 'bash scripts/bootstrap.sh' first.",file=sys.stderr); sys.exit(1)
def read(p): return p.read_text(encoding="utf-8")
def once(s,pat,repl,label):
 out,n=re.subn(pat,repl,s,count=1)
 if n!=1: raise ValueError(f"Expected exactly one {label}; found {n}. No files changed.")
 return out
changes={}; moves=[]
pub=read(pubspec); match=re.search(r"(?m)^name:\s*([a-z][a-z0-9_]*)\s*$",pub)
if not match: raise ValueError("Invalid/missing pubspec name.")
old_package=match.group(1)
changes[pubspec]=once(pub,r"(?m)^name:\s*[a-z][a-z0-9_]*\s*$",f"name: {package}","pubspec name")
spec=once(read(spec_file),r"(?m)^- App name:\s*.*$",f"- App name: {app}","APP_SPEC app name")
if re.search(r"(?m)^- Dart package name:",spec):
 spec=once(spec,r"(?m)^- Dart package name:\s*.*$",f"- Dart package name: {package}","APP_SPEC Dart package")
else: spec=spec.replace(f"- App name: {app}\n",f"- App name: {app}\n- Dart package name: {package}\n",1)
changes[spec_file]=once(spec,r"(?m)^- Android application ID:\s*.*$",f"- Android application ID: {app_id}","APP_SPEC Android ID")
for p in sorted([*(root/"lib").rglob("*.dart"),*tests.rglob("*.dart")]):
 s=read(p); updated=s.replace("Universal App",dart_app).replace(f"package:{old_package}/",f"package:{package}/")
 if updated!=s: changes[p]=updated
gradle=gradles[0]; gs=read(gradle)
for key in ("namespace","applicationId"):
 pat=rf'(?m)^(\s*{key}\s*(?:=\s*)?)[\'"]([^\'"]+)[\'"](\s*(?:\n|$))'
 gs=once(gs,pat,lambda m:f'{m.group(1)}"{app_id}"{m.group(3)}',f"Gradle {key}")
changes[gradle]=gs
ms=read(manifest); label=re.search(r'android:label\s*=\s*"([^"]+)"',ms)
if not label: raise ValueError("AndroidManifest.xml has no android:label.")
value=label.group(1)
if value.startswith("@string/"):
 sf=android/"src/main/res/values/strings.xml"
 if not sf.is_file(): raise ValueError("Android app-name strings.xml is missing.")
 key=re.escape(value.split("/",1)[1])
 changes[sf]=once(read(sf),rf'(?s)(<string\s+name="{key}"\s*>).*?(</string>)',lambda m:f"{m.group(1)}{xml_app}{m.group(2)}","Android app-name string")
else: changes[manifest]=ms.replace(f'android:label="{value}"',f'android:label="{xml_app}"',1)
activities=[p for p in (android/"src/main").rglob("*") if p.is_file() and p.name in ("MainActivity.kt","MainActivity.java")]
if len(activities)!=1: raise ValueError(f"Expected one MainActivity.kt/.java; found {len(activities)}.")
activity=activities[0]
at=once(read(activity),r"(?m)^package\s+[A-Za-z_][A-Za-z0-9_.]*\s*$",f"package {app_id}","MainActivity package")
source=android/"src/main"; lang="kotlin" if activity.suffix==".kt" else "java"
dest=source/lang/Path(*app_id.split("."))/activity.name
if dest!=activity:
 if dest.exists(): raise ValueError(f"MainActivity destination exists: {dest.relative_to(root)}")
 moves.append((activity,dest))
changes[activity]=at
for p in sorted(changes,key=str): print(("Would update " if dry else "Update ")+str(p.relative_to(root)))
for a,b in moves: print(("Would move " if dry else "Move ")+str(a.relative_to(root))+" -> "+str(b.relative_to(root)))
if dry: print("Dry run complete; no files changed."); sys.exit(0)
staged=[]
try:
 for p,s in changes.items():
  with tempfile.NamedTemporaryFile("w",encoding="utf-8",dir=p.parent,delete=False) as f:
   f.write(s); staged.append((Path(f.name),p))
 for tmp,target in staged: os.replace(tmp,target)
 for src,dst in moves:
  dst.parent.mkdir(parents=True,exist_ok=True); src.replace(dst)
  parent=src.parent
  while parent!=source:
   try: parent.rmdir()
   except OSError: break
   parent=parent.parent
except Exception:
 for tmp,_ in staged: tmp.unlink(missing_ok=True)
 raise
print(f"App initialized: {app} | {package} | {app_id}")
print("Run flutter pub get, format, analyze, tests and an Android debug build.")
PY
