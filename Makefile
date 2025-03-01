VERSION := $(shell grep '^version' typst.toml | awk -F ' = ' '{print $$2}' | tr -d '"')
PACKAGE_NAME := $(shell grep '^name' typst.toml | awk -F ' = ' '{print $$2}' | tr -d '"')
TARGET_DIR=./$(PACKAGE_NAME)/$(VERSION)

check:
	typst compile ./lib.typ
	rm ./lib.pdf

link :
	mkdir -p ~/.cache/typst/packages/preview/alchemist
	ln -s "$(CURDIR)" ~/.cache/typst/packages/preview/alchemist/$(VERSION)

clean-link:
	rm -rf ~/.cache/typst/packages/preview/alchemist

module:
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/src
	cp ./typst.toml $(TARGET_DIR)/typst.toml
	cp ./LICENSE $(TARGET_DIR)/
	cp ./lib.typ $(TARGET_DIR)/
	cp -r ./src/* $(TARGET_DIR)/src/
	awk '{gsub("https://typst.app/universe/package/alchemist", "https://github.com/Typsium/alchemist");print}' ./README.md > $(TARGET_DIR)/README.md

manual:
	typst compile ./doc/manual.typ --root .

watch:
	typst watch ./doc/manual.typ --root .