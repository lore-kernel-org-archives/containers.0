From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/5] page_cgroup: make page tracking available for blkio
Date: Tue, 22 Feb 2011 16:57:20 -0500
Message-ID: <20110222215720.GK28269__20352.6815319949$1298412223$gmane$org@redhat.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-4-git-send-email-arighi@develer.com>
	<20110222130145.37cb151e@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110222130145.37cb151e-vw3g6Xz/EtPk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 22, 2011 at 01:01:45PM -0700, Jonathan Corbet wrote:
> On Tue, 22 Feb 2011 18:12:54 +0100
> Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > The page_cgroup infrastructure, currently available only for the memory
> > cgroup controller, can be used to store the owner of each page and
> > opportunely track the writeback IO. This information is encoded in
> > the upper 16-bits of the page_cgroup->flags.
> > 
> > A owner can be identified using a generic ID number and the following
> > interfaces are provided to store a retrieve this information:
> > 
> >   unsigned long page_cgroup_get_owner(struct page *page);
> >   int page_cgroup_set_owner(struct page *page, unsigned long id);
> >   int page_cgroup_copy_owner(struct page *npage, struct page *opage);
> 
> My immediate observation is that you're not really tracking the "owner"
> here - you're tracking an opaque 16-bit token known only to the block
> controller in a field which - if changed by anybody other than the block
> controller - will lead to mayhem in the block controller.  I think it
> might be clearer - and safer - to say "blkcg" or some such instead of
> "owner" here.
> 
> I'm tempted to say it might be better to just add a pointer to your
> throtl_grp structure into struct page_cgroup.

throtl_grp might not even be present when page is being dirtied. When this
IO is actually submitted to device, we migth end up creating new
throtl_grp. I guess other concern here would be increasing the size of
page_cgroup structure.

I guess you meant storing a pointer to blkio_cgroup, along the lines of
storing a pointer to mem_cgroup. That also means extra 8 bytes and only
one subsystem can use it at a time. So using upper bits of pc->flags
is probably better.

> Or maybe replace the
> mem_cgroup pointer with a single pointer to struct css_set.  Both of
> those ideas, though, probably just add unwanted extra overhead now to gain
> generality which may or may not be wanted in the future.

This sounds interesting. IIUC, then this single pointer will allow all
the subsystems to use this single pointer to retireve respective cgroups
without actually co-mounting them. 

I am not sure how much work is involved in making it happen. Also not sure
about the overhead involved in traversing one extra pointer. Also apart
from blkio controller, have we practically felt the need of any other
controller this info. (network controller?). Few days back we were
experimenting with trying to control block IO bandwidth over NFS with 
the help of network controller but it did not really work well with
host of issues and one them being losing the context information.

If storing css_set pointer is lot of work, may be for the time being
we can go for this hardcoding that these bits are exclusively used
by blkio controller and once some other controller wants to share it,
then look for ways of how to do sharing.

Thanks
Vivek
