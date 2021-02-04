const { app, BrowserWindow, Menu } = require('electron')

const isMac = process.platform === 'darwin'

const template = [
  { role: 'appMenu' },
  { role: 'editMenu' },
  { role: 'windowMenu' }
]

const menu = isMac ? Menu.buildFromTemplate(template) : null
Menu.setApplicationMenu(menu)

function createWindow () {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    minWidth: 450,
    minHeight: 250,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false
    }
  })

  win.loadFile('content/index.html')
}

app.whenReady().then(createWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})
