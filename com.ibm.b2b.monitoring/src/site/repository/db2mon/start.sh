#!/bin/sh
# db2 DB2 10.5 statistics

./db2mon.sh qfdb | nc gdhape01.canlab.ibm.com 2003
