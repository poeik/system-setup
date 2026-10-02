#!/usr/bin/env bash

not_available() {
  ! command -v "$1" &>/dev/null
}
