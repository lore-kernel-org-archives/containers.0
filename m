From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4/5] blk-throttle: track buffered and anonymous pages
Date: Wed, 23 Feb 2011 00:03:54 +0100
Message-ID: <20110222230353.GC23723__40328.7506349899$1298415972$gmane$org@linux.develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-5-git-send-email-arighi@develer.com>
	<AANLkTinD2ZH3hw_iqVpvMjMRbUkXMBgttjd2NevvYq9x@mail.gmail.com>
	<20110222204928.GH28269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110222204928.GH28269-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Chad Talbott <ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 22, 2011 at 03:49:28PM -0500, Vivek Goyal wrote:
> On Tue, Feb 22, 2011 at 10:42:41AM -0800, Chad Talbott wrote:
> > On Tue, Feb 22, 2011 at 9:12 AM, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrot=
e:
> > > Add the tracking of buffered (writeback) and anonymous pages.
> > ...
> > > ---
> > > =A0block/blk-throttle.c =A0 | =A0 87 ++++++++++++++++++++++++++++++++=
+++++++++++++++-
> > > =A0include/linux/blkdev.h | =A0 26 ++++++++++++++-
> > > =A02 files changed, 111 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/block/blk-throttle.c b/block/blk-throttle.c
> > > index 9ad3d1e..a50ee04 100644
> > > --- a/block/blk-throttle.c
> > > +++ b/block/blk-throttle.c
> > ...
> > > +int blk_throtl_set_anonpage_owner(struct page *page, struct mm_struc=
t *mm)
> > > +int blk_throtl_set_filepage_owner(struct page *page, struct mm_struc=
t *mm)
> > > +int blk_throtl_copy_page_owner(struct page *npage, struct page *opag=
e)
> > =

> > It would be nice if these were named blk_cgroup_*.  This is arguably
> > more correct as the id comes from the blkio subsystem, and isn't
> > specific to blk-throttle.  This will be more important very shortly,
> > as CFQ will be using this same cgroup id for async IO tracking soon.
> =

> Should this really be all part of blk-cgroup.c and not blk-throttle.c
> so that it can be used by CFQ code also down the line? Anyway all this
> is not throttle specific as such but blkio controller specific.

Agreed.

> =

> Though function naming convetion is not great in blk-cgroup.c But
> functions either have blkio_ prefix or blkiocg_ prefix.

ok.

> =

> Functions which are not directly dealing with cgroups or in general
> are called by blk-throttle.c and/or cfq-iosched.c I have marked as
> prefixed with "blkio_". Functions which directly deal with cgroup stuff
> and register with cgroup subsystem for this controller are generally
> having "blkiocg_" prefix.
> =

> In this case probably we can use probably blkio_ prefix.

ok.

Thanks,
-Andrea
