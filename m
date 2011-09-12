From: Alex Bligh <alex@alex.org.uk>
Subject: Re: [PATCH] Fix repeatable Oops on container destroy with conntrack
Date: Mon, 12 Sep 2011 11:32:18 +0100
Message-ID: <E0902A9541FD5D118EA02B31@Ximines.local>
References: <2184C0CE5A5EDC94CDDA5053@Ximines.local>
 <20110912072524.GA2996@p183.telecom.by> <20110912093749.GE2194@1984>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110912093749.GE2194@1984>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>, Alexey Dobriyan <adobriyan@gmail.com>
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Linux Containers <containers@lists.osdl.org>, Alex Bligh <alex@alex.org.uk>
List-Id: containers.vger.kernel.org

Alexey / Pablo,

--On 12 September 2011 11:37:49 +0200 Pablo Neira Ayuso 
<pablo@netfilter.org> wrote:

> On Mon, Sep 12, 2011 at 10:25:24AM +0300, Alexey Dobriyan wrote:
>> On Sat, Sep 10, 2011 at 07:48:43PM +0100, Alex Bligh wrote:
>> > --- a/net/netfilter/nf_conntrack_netlink.c
>> > +++ b/net/netfilter/nf_conntrack_netlink.c
>> > @@ -570,6 +570,11 @@ ctnetlink_conntrack_event(unsigned int events,
>> > struct nf_ct_event *item) return 0;
>> >
>> >  	net = nf_ct_net(ct);
>> > +
>> > +	/* container deinit, netlink may have died before death_by_timeout */
>> > +	if (!net->nfnl)
>> > +		return 0;
>> > +
>> >  	if (!item->report && !nfnetlink_has_listeners(net, group))
>> >  		return 0;
>>
>> If this is correct fix, ->nfnl check should be folded into
>> nfnetlink_has_listeners(), otherwise expectations aren't covered.
>
> Agreed.

I /think/ it is the correct fix, in that it certainly fixes the oops,
and it's relatively low overhead. I ran the torture test for 24 hours
without a problem.

My only concern is that eventually my torture test died as the
machine (512MB VM) had run out of memory - this was after about 30
hours. Save for having no free memory, the box is happy.
It looks like there is something (possibly something
entirely different) leaking memory. It does not appear to be
conntrack. Whatever, a slow memory leak causing death on a tiny
VM over 5,000 iterations is better than an oops after 5. Memory
stats below. I will leave the vm up in case anyone wants other
stats.

On the suggestion to move the check for ->nfnl into
nfnetlink_has_listeners(), the problem with that is that
if item->report is non-NULL, nfnetlink_has_listeners()
will not be called, and the early return will not be made.
This will merely delay the oops until elsewhere (nfnetlink_send
for example). The check is currently as follows:

        if (!item->report && !nfnetlink_has_listeners(net, group))
                return 0;

I am a very long way from being a netlink expert, but I am not
entirely sure what the point of progressing further is if there
are no listeners if item->report is non-null. Certainly there is
no point in progressing if net->nfnl NULL (as this will oops
before item->report is meaningfully used - it's just passed
as a parametner to nfnetlink_send which will crash). It's
almost as if that test should be || not &&.

Perhaps we should check net->nfnl in both places.

I think there might be similar issues with ctnetlink_expect_event.

-- 
Alex Bligh

root@azed:/home/amb# cat /proc/meminfo
MemTotal:         438432 kB
MemFree:           10648 kB
Buffers:           88944 kB
Cached:           219532 kB
SwapCached:         3500 kB
Active:           142540 kB
Inactive:         182796 kB
Active(anon):       7092 kB
Inactive(anon):     9804 kB
Active(file):     135448 kB
Inactive(file):   172992 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:        520188 kB
SwapFree:         485356 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         15956 kB
Mapped:             5644 kB
Shmem:                36 kB
Slab:              87296 kB
SReclaimable:      65384 kB
SUnreclaim:        21912 kB
KernelStack:        1080 kB
PageTables:         3208 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      739404 kB
Committed_AS:     570652 kB
VmallocTotal:   34359738367 kB
VmallocUsed:        3600 kB
VmallocChunk:   34359732156 kB
HardwareCorrupted:     0 kB
AnonHugePages:         0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       36844 kB
DirectMap2M:      487424 kB

root@azed:/home/amb# cat /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> 
<pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata 
<active_slabs> <num_slabs> <sharedavail>
nf_conntrack_expect      0      0    240   17    1 : tunables    0    0 
0 : slabdata      0      0      0
nf_conntrack_ffffffff81f09100     28     39    312   13    1 : tunables 
0    0    0 : slabdata      3      3      0
UDPLITEv6              0      0   1024   16    4 : tunables    0    0    0 
: slabdata      0      0      0
UDPv6                 32     32   1024   16    4 : tunables    0    0    0 
: slabdata      2      2      0
tw_sock_TCPv6         12     12    320   12    1 : tunables    0    0    0 
: slabdata      1      1      0
TCPv6                 34     34   1920   17    8 : tunables    0    0    0 
: slabdata      2      2      0
kcopyd_job             0      0   3384    9    8 : tunables    0    0    0 
: slabdata      0      0      0
dm_uevent              0      0   2608   12    8 : tunables    0    0    0 
: slabdata      0      0      0
dm_rq_target_io        0      0    400   20    2 : tunables    0    0    0 
: slabdata      0      0      0
cfq_queue              0      0    232   17    1 : tunables    0    0    0 
: slabdata      0      0      0
bsg_cmd                0      0    312   13    1 : tunables    0    0    0 
: slabdata      0      0      0
mqueue_inode_cache     18     18    896   18    4 : tunables    0    0    0 
: slabdata      1      1      0
fuse_request           0      0    608   13    2 : tunables    0    0    0 
: slabdata      0      0      0
fuse_inode             0      0    768   21    4 : tunables    0    0    0 
: slabdata      0      0      0
ecryptfs_key_record_cache      0      0    576   14    2 : tunables    0 
0    0 : slabdata      0      0      0
ecryptfs_inode_cache      0      0   1024   16    4 : tunables    0    0 
0 : slabdata      0      0      0
hugetlbfs_inode_cache     13     13    616   13    2 : tunables    0    0 
0 : slabdata      1      1      0
journal_handle       340    340     24  170    1 : tunables    0    0    0 
: slabdata      2      2      0
journal_head          72     72    112   36    1 : tunables    0    0    0 
: slabdata      2      2      0
revoke_record        256    256     32  128    1 : tunables    0    0    0 
: slabdata      2      2      0
ext4_inode_cache   27639  27727    920   17    4 : tunables    0    0    0 
: slabdata   1631   1631      0
ext4_free_data       146    146     56   73    1 : tunables    0    0    0 
: slabdata      2      2      0
ext4_allocation_context    210    210    136   30    1 : tunables    0    0 
0 : slabdata      7      7      0
ext4_io_end           28     28   1128   14    4 : tunables    0    0    0 
: slabdata      2      2      0
ext4_io_page         514    768     16  256    1 : tunables    0    0    0 
: slabdata      3      3      0
ext2_inode_cache      40     40    792   20    4 : tunables    0    0    0 
: slabdata      2      2      0
ext3_inode_cache       0      0    816   20    4 : tunables    0    0    0 
: slabdata      0      0      0
ext3_xattr             0      0     88   46    1 : tunables    0    0    0 
: slabdata      0      0      0
dquot                  0      0    256   16    1 : tunables    0    0    0 
: slabdata      0      0      0
dnotify_mark          63     90    136   30    1 : tunables    0    0    0 
: slabdata      3      3      0
pid_namespace          0      0   2112   15    8 : tunables    0    0    0 
: slabdata      0      0      0
user_namespace         0      0   1072   15    4 : tunables    0    0    0 
: slabdata      0      0      0
UDP-Lite               0      0    832   19    4 : tunables    0    0    0 
: slabdata      0      0      0
xfrm_dst_cache         0      0    448   18    2 : tunables    0    0    0 
: slabdata      0      0      0
ip_fib_trie          146    146     56   73    1 : tunables    0    0    0 
: slabdata      2      2      0
arp_cache             24     24    320   12    1 : tunables    0    0    0 
: slabdata      2      2      0
RAW                   62     76    832   19    4 : tunables    0    0    0 
: slabdata      4      4      0
UDP                   38     38    832   19    4 : tunables    0    0    0 
: slabdata      2      2      0
tw_sock_TCP           16     16    256   16    1 : tunables    0    0    0 
: slabdata      1      1      0
TCP                   36     36   1728   18    8 : tunables    0    0    0 
: slabdata      2      2      0
blkdev_queue          54     54   1728   18    8 : tunables    0    0    0 
: slabdata      3      3      0
blkdev_requests       79     88    360   22    2 : tunables    0    0    0 
: slabdata      4      4      0
fsnotify_event        68     68    120   34    1 : tunables    0    0    0 
: slabdata      2      2      0
bip-256                7      7   4224    7    8 : tunables    0    0    0 
: slabdata      1      1      0
bip-128                0      0   2176   15    8 : tunables    0    0    0 
: slabdata      0      0      0
bip-64                 0      0   1152   14    4 : tunables    0    0    0 
: slabdata      0      0      0
bip-16                49     63    384   21    2 : tunables    0    0    0 
: slabdata      3      3      0
sock_inode_cache      96    161    704   23    4 : tunables    0    0    0 
: slabdata      7      7      0
file_lock_cache       44     44    184   22    1 : tunables    0    0    0 
: slabdata      2      2      0
net_namespace         24     24   2624   12    8 : tunables    0    0    0 
: slabdata      2      2      0
shmem_inode_cache   4000   4009    824   19    4 : tunables    0    0    0 
: slabdata    211    211      0
Acpi-ParseExt       1085   1176     72   56    1 : tunables    0    0    0 
: slabdata     21     21      0
Acpi-Namespace       981   1122     40  102    1 : tunables    0    0    0 
: slabdata     11     11      0
task_delay_info      206    540    112   36    1 : tunables    0    0    0 
: slabdata     15     15      0
taskstats             24     24    328   12    1 : tunables    0    0    0 
: slabdata      2      2      0
proc_inode_cache   37093  37512    664   12    2 : tunables    0    0    0 
: slabdata   3126   3126      0
sigqueue              50     50    160   25    1 : tunables    0    0    0 
: slabdata      2      2      0
bdev_cache            38     38    832   19    4 : tunables    0    0    0 
: slabdata      2      2      0
sysfs_dir_cache    13096  13209     80   51    1 : tunables    0    0    0 
: slabdata    259    259      0
inode_cache         4199   4329    600   13    2 : tunables    0    0    0 
: slabdata    333    333      0
dentry             66510  72786    192   21    1 : tunables    0    0    0 
: slabdata   3466   3466      0
buffer_head        42233  43368    104   39    1 : tunables    0    0    0 
: slabdata   1112   1112      0
vm_area_struct      2685   2875    176   23    1 : tunables    0    0    0 
: slabdata    125    125      0
mm_struct             67    108    896   18    4 : tunables    0    0    0 
: slabdata      6      6      0
files_cache           74    115    704   23    4 : tunables    0    0    0 
: slabdata      5      5      0
signal_cache         104    285   1088   15    4 : tunables    0    0    0 
: slabdata     19     19      0
sighand_cache        104    270   2112   15    8 : tunables    0    0    0 
: slabdata     18     18      0
task_struct          142    220   5920    5    8 : tunables    0    0    0 
: slabdata     44     44      0
anon_vma            1549   1736     72   56    1 : tunables    0    0    0 
: slabdata     31     31      0
shared_policy_node   2813   5015     48   85    1 : tunables    0    0    0 
: slabdata     59     59      0
numa_policy          852   1020     24  170    1 : tunables    0    0    0 
: slabdata      6      6      0
radix_tree_node     2234   2282    568   14    2 : tunables    0    0    0 
: slabdata    163    163      0
idr_layer_cache      269    300    544   15    2 : tunables    0    0    0 
: slabdata     20     20      0
dma-kmalloc-8192       0      0   8192    4    8 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-4096       0      0   4096    8    8 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-2048       0      0   2048   16    8 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-1024       0      0   1024   16    4 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-512       16     16    512   16    2 : tunables    0    0    0 
: slabdata      1      1      0
dma-kmalloc-256        0      0    256   16    1 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-128        0      0    128   32    1 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-64         0      0     64   64    1 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-32         0      0     32  128    1 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-16         0      0     16  256    1 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-8          0      0      8  512    1 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-192        0      0    192   21    1 : tunables    0    0    0 
: slabdata      0      0      0
dma-kmalloc-96         0      0     96   42    1 : tunables    0    0    0 
: slabdata      0      0      0
kmalloc-8192          36     36   8192    4    8 : tunables    0    0    0 
: slabdata      9      9      0
kmalloc-4096         128    128   4096    8    8 : tunables    0    0    0 
: slabdata     16     16      0
kmalloc-2048         177    192   2048   16    8 : tunables    0    0    0 
: slabdata     12     12      0
kmalloc-1024        4340   4800   1024   16    4 : tunables    0    0    0 
: slabdata    300    300      0
kmalloc-512         2503   6240    512   16    2 : tunables    0    0    0 
: slabdata    390    390      0
kmalloc-256          461    464    256   16    1 : tunables    0    0    0 
: slabdata     29     29      0
kmalloc-128         6270  14144    128   32    1 : tunables    0    0    0 
: slabdata    442    442      0
kmalloc-64          3123   4288     64   64    1 : tunables    0    0    0 
: slabdata     67     67      0
kmalloc-32           978   2048     32  128    1 : tunables    0    0    0 
: slabdata     16     16      0
kmalloc-16          2560   2560     16  256    1 : tunables    0    0    0 
: slabdata     10     10      0
kmalloc-8           6079   6144      8  512    1 : tunables    0    0    0 
: slabdata     12     12      0
kmalloc-192         1823   3234    192   21    1 : tunables    0    0    0 
: slabdata    154    154      0
kmalloc-96           516    630     96   42    1 : tunables    0    0    0 
: slabdata     15     15      0
kmem_cache            32     32    256   16    1 : tunables    0    0    0 
: slabdata      2      2      0
kmem_cache_node      191    192     64   64    1 : tunables    0    0    0 
: slabdata      3      3      0
root@azed:/home/amb#
root@azed:/home/amb# ps auxwwg
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.4  24044  1768 ?        Ss   Sep10   0:19 /sbin/init
root         2  0.0  0.0      0     0 ?        S    Sep10   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        S    Sep10   0:01 
[ksoftirqd/0]
root         5  0.0  0.0      0     0 ?        S    Sep10   0:00 
[kworker/u:0]
root         6  0.0  0.0      0     0 ?        S    Sep10   0:00 
[migration/0]
root         7  0.0  0.0      0     0 ?        S    Sep10   0:00 
[migration/1]
root         9  0.0  0.0      0     0 ?        S    Sep10   0:01 
[ksoftirqd/1]
root        11  0.0  0.0      0     0 ?        S<   Sep10   0:00 [cpuset]
root        12  0.0  0.0      0     0 ?        S<   Sep10   0:00 [khelper]
root        13  0.0  0.0      0     0 ?        S<   Sep10   0:00 [netns]
root        14  0.0  0.0      0     0 ?        S    Sep10   0:00 
[sync_supers]
root        15  0.0  0.0      0     0 ?        S    Sep10   0:08 
[kworker/u:1]
root        16  0.0  0.0      0     0 ?        S    Sep10   0:00 
[bdi-default]
root        17  0.0  0.0      0     0 ?        S<   Sep10   0:00 
[kintegrityd]
root        18  0.0  0.0      0     0 ?        S<   Sep10   0:00 [kblockd]
root        19  0.0  0.0      0     0 ?        S<   Sep10   0:00 [ata_sff]
root        20  0.0  0.0      0     0 ?        S    Sep10   0:00 [khubd]
root        21  0.0  0.0      0     0 ?        S<   Sep10   0:00 [md]
root        23  0.0  0.0      0     0 ?        S    Sep10   0:00 
[khungtaskd]
root        24  0.0  0.0      0     0 ?        S    Sep10   0:05 [kswapd0]
root        25  0.0  0.0      0     0 ?        SN   Sep10   0:00 [ksmd]
root        26  0.0  0.0      0     0 ?        S    Sep10   0:00 
[fsnotify_mark]
root        27  0.0  0.0      0     0 ?        S    Sep10   0:00 
[ecryptfs-kthrea]
root        28  0.0  0.0      0     0 ?        S<   Sep10   0:00 [crypto]
root        36  0.0  0.0      0     0 ?        S<   Sep10   0:00 [kthrotld]
root        38  0.0  0.0      0     0 ?        S    Sep10   0:00 [scsi_eh_0]
root        39  0.0  0.0      0     0 ?        S    Sep10   0:00 [scsi_eh_1]
root       208  0.0  0.0      0     0 ?        S<   Sep10   0:00 [kdmflush]
root       220  0.0  0.0      0     0 ?        S<   Sep10   0:00 [kdmflush]
root       229  0.0  0.0      0     0 ?        S    Sep10   0:01 
[jbd2/dm-0-8]
root       230  0.0  0.0      0     0 ?        S<   Sep10   0:00 
[ext4-dio-unwrit]
root       292  0.0  0.1  17096   476 ?        S    Sep10   0:08 
upstart-udev-bridge --daemon
root       295  0.0  0.1  21360   796 ?        Ss   Sep10   0:11 udevd 
--daemon
root       373  0.0  0.0      0     0 ?        S    Sep10   0:00 [vballoon]
105        405  0.0  0.1  24152   568 ?        Ss   Sep10   0:03 
dbus-daemon --system --fork --activation=upstart
syslog     421  0.0  0.1  52732   820 ?        Sl   Sep10   0:08 rsyslogd 
-c5
root       428  0.0  0.0      0     0 ?        S<   Sep10   0:00 [kpsmoused]
root       522  0.0  0.0  15048   352 ?        S    Sep10   0:01 
upstart-socket-bridge --daemon
root       563  0.0  0.3  49684  1564 ?        Ss   Sep10   0:00 
/usr/sbin/sshd -D
root       678  0.0  0.1   4180   500 tty4     Ss+  Sep10   0:00 
/sbin/getty -8 38400 tty4
root       684  0.0  0.1   4180   500 tty5     Ss+  Sep10   0:00 
/sbin/getty -8 38400 tty5
root       696  0.0  0.1   4180   500 tty2     Ss+  Sep10   0:00 
/sbin/getty -8 38400 tty2
root       697  0.0  0.1   4180   500 tty3     Ss+  Sep10   0:00 
/sbin/getty -8 38400 tty3
root       699  0.0  0.1   4180   500 tty6     Ss+  Sep10   0:00 
/sbin/getty -8 38400 tty6
root       702  0.0  0.1   4196   520 ?        Ss   Sep10   0:00 acpid -c 
/etc/acpi/events -s /var/run/acpid.socket
root       703  0.0  0.1  18976   704 ?        Ss   Sep10   0:00 cron
daemon     704  0.0  0.0  16776   196 ?        Ss   Sep10   0:00 atd
root       705  0.0  0.1  15848   488 ?        Ss   Sep10   0:10 
/usr/sbin/irqbalance
bind       764  0.0  0.4 125828  2068 ?        Ssl  Sep10   0:00 
/usr/sbin/named -u bind
root       840  0.0  0.1   4180   500 tty1     Ss+  Sep10   0:00 
/sbin/getty -8 38400 tty1
root       844  0.0  0.3  73084  1608 ?        Ss   Sep10   0:00 sshd: amb 
[priv]
amb        871  0.0  0.1  73084   684 ?        S    Sep10   0:21 sshd: 
amb@pts/0
amb        872  0.0  0.1  28104   856 pts/0    Ss   Sep10   0:00 -bash
root       974  0.0  0.2  35548   956 pts/0    S    Sep10   0:00 sudo su
root       975  0.0  0.2  39320   884 pts/0    S    Sep10   0:00 su
root       976  0.0  0.3  21752  1692 pts/0    S    Sep10   0:00 bash
root      1328  0.0  0.3  73084  1608 ?        Ss   Sep10   0:00 sshd: amb 
[priv]
amb       1371  0.0  0.1  73084   632 ?        S    Sep10   0:01 sshd: 
amb@pts/1
amb       1372  0.0  0.1  28172   852 pts/1    Ss+  Sep10   0:00 -bash
root      3919  0.0  0.0      0     0 ?        S    Sep11   0:00 
[kworker/0:2]
root      6185  0.0  0.0    188    12 ?        Ss   Sep10   0:01 runsvdir 
-P /etc/service log: 
...........................................................................................................................................................................................................................................................................................................................................................................................................
root      6350  0.0  0.0    164     0 ?        Ss   Sep10   0:00 runsv 
git-daemon
gitlog    6351  0.0  0.0    184     0 ?        S    Sep10   0:00 svlogd -tt 
/var/log/git-daemon
107       6352  0.0  0.1   9108   552 ?        S    Sep10   0:00 
/usr/lib/git-core/git-daemon --verbose --reuseaddr --base-path=/var/cache 
/var/cache/git
root     10047  0.0  2.8  57560 12404 ?        S    Sep11   0:04 python 
/usr/sbin/denyhosts --daemon --purge --config=/etc/denyhosts.conf
root     10561  0.0  0.1  21356   464 ?        S    Sep11   0:00 udevd 
--daemon
root     10639  0.0  0.0  21356   416 ?        S    Sep11   0:00 udevd 
--daemon
root     13015  0.0  0.0      0     0 ?        S    Sep11   0:00 
[kworker/1:2]
root     20473  0.0  0.0      0     0 ?        S    Sep11   0:00 
[kworker/0:0]
root     20831  0.0  0.0      0     0 ?        S    11:05   0:00 
[flush-252:0]
root     20914  0.0  0.2  16680  1188 pts/0    R+   11:15   0:00 ps auxwwg
root     22549  0.0  0.0      0     0 ?        S    Sep11   0:02 
[kworker/1:1]
root@azed:/home/amb#
