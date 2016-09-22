# nmon.gawk
/^PROC,T/{
currenttime=systime()
print "server."hostname".cpu.runQueue",$3,currenttime
fflush();
}
/^CPU_ALL,T/{
currenttime=systime()
print "server."hostname".cpu.usr",$3,currenttime
print "server."hostname".cpu.sys",$4,currenttime
print "server."hostname".cpu.wait",$5,currenttime
totalcpuusage=100-$6;
print "server."hostname".cpu.total",totalcpuusage,currenttime
fflush();
}

/^MEM,T/{
currenttime=systime()
memused=$3-$7;
swapused=$6-$10;
print "server."hostname".mem.total",$3,currenttime
print "server."hostname".mem.free",$7,currenttime
print "server."hostname".mem.used",memused,currenttime
print "server."hostname".swap.total",$6,currenttime
print "server."hostname".swap.free",$10,currenttime
print "server."hostname".swap.used",swapused,currenttime
fflush();
}

/^NETPACKET,T/{
num_interfaces=(NF-3)/2;
read_sum=0;
for (i=3;i<(3+num_interfaces);i++) {
     read_sum=read_sum+$i;
}
write_sum=0;
for (i=(3+num_interfaces);i<=NF;i++) {
     write_sum=write_sum+$i;
}
currenttime=systime();
print "server."hostname".network.packetReadsec",read_sum,currenttime;
print "server."hostname".network.packetWritesec",write_sum,currenttime;
fflush();
}
/^NET,T/{
num_interfaces=(NF-3)/2;
read_sum=0;
for (i=3;i<(3+num_interfaces);i++) {
     read_sum=read_sum+$i;
}
write_sum=0;
for (i=(3+num_interfaces);i<=NF;i++) {
     write_sum=write_sum+$i;
}
currenttime=systime();
print "server."hostname".network.readKBsec",read_sum,currenttime;
print "server."hostname".network.writeKBsec",write_sum,currenttime;
fflush();
}


/^DISKWRITE,T/ {
num_disks=(NF-2);
currenttime=systime()
write_sum=0;    
for (i=3;i<=(2+num_disks);i++) {
     write_sum=write_sum+$i;
}
print "server."hostname".disk.writeKBsec",write_sum,currenttime;
fflush();
}

/^DISKREAD,T/ {
num_disks=(NF-2);
currenttime=systime()
read_sum=0;    
for (i=3;i<=(2+num_disks);i++) {
     read_sum=read_sum+$i;
}
print "server."hostname".disk.readKBsec",read_sum,currenttime;
fflush();
}

/^DISKXFER,T/ {
num_interfaces=(NF-2);
xfer_sum=0;
for (i=3;i<=(2+num_interfaces);i++) {
     xfer_sum=xfer_sum+$i;
}
currenttime=systime();
print "server."hostname".disk.iops",xfer_sum,currenttime;
fflush();
}