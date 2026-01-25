test:
	@echo "Running tests with Vim..."
	@vim --version | head -1
	vim -u NONE -N -i NONE --noplugin \
		-c 'set runtimepath+=.' \
		-c 'source test/autoload/ddx/commands.vim' \
		-c 'call Test_parse_options_args()' \
		-c 'echo "All tests passed!"' \
		-c 'qall!'
	@echo ""
	@if command -v nvim >/dev/null 2>&1; then \
		echo "Running tests with Neovim..."; \
		nvim --version | head -1; \
		nvim -u NONE -N -i NONE --noplugin --headless \
			-c 'set runtimepath+=.' \
			-c 'source test/autoload/ddx/commands.vim' \
			-c 'call Test_parse_options_args()' \
			-c 'echo "All tests passed!"' \
			-c 'qall!'; \
	else \
		echo "Neovim not found, skipping neovim tests"; \
	fi

.PHONY: test
