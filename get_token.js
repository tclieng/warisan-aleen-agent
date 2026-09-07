const { execSync } = require('child_process');
const xb = 'C:\\Program Files\\QClaw\\v0.2.35.624\\resources\\openclaw\\config\\skills\\xbrowser\\scripts\\xb.cjs';
const ws = 'C:\\Users\\MK-User\\.qclaw\\workspace\\warisan-agent';

const shell = (cmd) => execSync(`node "${xb}" run --browser chrome ${cmd}`, { stdio: ['pipe', 'pipe', 'pipe'] });

const wait = (ms) => {
  const end = Date.now() + ms;
  while (Date.now() < end) {}
};

const clipboard = () => {
  try {
    const { execSync: ex } = require('child_process');
    return ex('powershell -Command "[System.Windows.Forms.Clipboard]::GetText()"').toString().trim();
  } catch(e) { return ''; }
};

try {
  shell('click e73');  // Focus the token textbox
  wait(400);
  shell('send-keys --ctrl a');
  wait(400);
  shell('send-keys --ctrl c');
  wait(400);
  const text = clipboard();
  require('fs').writeFileSync(`${ws}\\clipboard_result.txt`, text);
  console.log('Clipboard: ' + text.substring(0, 300));
} catch(e) {
  require('fs').writeFileSync(`${ws}\\clipboard_result.txt`, 'ERROR: ' + e.message);
  console.error(e.message);
}
