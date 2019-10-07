#!/bin/bash
set -ex

UNISWAP_FACTORY_ADDRESS=""

function fetch_uniswap_factory_address() {
  gsutil -q cp gs://keep-dev-contract-data/uniswap/${UNISWAP_CONTRACT_DATA} ./
  UNISWAP_FACTORY_ADDRESS=$(cat ./${UNISWAP_CONTRACT_DATA} | grep Factory | awk '{print $2}')
}

function set_uniswap_factory_address() {
  sed -i -e "/UniswapFactoryAddress/s/0x[a-fA-F0-9]\{0,40\}/${UNISWAP_FACTORY_ADDRESS}/" ./implementation/migrations/externals.js
}

fetch_uniswap_factory_address
set_uniswap_factory_address
