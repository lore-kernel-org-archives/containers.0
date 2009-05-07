From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Fri, 8 May 2009 00:19:01 +0200
Message-ID: <20090507221900.GA29774__7736.17012096128$1241735288$gmane$org@linux>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<20090506023332.GA1212@redhat.com>
	<20090506203228.GH8180@redhat.com> <20090506213453.GC4282@linux>
	<20090506215235.GJ8180@redhat.com> <20090507090450.GA4613@linux>
	<20090507141126.GA9463@redhat.com>
	<20090507144501.GB9463@redhat.com>
	<20090507153642.GC9463@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090507153642.GC9463-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 07, 2009 at 11:36:42AM -0400, Vivek Goyal wrote:
> Hmm.., my old config had "AS" as default scheduler that's why I was seeing
> the strange issue of RT task finishing after BE. My apologies for that. I
> somehow assumed that CFQ is default scheduler in my config.

ok.

> 
> So I have re-run the test to see if we are still seeing the issue of
> loosing priority and class with-in cgroup. And we still do..
> 
> 2.6.30-rc4 with io-throttle patches
> ===================================
> Test1
> =====
> - Two readers, one BE prio 0 and other BE prio 7 in a cgroup limited with
>   8MB/s BW.
> 
> 234179072 bytes (234 MB) copied, 55.8448 s, 4.2 MB/s
> prio 0 task finished
> 234179072 bytes (234 MB) copied, 55.8878 s, 4.2 MB/s
> 
> Test2
> =====
> - Two readers, one RT prio 0 and other BE prio 7 in a cgroup limited with
>   8MB/s BW.
> 
> 234179072 bytes (234 MB) copied, 55.8876 s, 4.2 MB/s
> 234179072 bytes (234 MB) copied, 55.8984 s, 4.2 MB/s
> RT task finished

ok, coherent with the current io-throttle implementation.

> 
> Test3
> =====
> - Reader Starvation
> - I created a cgroup with BW limit of 64MB/s. First I just run the reader
>   alone and then I run reader along with 4 writers 4 times. 
> 
> Reader alone
> 234179072 bytes (234 MB) copied, 3.71796 s, 63.0 MB/s
> 
> Reader with 4 writers
> ---------------------
> First run
> 234179072 bytes (234 MB) copied, 30.394 s, 7.7 MB/s 
> 
> Second run
> 234179072 bytes (234 MB) copied, 26.9607 s, 8.7 MB/s
> 
> Third run
> 234179072 bytes (234 MB) copied, 37.3515 s, 6.3 MB/s
> 
> Fourth run
> 234179072 bytes (234 MB) copied, 36.817 s, 6.4 MB/s
> 
> Note that out of 64MB/s limit of this cgroup, reader does not get even
> 1/5 of the BW. In normal systems, readers are advantaged and reader gets
> its job done much faster even in presence of multiple writers.   

And this is also coherent. The throttling is equally probable for read
and write. But this shouldn't happen if we saturate the physical disk BW
(doing proportional BW control or using a watermark close to 100 in
io-throttle). In this case IO scheduler logic shouldn't be totally
broken.

Doing a very quick test with io-throttle, using a 10MB/s BW limit and
blockio.watermark=90:

Launching reader
256+0 records in
256+0 records out
268435456 bytes (268 MB) copied, 32.2798 s, 8.3 MB/s

In the same time the writers wrote ~190MB, so the single reader got
about 1/3 of the total BW.

182M testzerofile4
198M testzerofile1
188M testzerofile3
189M testzerofile2

Things are probably better with many cgroups, many readers and writers
and in general the disk BW more saturated.

Proportional BW approach wins in this case, because if you always use
the whole disk BW the logic of the IO scheduler is still valid.

> 
> Vanilla 2.6.30-rc4
> ==================
> 
> Test3
> =====
> Reader alone
> 234179072 bytes (234 MB) copied, 2.52195 s, 92.9 MB/s
> 
> Reader with 4 writers
> ---------------------
> First run
> 234179072 bytes (234 MB) copied, 4.39929 s, 53.2 MB/s
> 
> Second run
> 234179072 bytes (234 MB) copied, 4.55929 s, 51.4 MB/s
> 
> Third run
> 234179072 bytes (234 MB) copied, 4.79855 s, 48.8 MB/s
> 
> Fourth run
> 234179072 bytes (234 MB) copied, 4.5069 s, 52.0 MB/s
> 
> Notice, that without any writers we seem to be having BW of 92MB/s and
> more than 50% of that BW is still assigned to reader in presence of
> writers. Compare this with io-throttle cgroup of 64MB/s where reader
> struggles to get 10-15% of BW. 
> 
> So any 2nd level control will break the notion and assumptions of
> underlying IO scheduler. We should probably do control at IO scheduler
> level to make sure we don't run into such issues while getting
> hierarchical fair share for groups.
> 
> Thanks
> Vivek
> 

What are the results with your IO scheduler controller (if you already
have them, otherwise I'll repeat this test in my system)? It seems a
very interesting test to compare the advantages of the IO scheduler
solution respect to the io-throttle approach.

Thanks,
-Andrea

> > So now we are left with the issue of loosing the notion of priority and
> > class with-in cgroup. In fact on bigger systems we will probably run into > issues of kiothrottled scalability as single thread is trying to cater to
> > all the disks.
> > 
> > If we do max bw control at IO scheduler level, then I think we should be able
> > to control max bw while maintaining the notion of priority and class with-in
> > cgroup. Also there are multiple pdflush threads and jens seems to be pushing
> > flusher threads per bdi which will help us achieve greater scalability and
> > don't have to replicate that infrastructure for kiothrottled also.
> > 
> > Thanks
> > Vivek
