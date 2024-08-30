#!/usr/bin/env bash
#
# Fetches the latest metaplex programs and produces the solana-genesis command-line
# arguments needed to install them
#
# These programs are fetched from: https://github.com/metaplex-foundation/metaplex-program-library/blob/master/Anchor.toml

set -e

here=$(dirname "$0")
# shellcheck source=multinode-demo/common.sh
source "$here"/multinode-demo/common.sh

upgradeableLoader=BPFLoaderUpgradeab1e11111111111111111111111
url="http://api.mainnet-beta.solana.com"

fetch_program() {
  declare name=$1
  declare address=$2
  declare loader=$3

  if [[ $loader == "$upgradeableLoader" ]]; then
    genesis_args+=(--upgradeable-program "$address" "$loader" "$name.so" none)
  else
    genesis_args+=(--bpf-program "$address" "$loader" "$name.so")
  fi

  $solana_cli program dump "$address" "$name.so" --url "$url"
}

fetch_program mpl_token-metadata metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s BPFLoaderUpgradeab1e11111111111111111111111
fetch_program mpl_auction-house hausS13jsjafwWwGqZTUQRmWyvyxn9EQpqMwV1PBBmk BPFLoaderUpgradeab1e11111111111111111111111
fetch_program mpl_token-entagler qntmGodpGkrM42mN68VCZHXnKqDCT8rdY23wFcXCLPd BPFLoaderUpgradeab1e11111111111111111111111
fetch_program mpl_fixed-price-sale SaLeTjyUa5wXHnGuewUSyJ5JWZaHwz3TxqUntCE9czo BPFLoaderUpgradeab1e11111111111111111111111
fetch_program mpl_gumdrop gdrpGjVffourzkdDRrQmySw4aTHr8a3xmQzzxSwFD1a BPFLoaderUpgradeab1e11111111111111111111111
fetch_program mpl_hydra hyDQ4Nz1eYyegS6JfenyKwKzYxRsCWCriYSAjtzP4Vg BPFLoaderUpgradeab1e11111111111111111111111

echo "${genesis_args[@]}" >metaplex-genesis-args.sh