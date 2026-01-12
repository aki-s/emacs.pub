.PHONY: help
.DEFAULT_GOAL := help

help: ## Display this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \\
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## This target is not tested yet, and it would be broken yet...
	$HOME/.emacs.d/util/setup-emacs.pub.sh
	brew install sops age
	git lfs pull
	make decrypt

SDIC_FILES := share/dict/eijirou118.sdic share/dict/waeijirou118.sdic
SOPS_AGE_KEY_FILE ?= "$${HOME}/.ssh/age-keygen.key"

encrypt: ## Encrypt
	for f in $(SDIC_FILES) ;\
do \
  sops encrypt --age age19hd8tzm07duq0fh44cx29qdxwxawwvcp98a25ya9mgfamm7alacs5wv80v\
 $${f} > $${f}.enc ;\
done

decrypt: ## Decrypt
	for f in $(SDIC_FILES) ;\
do \
  sops decrypt $${f}.enc > $${f} ;\
done
