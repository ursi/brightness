#! /usr/bin/node

const { execSync } = require(`child_process`);
const fs = require(`fs`);
const path = require(`path`);
const readline = require(`readline`);

const configPath = path.join(require(`os`).homedir(), `.brightness`);

if (!fs.existsSync(configPath))
	fs.writeFileSync(configPath, `1`);

let currentBrightness = Number(fs.readFileSync(configPath, `utf8`));

const setBrightness = b => {
	execSync(`xrandr --output HDMI-0 --brightness ${b}`);
	fs.writeFileSync(configPath, String(b));
	console.log(b);
};

setBrightness(currentBrightness);

process.stdin.setRawMode(true);
readline.emitKeypressEvents(process.stdin);

let lower = 0;
let upper = 1;

process.stdin.on(`keypress`, (_, {name, ctrl}) => {
	if (name === `up`) {
		lower = currentBrightness;
		currentBrightness = (lower + upper) / 2;
	} else if (name === `down`) {
		upper = currentBrightness;
		currentBrightness = (lower + upper) / 2;
	}

	if (name === `r`) {
		lower = 0;
		upper = 1;
		currentBrightness = 1
	}

	if (name === `c` && ctrl)
		process.exit();

	setBrightness(currentBrightness);
});
