#!/usr/bin/env bash

set -euo pipefail

NT_HOME="${NT_HOME:-${HOME}/.local/nt}"
NT_NODES="${NT_HOME}/node"
NT_TOOLS="${NT_HOME}/tools"
NT_BIN="${NT_HOME}/bin"

__nt_parse_pkg_spec() {
    local spec="$1"
    local pkg_name pkg_ver dir_name

    if [[ "$spec" =~ ^@(.+)$ ]]; then
        local without_at="${BASH_REMATCH[1]}"
        if [[ "$without_at" =~ ^([^@]+)@(.+)$ ]]; then
            pkg_name="@${BASH_REMATCH[1]}"
            pkg_ver="${BASH_REMATCH[2]}"
        else
            pkg_name="@${without_at}"
            pkg_ver=""
        fi
        dir_name="${pkg_name#@}"
        dir_name="${dir_name//\//__}"
    else
        if [[ "$spec" =~ ^([^@]+)@(.+)$ ]]; then
            pkg_name="${BASH_REMATCH[1]}"
            pkg_ver="${BASH_REMATCH[2]}"
        else
            pkg_name="$spec"
            pkg_ver=""
        fi
        dir_name="$pkg_name"
    fi

    echo "$pkg_name"
    echo "$pkg_ver"
    echo "$dir_name"
}

__nt_ensure_n() {
    local n_bin="${NT_HOME}/bin/n"
    
    if [[ ! -x "$n_bin" ]]; then
        echo "→ downloading n (Node.js version manager)..."
        mkdir -p "${NT_HOME}/bin"
        if ! curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n -o "$n_bin"; then
            echo "nt: failed to download n"
            return 1
        fi
        chmod +x "$n_bin"
        echo "✓ n installed"
    fi
}

__nt_ensure_node() {
    local spec="$1"
    local node_dir="${NT_NODES}/${spec}"

    __nt_ensure_n || return 1

    echo "→ updating node@${spec} via n..."
    mkdir -p "$node_dir"
    N_PREFIX="$node_dir" "${NT_HOME}/bin/n" "$spec"

    if [[ ! -x "${node_dir}/bin/node" ]]; then
        echo "nt: node installation failed"
        rm -rf "$node_dir"
        return 1
    fi

    export PATH="${node_dir}/bin:${PATH}"

    echo "✓ node@${spec} ready"
}

__nt_cleanup_wrappers() {
    local tool_dir="$1"

    [[ ! -d "$NT_BIN" ]] && return

    for f in "$NT_BIN"/*; do
        [[ -f "$f" ]] && grep -qF "$tool_dir" "$f" && rm -f "$f"
    done
}

__nt_create_wrappers() {
    local node_dir="$1"
    local tool_dir="$2"
    local pkg_name="$3"

    local pkg_json="${tool_dir}/node_modules/${pkg_name}/package.json"
    local count=0

    if [[ ! -f "$pkg_json" ]]; then
        echo "nt: warning — package.json not found at $pkg_json"
        return
    fi

    local bin_entries
    bin_entries=$("${node_dir}/bin/node" -e "
const p = require('${pkg_json}');
const b = p.bin;
if (!b) process.exit(0);
const obj = typeof b === 'string' ? {[p.name]: b} : b;
Object.entries(obj).forEach(([n, v]) => console.log(n + '\t' + v));
" 2>/dev/null || true)

    mkdir -p "$NT_BIN"

    while IFS=$'\t' read -r bin_name bin_rel; do
        [[ -z "$bin_name" ]] && continue

        local bin_abs="${tool_dir}/node_modules/${pkg_name}/${bin_rel}"
        local wrapper="${NT_BIN}/${bin_name}"

        cat > "$wrapper" <<EOF
#!/usr/bin/env bash
# nt-tool: ${tool_dir}
export PATH="${node_dir}/bin:\$PATH"
exec "${bin_abs}" "\$@"
EOF

        chmod +x "$wrapper"
        ((count++))
    done <<< "$bin_entries"

    echo "$count"
}

__nt_install() {
    local node_spec="latest"
    local pkg_spec=""

    for arg in "$@"; do
        if [[ "$arg" =~ ^--node=(.+)$ ]]; then
            node_spec="${BASH_REMATCH[1]}"
        elif [[ ! "$arg" =~ ^- ]]; then
            pkg_spec="$arg"
        fi
    done

    if [[ -z "$pkg_spec" ]]; then
        echo "Usage: nt install [--node=<version>] <package>[@version]"
        return 1
    fi

    local parsed
    readarray -t parsed < <(__nt_parse_pkg_spec "$pkg_spec")
    local pkg_name="${parsed[0]}"
    local pkg_ver="${parsed[1]}"
    local dir_name="${parsed[2]}"

    local install_spec
    if [[ -z "$pkg_ver" ]]; then
        install_spec="${pkg_name}@latest"
    else
        install_spec="${pkg_name}@${pkg_ver}"
    fi

    __nt_ensure_node "$node_spec" || return 1

    local node_dir="${NT_NODES}/${node_spec}"
    local tool_dir="${NT_TOOLS}/${dir_name}"

    if [[ -d "$tool_dir" ]]; then
        __nt_cleanup_wrappers "$tool_dir"
        rm -rf "$tool_dir"
    fi

    mkdir -p "$tool_dir"
    echo "$node_spec" > "${tool_dir}/.node-version"
    echo "$pkg_spec" > "${tool_dir}/.package-spec"

    echo "→ installing ${install_spec}..."

    "${node_dir}/bin/npm" install --prefix "$tool_dir" "$install_spec"
    local npm_exit=$?

    if [[ $npm_exit -ne 0 ]]; then
        echo "nt: npm install failed"
        rm -rf "$tool_dir"
        return 1
    fi

    local count
    count=$(__nt_create_wrappers "$node_dir" "$tool_dir" "$pkg_name")

    echo "✓ ${install_spec} installed — ${count} bin(s) in ${NT_BIN}"

    if [[ ":$PATH:" != *":${NT_BIN}:"* ]]; then
        echo "  ⚠  add to ~/.bashrc or ~/.zshrc:"
        echo "     export PATH=\"${NT_BIN}:\$PATH\""
    fi
}

__nt_remove() {
    local dir_name="$1"

    if [[ -z "$dir_name" ]]; then
        echo "Usage: nt remove <package>"
        return 1
    fi

    local parsed
    readarray -t parsed < <(__nt_parse_pkg_spec "$dir_name")
    dir_name="${parsed[2]}"
    local tool_dir="${NT_TOOLS}/${dir_name}"

    if [[ ! -d "$tool_dir" ]]; then
        echo "nt: ${dir_name} is not installed"
        return 1
    fi

    __nt_cleanup_wrappers "$tool_dir"
    rm -rf "$tool_dir"

    echo "✓ ${dir_name} removed"
}

__nt_update() {
    if [[ ! -d "$NT_TOOLS" ]]; then
        echo "nothing installed"
        return
    fi

    local tools=("$NT_TOOLS"/*/)
    if [[ ${#tools[@]} -eq 0 ]] || [[ ! -d "${tools[0]}" ]]; then
        echo "nothing installed"
        return
    fi

    for tool_dir in "${tools[@]}"; do
        local dir_name
        dir_name=$(basename "$tool_dir")
        local node_spec
        node_spec=$(cat "${tool_dir}/.node-version" 2>/dev/null || echo "latest")
        local pkg_spec
        pkg_spec=$(cat "${tool_dir}/.package-spec" 2>/dev/null || echo "$dir_name")

        echo ""
        echo "━━ ${dir_name} (node@${node_spec}, pkg: ${pkg_spec})"
        __nt_install --node="$node_spec" "$pkg_spec"
    done
}

__nt_list() {
    if [[ ! -d "$NT_TOOLS" ]]; then
        echo "nothing installed"
        return
    fi

    local tools=("$NT_TOOLS"/*/)
    if [[ ${#tools[@]} -eq 0 ]] || [[ ! -d "${tools[0]}" ]]; then
        echo "nothing installed"
        return
    fi

    for tool_dir in "${tools[@]}"; do
        local dir_name
        dir_name=$(basename "$tool_dir")
        local node_spec
        node_spec=$(cat "${tool_dir}/.node-version" 2>/dev/null || echo "?")
        local pkg_spec
        pkg_spec=$(cat "${tool_dir}/.package-spec" 2>/dev/null || echo "?")
        echo "  ${dir_name}  pkg: ${pkg_spec}  node: ${node_spec}"
    done
}

case "${1:-}" in
    install)
        shift
        __nt_install "$@"
        ;;
    remove|rm)
        shift
        __nt_remove "$@"
        ;;
    update|up)
        __nt_update
        ;;
    list|ls)
        __nt_list
        ;;
    "")
        echo "Usage:"
        echo "  nt install [--node=<version>] <package>[@version]"
        echo "  nt remove <package>"
        echo "  nt update"
        echo "  nt list"
        ;;
    *)
        echo "nt: unknown command '$1'"
        exit 1
        ;;
esac
