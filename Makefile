TS=$(shell find denops -name "*.ts")
TSTEST=$(shell grep -rl "Deno.test" denops)

dev: format lint test

lint:
	deno lint
	deno test --unstable --no-run -A ${TS}
format:
	deno fmt denops
test:
	deno test --unstable -A ${TSTEST}
