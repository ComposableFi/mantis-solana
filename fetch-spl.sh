#!/usr/bin/env bash
#
# Fetches the latest SPL programs and produces the solana-genesis command-line
# arguments needed to install them
#

set -e

upgradeableLoader=BPFLoaderUpgradeab1e11111111111111111111111
PROGRAMS_PATH=../solana-program-library/target/deploy

fetch_program() {
  declare name=$1
  declare version=$2
  declare address=$3
  declare loader=$4
  declare repo=$5

  case $repo in
  "jito")
    so=$name-$version.so
    so_name="$name.so"
    url="https://github.com/jito-foundation/jito-programs/releases/download/v$version/$so_name"
    ;;
  "solana")
    so=spl_$name-$version.so
    so_name="spl_${name//-/_}.so"
    url="https://github.com/ComposableFi/solana-program-library/releases/download/v$version/$so_name"
    ;;
  "rollup")
    so=spl_$name-$version.so
    so_name="spl_${name//-/_}.so"
    url="https://github.com/ComposableFi/solana-program-library/releases/download/v$version/$so_name"
    ;;
  "path")
    so="spl_${name//-/_}.so"
    programs_path=$6
    if [[ ! -d $programs_path ]]; then
      echo "Invalid programs path: $programs_path"
      return 1
    fi
    so=$programs_path/$so
    ;;
  *)
    echo "Unsupported repo: $repo"
    return 1
    ;;
  esac

  if [[ $loader == "$upgradeableLoader" ]]; then
    genesis_args+=(--upgradeable-program "$address" "$loader" "$so" none)
  else
    genesis_args+=(--bpf-program "$address" "$loader" "$so")
  fi

  if [[ -r $so ]]; then
    return
  fi

  if [[ -r ~/.cache/solana-spl/$so ]]; then
    cp ~/.cache/solana-spl/"$so" "$so"
  else
    echo "Downloading $name $version"
    (
      set -x
      curl -L --retry 5 --retry-delay 2 --retry-connrefused \
        -o "$so" \
        "$url"
    )

    mkdir -p ~/.cache/solana-spl
    cp "$so" ~/.cache/solana-spl/"$so"
  fi

}

MANTIS_SPL_VERSION=0.1.0

# Token program is made upgradeable since it has rebasing logic.
fetch_program token $MANTIS_SPL_VERSION TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA BPFLoaderUpgradeab1e11111111111111111111111 rollup
fetch_program token_2022 $MANTIS_SPL_VERSION TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb BPFLoaderUpgradeab1e11111111111111111111111 rollup
fetch_program memo $MANTIS_SPL_VERSION Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo BPFLoader1111111111111111111111111111111111 rollup
fetch_program memo $MANTIS_SPL_VERSION MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr BPFLoader2111111111111111111111111111111111 rollup
fetch_program associated_token_account $MANTIS_SPL_VERSION ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL BPFLoader2111111111111111111111111111111111 rollup
fetch_program feature_proposal $MANTIS_SPL_VERSION Feat1YXHhH6t1juaWF74WLcfv4XoNocjXA6sPWHNgAse BPFLoader2111111111111111111111111111111111 rollup
# jito programs
fetch_program jito_tip_payment 0.1.4 T1pyyaTNZsKv2WcRAB8oVnk93mLJw2XzjtVYqCsaHqt BPFLoaderUpgradeab1e11111111111111111111111 jito
fetch_program jito_tip_distribution 0.1.4 4R3gSG8BpU4t19KYj8CfnbtRpnT8gtk4dvTHxVRwc2r7 BPFLoaderUpgradeab1e11111111111111111111111 jito

echo "${genesis_args[@]}" > spl-genesis-args.sh

echo
echo "Available SPL programs:"
ls -l spl_*.so
ls -l $PROGRAMS_PATH/*.so || true

echo "Available Jito programs:"
ls -l jito*.so

echo
echo "solana-genesis command-line arguments (spl-genesis-args.sh):"
cat spl-genesis-args.sh
