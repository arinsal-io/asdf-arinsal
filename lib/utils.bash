#!/usr/bin/env bash

arinsal::api_token() {
	printf '%s' "${GITHUB_API_TOKEN:-${GITHUB_TOKEN:-}}"
}

arinsal::curl() {
	local token
	token=$(arinsal::api_token)
	local -a options=(--fail --silent --show-error --location --retry 3)
	options+=(--header 'Accept: application/vnd.github+json')
	if [ -n "$token" ]; then
		options+=(--header "Authorization: Bearer $token")
	fi
	curl "${options[@]}" "$@"
}

arinsal::github_api_get() {
	local url=$1 output=$2 token
	token=$(arinsal::api_token)
	local -a options=(--silent --show-error --location --retry 3)
	options+=(--header 'Accept: application/vnd.github+json')
	options+=(--output "$output" --write-out '%{http_code}')
	if [ -n "$token" ]; then
		options+=(--header "Authorization: Bearer $token")
	fi
	curl "${options[@]}" "$url"
}

arinsal::target_triple() {
	local os arch
	os=$(uname -s)
	arch=$(uname -m)
	case "$os:$arch" in
	Darwin:arm64 | Darwin:aarch64) printf '%s\n' aarch64-apple-darwin ;;
	Linux:aarch64 | Linux:arm64) printf '%s\n' aarch64-unknown-linux-gnu ;;
	Darwin:x86_64 | Darwin:amd64 | Linux:x86_64 | Linux:amd64)
		echo "arinsal: x86-64 is not supported (supported: aarch64-apple-darwin, aarch64-unknown-linux-gnu)" >&2
		return 1
		;;
	*)
		echo "arinsal: unsupported platform $os/$arch (supported: aarch64-apple-darwin, aarch64-unknown-linux-gnu)" >&2
		return 1
		;;
	esac
}

arinsal::verify_sha256() {
	local archive=$1 checksum_file=$2 expected actual
	expected=$(awk 'NF { print $1; exit }' "$checksum_file")
	case "$expected" in
	'' | *[!0-9a-fA-F]*)
		echo "arinsal: invalid SHA-256 sidecar: $checksum_file" >&2
		return 1
		;;
	esac
	if [ "${#expected}" -ne 64 ]; then
		echo "arinsal: invalid SHA-256 sidecar: $checksum_file" >&2
		return 1
	fi
	if command -v shasum >/dev/null 2>&1; then
		actual=$(shasum -a 256 "$archive" | awk '{ print $1 }')
	elif command -v sha256sum >/dev/null 2>&1; then
		actual=$(sha256sum "$archive" | awk '{ print $1 }')
	else
		echo 'arinsal: shasum or sha256sum is required to verify the distribution' >&2
		return 1
	fi
	if [ "$actual" != "$expected" ]; then
		echo "arinsal: SHA-256 mismatch for $archive" >&2
		return 1
	fi
}
