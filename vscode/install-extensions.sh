#!/bin/bash -e

VSCODE_EXT=(
    charliermarsh.ruff
    formulahendry.auto-close-tag
    ms-python.python
    ms-toolsai.jupyter
    ms-vscode.cmake-tools
    ms-vscode.cpptools
    ms-vscode-remote.remote-ssh
    nefrob.vscode-just-syntax
    pdconsec.vscode-print
    redhat.vscode-yaml
    rust-lang.rust-analyzer
    shardulm94.trailing-spaces
    spywhere.guides
    tamasfe.even-better-toml
    vadimcn.vscode-lldb
    vincaslt.highlight-matching-tag
    vscodevim.vim
)

for ext in "${VSCODE_EXT[@]}"
do
    code --install-extension "$ext" --force
done
