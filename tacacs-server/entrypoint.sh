#!/bin/sh

exec ${TAC_PLUS_BIN} -l /dev/stdout -G -C ${CONF_FILE} "$@"