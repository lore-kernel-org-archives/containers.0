From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO scheduler based IO controller V4
Date: Tue, 9 Jun 2009 09:52:56 -0400
Message-ID: <20090609135256.GA13476__45190.7689836391$1244555740$gmane$org@redhat.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
	<4A2DE381.6090205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A2DE381.6090205-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 09, 2009 at 12:22:25PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> > Hi All,
> > 
> > Here is the V4 of the IO controller patches generated on top of 2.6.30-rc8.
> > 
> 
> Hi Vivek,
> 
> I can't apply the patchset.
> 
> [root@localhost linux-2.6.30-rc8-Vivek-V4]# git-am ../V4/1.eml
> Applying io-controller: Documentation
> [root@localhost linux-2.6.30-rc8-Vivek-V4]# git-am ../V4/2.eml
> Applying io-controller: Common flat fair queuing code in elevaotor layer
> error: patch failed: block/Makefile:15
> error: block/Makefile: patch does not apply
> Patch failed at 0001.
> When you have resolved this problem run "git-am --resolved".
> If you would prefer to skip this patch, instead run "git-am --skip".

Hi Gui,

This is strange. It seems to be applying cleanly for me. Can you please
recheck your setup and also see why it is failing. In block/Makefile,
there is one line change and recently no change has taken to that file
in git.

Thanks
Vivek

[vgoyal@machine linux-2.6]$ git-am /tmp/V4/ioc-v4 
Applying: io-controller: Documentation
Applying: io-controller: Common flat fair queuing code in elevaotor layer
Applying: io-controller: Charge for time slice based on average disk rate
Applying: io-controller: Modify cfq to make use of flat elevator fair
queuing
Applying: io-controller: Common hierarchical fair queuing code in
elevaotor layer
Applying: io-controller: cfq changes to use hierarchical fair queuing code
in elevaotor layer
Applying: io-controller: Export disk time used and nr sectors dipatched
through cgroups
Applying: io-controller: idle for sometime on sync queue before expiring
it
Applying: io-controller: Separate out queue and data
Applying: io-conroller: Prepare elevator layer for single queue schedulers
Applying: io-controller: noop changes for hierarchical fair queuing
Applying: io-controller: deadline changes for hierarchical fair queuing
Applying: io-controller: anticipatory changes for hierarchical fair
queuing
Applying: blkio_cgroup patches from Ryo to track async bios.
Applying: io-controller: map async requests to appropriate cgroup
Applying: io-controller: Per cgroup request descriptor support
Applying: io-controller: Support per cgroup per device weights and io
class
Applying: io-controller: Debug hierarchical IO scheduling
Applying: io-controller: experimental debug patch for async queue wait
before expiry
