# YoutubeFlash

Convert youtube videos to mp3 and mp4 on IOS.
The app requires node js server to download the mp4 and mp3 files, thanks to [youtube-dl-exec
](https://www.npmjs.com/package/youtube-dl-exec)

# USE IT AT YOUR OWN RISK

It's against youtube TOS!

# Instalation

To make the software work first you need to go to backend and type this commands

1. First go to backend folder and install the dependencies:

```shell
cd backend/
npm install
```

2. After that modify the content of the index.js, line 15 the port ([see this](backend/index.js)) or leave it like that then run:

```shell
node index.js
```

1. After that go to the app folder and inside of there, open the project as xcode and then modify the ContentView.swift line 15 ([see this](app/YoutubeFlash/ContentView.swift))
2. Now you are done! Enjoy!
