From: James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>
Subject: Re: memcg: fix fatal livelock in kswapd
Date: Tue, 03 May 2011 09:11:04 -0500
Message-ID: <1304431865.2576.3.camel__1016.17075638405$1304433087$gmane$org@mulgrave.site>
References: <1304366849.15370.27.camel@mulgrave.site>
	<20110502224838.GB10278@cmpxchg.org>
	<BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
	<1304380698.15370.36.camel@mulgrave.site>
	<20110503063817.GD10278@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110503063817.GD10278-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Chris Mason <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2011-05-03 at 08:38 +0200, Johannes Weiner wrote:
> On Mon, May 02, 2011 at 06:58:18PM -0500, James Bottomley wrote:
> > On Mon, 2011-05-02 at 16:14 -0700, Ying Han wrote:
> > > On Mon, May 2, 2011 at 3:48 PM, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org> wrote:
> > > > I am very much for removing this hack.  There is still more scan
> > > > pressure applied to memcgs in excess of their soft limit even if the
> > > > extra scan is happening at a sane priority level.  And the fact that
> > > > global reclaim operates completely unaware of memcgs is a different
> > > > story.
> > > >
> > > > However, this code came into place with v2.6.31-8387-g4e41695.  Why is
> > > > it only now showing up?
> > > >
> > > > You also wrote in that thread that this happens on a standard F15
> > > > installation.  On the F15 I am running here, systemd does not
> > > > configure memcgs, however.  Did you manually configure memcgs and set
> > > > soft limits?  Because I wonder how it ended up in soft limit reclaim
> > > > in the first place.
> > 
> > It doesn't ... it's standard FC15 ... the mere fact of having memcg
> > compiled into the kernel is enough to do it (conversely disabling it at
> > compile time fixes the problem).
> 
> Does this mean you have not set one up yourself, or does it mean that
> you have checked no other software is setting up a soft-limited memcg?

Right, I've done nothing other than install and boot.  As far as I can
tell from /sys/fs/cgroup/memory, nothing is defined other than the
standard limits.

> Right now, I still don't see how we could enter the problematic path
> without one memcg exceeding its soft limit.

Yes, that's what we all think too.  The limit is way above my memory
size, though.

> So if you have not done this yet, can you check the cgroup fs for
> memcgs, their memory.soft_limit_in_bytes and .usage_in_bytes right
> before you would run the workload that reproduces the problem?

Sure ... I've got the entire contents at the bottom.

> > > curious as well. if we have workload to reproduce it, i would like to try
> > 
> > Well, the only one I can suggest is the one that produces it (large
> > untar).  There seems to be something magical about the memory size (mine
> > is 2G) because adding more also seems to make the problem go away.
> 
> I'll try to reproduce this on my F15 as well.

It's an SMP kernel (The core i5 Lenovo laptop has two cores with two
threads).  Turning on PREEMPT makes the hang go away, but still causes
kswapd to loop.

James

---

]# for f in *; do echo -e "$f\t"; cat $f;done
cgroup.clone_children
0
cgroup.event_control
cat: cgroup.event_control: Invalid argument
cgroup.procs
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
49
50
51
52
53
54
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
335
339
352
370
371
408
409
415
427
431
443
613
614
679
690
704
732
758
759
775
799
800
825
840
849
851
865
866
890
948
964
997
1000
1037
memory.failcnt
0
memory.force_empty
cat: memory.force_empty: Invalid argument
memory.limit_in_bytes
9223372036854775807
memory.max_usage_in_bytes
0
memory.move_charge_at_immigrate
0
memory.oom_control
oom_kill_disable 0
under_oom 0
memory.soft_limit_in_bytes
9223372036854775807
memory.stat
cache 68370432
rss 34246656
mapped_file 6008832
pgpgin 132627
pgpgout 107574
inactive_anon 6766592
active_anon 34226176
inactive_file 45350912
active_file 16228352
unevictable 0
hierarchical_memory_limit 9223372036854775807
total_cache 68370432
total_rss 34246656
total_mapped_file 6008832
total_pgpgin 132627
total_pgpgout 107574
total_inactive_anon 6766592
total_active_anon 34226176
total_inactive_file 45350912
total_active_file 16228352
total_unevictable 0
memory.swappiness
60
memory.usage_in_bytes
102617088
memory.use_hierarchy
0
notify_on_release
0
release_agent

tasks
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
49
50
51
52
53
54
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
335
339
352
370
371
408
409
415
427
431
443
613
614
679
690
704
732
758
759
775
799
800
825
840
849
851
865
866
890
891
948
964
997
1000
1051
