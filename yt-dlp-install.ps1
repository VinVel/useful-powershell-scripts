#Windows only

Set-Location $HOME #Im Userprofile anfangen
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force #Terminal vorbereiten

#Pyenv (Python Versions Manager) installieren und in PATH setzen + Python 3.12 und Pakete
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1" #installs pyenv
#Terminal neustarten
pyenv install 3.12.10
pyenv global 3.12.10
pip install -U yt-dlp bgutil-ytdlp-pot-provider #installiert yt-dlp und PO Token Plugin

#installiert scoop, für nodejs and Deno management
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression 
scoop install git
scoop install deno
scoop install nodejs
scoop install ffmpeg
scoop install atomicparsley

# PO Token Provider Server klonen und vorbereiten
git clone --single-branch --branch 1.2.2 https://github.com/Brainicism/bgutil-ytdlp-pot-provider.git
cd bgutil-ytdlp-pot-provider/server/
npm install
npx tsc