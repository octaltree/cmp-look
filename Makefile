TSTEST=$(shell grep -rl "Deno.test" denops)

dev: format lint test

lint:
	deno lint
format:
	deno fmt denops
test:
	deno test --unstable -A ${TSTEST}
