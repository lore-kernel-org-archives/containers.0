From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v4 0/4] cgroups: support for module-loadable subsystems
Date: Thu, 7 Jan 2010 02:48:12 -0500
Message-ID: <20100107074812.GA16656__39514.4616523341$1262851100$gmane$org@andrew.cmu.edu>
References: <20091231051050.GA714@andrew.cmu.edu>
	<20100106160414.bd555474.akpm@linux-foundation.org>
	<20100107012606.GA25577@andrew.cmu.edu>
	<20100107120732.97d502bd.kamezawa.hiroyu@jp.fujitsu.com>
	<4B45824B.9030108@cn.fujitsu.com>
	<20100107161627.34b31e0c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100107161627.34b31e0c.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jan 07, 2010 at 04:16:27PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 07 Jan 2010 14:42:19 +0800
> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 
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
> > 
> 
> Hmm, I read the patch slightly. I'm not enough expert to review this patch..
> 
> I requst following as TODO.
> (No objection to the direction/patch.)
> 
>  1. Add documentation about load/unlod module.

could perhaps use more, i suppose.

>    It seems module unloading will not succuess while subsystem is mounted.
>    Right ?

yes, when you mount it, it takes a reference on the module, so you get
"module is in use".

>  2. Making this to be reasonable value.
> #define CGROUP_SUBSYS_COUNT (BITS_PER_BYTE*sizeof(unsigned long))
>    I can't find why.

"We limit to this many since cgroupfs_root has subsys_bits to keep track
of all of them." should it be less, perhaps? the memory footprint is not
great, it is true, but implementing dynamically sized subsystem tracking
data structures requires much cleverer code in many places.

>  3. show whehter a subsys is a loadable module or not via /proc/cgroups

with just "y" or "n"? possible, and probably easy. do note that since
they are sorted by subsys_id, all the ones above a certain line will be
"n" and all below will be "y".

>  4. how to test ? load/unload NET_CLS is enough ?

load, mount, remount, unmount, mount with different combinations, unload
was the general approach I took, plus using gdb to examine state.

> 
> Last one is question.
> 
>  5. Is following path is safe ?
> 
>     find_css_set() {
>      ....
>           read_lock(&css_set_lock);
>           get template including pointer
>           read_unlock(&css_set_lock);
> 
>           use template to build new css_set.

should be, because that code is dealing with a cgrp's/css's specific
->subsys array, which state is protected by refcounts held by the
already mounted hierarchy, and the other entries in the array are not
cared about by the particular css in question.

> 
> 
> Thanks,
> -Kame
> 
> 
> 
