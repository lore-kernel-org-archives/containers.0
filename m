From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v4 0/4] cgroups: support for module-loadable subsystems
Date: Fri, 8 Jan 2010 00:27:34 -0500
Message-ID: <20100108052734.GA13168__37239.8707936101$1262928583$gmane$org@andrew.cmu.edu>
References: <20091231051050.GA714@andrew.cmu.edu>
	<20100106160414.bd555474.akpm@linux-foundation.org>
	<20100107012606.GA25577@andrew.cmu.edu>
	<20100107120732.97d502bd.kamezawa.hiroyu@jp.fujitsu.com>
	<4B45824B.9030108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B45824B.9030108-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jan 07, 2010 at 02:42:19PM +0800, Li Zefan wrote:
> KAMEZAWA Hiroyuki wrote:
> > On Wed, 6 Jan 2010 20:26:06 -0500
> > Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> > 
> >> On Wed, Jan 06, 2010 at 04:04:14PM -0800, Andrew Morton wrote:
> >>> On Thu, 31 Dec 2009 00:10:50 -0500
> >>> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> >>>
> >>>> This patch series implements support for building, loading, and
> >>>> unloading subsystems as modules, both within and outside the kernel
> >>>> source tree. It provides an interface cgroup_load_subsys() and
> >>>> cgroup_unload_subsys() which modular subsystems can use to register and
> >>>> depart during runtime. The net_cls classifier subsystem serves as the
> >>>> example for a subsystem which can be converted into a module using these
> >>>> changes.
> >>> What is the value in this?  What are the usage scenarios?  Why does the
> >>> benefit of this change exceed the cost/risk/etc of merging it?
> >> As discussed in the first posting of these patches, this provides the
> >> ability for arbitrary subsystems to be used with cgroups.. cls_cgroup
> >> would have already been a module except for a lack of support from
> >> cgroups, and the change also allows other module-loadable classifiers
> >> to add subsystems of their own.
> > 
> > Hmm, do you have your own module in plan ?
> > 
> 
> Maybe the new blkio_cgroup can also be made module-able.

Ok, the following two patches make this happen (or at least pretend to
well enough to fool me). The first one adds use_id initialization in
cgroup_load_subsys, and the second rearranges config options and some
code as appropriate in block/ and adds EXPORT_SYMBOLs in cgroup.c.

-- bblum

---
 block/Kconfig             |    2 -
 block/Kconfig.iosched     |    2 -
 block/blk-cgroup.c        |   53 +++++++++++++++++++++++++++++++++++-----------
 block/blk-cgroup.h        |   10 ++++++--
 include/linux/iocontext.h |    2 -
 kernel/cgroup.c           |   31 +++++++++++++++++++++-----
 6 files changed, 77 insertions(+), 23 deletions(-)
