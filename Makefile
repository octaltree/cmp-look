dev: format lint test

lint:
	deno lint
format:
	deno fmt denops
test:
	deno test --unstable -A denops/ddc-sources/look.ts
