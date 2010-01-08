From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [RFC] [PATCH 1/2] cgroups: modular subsystems support for use_id
Date: Fri, 8 Jan 2010 00:29:07 -0500
Message-ID: <20100108052907.GB13168__3924.08447010002$1262928648$gmane$org@andrew.cmu.edu>
References: <20091231051050.GA714@andrew.cmu.edu>
	<20100106160414.bd555474.akpm@linux-foundation.org>
	<20100107012606.GA25577@andrew.cmu.edu>
	<20100107120732.97d502bd.kamezawa.hiroyu@jp.fujitsu.com>
	<4B45824B.9030108@cn.fujitsu.com>
	<20100108052734.GA13168@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100108052734.GA13168-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers@lists
List-Id: containers.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


On Fri, Jan 08, 2010 at 12:27:34AM -0500, Ben Blum wrote:
> On Thu, Jan 07, 2010 at 02:42:19PM +0800, Li Zefan wrote:
> > KAMEZAWA Hiroyuki wrote:
> > > On Wed, 6 Jan 2010 20:26:06 -0500
> > > Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> > > 
> > >> On Wed, Jan 06, 2010 at 04:04:14PM -0800, Andrew Morton wrote:
> > >>> On Thu, 31 Dec 2009 00:10:50 -0500
> > >>> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> > >>>
> > >>>> This patch series implements support for building, loading, and
> > >>>> unloading subsystems as modules, both within and outside the kernel
> > >>>> source tree. It provides an interface cgroup_load_subsys() and
> > >>>> cgroup_unload_subsys() which modular subsystems can use to register and
> > >>>> depart during runtime. The net_cls classifier subsystem serves as the
> > >>>> example for a subsystem which can be converted into a module using these
> > >>>> changes.
> > >>> What is the value in this?  What are the usage scenarios?  Why does the
> > >>> benefit of this change exceed the cost/risk/etc of merging it?
> > >> As discussed in the first posting of these patches, this provides the
> > >> ability for arbitrary subsystems to be used with cgroups.. cls_cgroup
> > >> would have already been a module except for a lack of support from
> > >> cgroups, and the change also allows other module-loadable classifiers
> > >> to add subsystems of their own.
> > > 
> > > Hmm, do you have your own module in plan ?
> > > 
> > 
> > Maybe the new blkio_cgroup can also be made module-able.
> 
> Ok, the following two patches make this happen (or at least pretend to
> well enough to fool me). The first one adds use_id initialization in
> cgroup_load_subsys, and the second rearranges config options and some
> code as appropriate in block/ and adds EXPORT_SYMBOLs in cgroup.c.
> 
> -- bblum
> 
> ---
>  block/Kconfig             |    2 -
>  block/Kconfig.iosched     |    2 -
>  block/blk-cgroup.c        |   53 +++++++++++++++++++++++++++++++++++-----------
>  block/blk-cgroup.h        |   10 ++++++--
>  include/linux/iocontext.h |    2 -
>  kernel/cgroup.c           |   31 +++++++++++++++++++++-----
>  6 files changed, 77 insertions(+), 23 deletions(-)
> 
> 

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="cgroups-module-use_id-support.patch"

This patch adds support for subsys.use_id in module-loadable subsystems.

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---
 kernel/cgroup.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index cc2e1f6..5af59eb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -240,7 +240,8 @@ struct cg_cgroup_link {
 static struct css_set init_css_set;
 static struct cg_cgroup_link init_css_set_link;
 
-static int cgroup_subsys_init_idr(struct cgroup_subsys *ss);
+static int cgroup_init_idr(struct cgroup_subsys *ss,
+			   struct cgroup_subsys_state *css);
 
 /* css_set_lock protects the list of css_set objects, and the
  * chain of tasks off each css_set.  Nests outside task->alloc_lock
@@ -3390,6 +3391,16 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 		mutex_unlock(&cgroup_mutex);
 		return PTR_ERR(css);
 	}
+	/* call init_idr here because it has a failure case */
+	if (ss->use_id) {
+		int ret = cgroup_init_idr(ss, css);
+		if (ret) {
+			ss->destroy(ss, dummytop);
+			subsys[i] = NULL;
+			mutex_unlock(&cgroup_mutex);
+			return ret;
+		}
+	}
 
 	list_add(&ss->sibling, &rootnode.subsys_list);
 	ss->root = &rootnode;
@@ -3484,7 +3495,8 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	/*
 	 * remove subsystem's css from the dummytop and free it - need to free
 	 * before marking as null because ss->destroy needs the cgrp->subsys
-	 * pointer to find their state.
+	 * pointer to find their state. note that this also takes care of
+	 * freeing the css_id.
 	 */
 	ss->destroy(ss, dummytop);
 	dummytop->subsys[ss->subsys_id] = NULL;
@@ -3563,7 +3575,7 @@ int __init cgroup_init(void)
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
 		if (ss->use_id)
-			cgroup_subsys_init_idr(ss);
+			cgroup_init_idr(ss, init_css_set.subsys[ss->subsys_id]);
 	}
 
 	/* Add init_css_set to the hash table */
@@ -4231,15 +4243,14 @@ err_out:
 
 }
 
-static int __init cgroup_subsys_init_idr(struct cgroup_subsys *ss)
+static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
+					    struct cgroup_subsys_state *rootcss)
 {
 	struct css_id *newid;
-	struct cgroup_subsys_state *rootcss;
 
 	spin_lock_init(&ss->id_lock);
 	idr_init(&ss->idr);
 
-	rootcss = init_css_set.subsys[ss->subsys_id];
 	newid = get_new_cssid(ss, 0);
 	if (IS_ERR(newid))
 		return PTR_ERR(newid);

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--Qxx1br4bt0+wmkIi--
