const readline = require(`readline`);
process.stdin.setRawMode(true);
readline.emitKeypressEvents(process.stdin);

exports.getKeypressImpl = aC => _ => () => {
	const handler = (_, data) => aC({
		name: String(data.name),
		ctrl: data.ctrl
	});

	process.stdin.once(`keypress`, handler);
	return () => process.stdin.removeListener(`keypress`, handler);
};
