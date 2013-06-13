From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET v2 cgroup/for-3.11] cgroup: convert
	cgroup_subsys_state refcnt to percpu_ref
Date: Thu, 13 Jun 2013 10:56:27 -0700
Message-ID: <20130613175627.GC10799__4057.63266976482$1371146203$gmane$org@mtj.dyndns.org>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
	<51B960FF.7070604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51B960FF.7070604-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jun 13, 2013 at 02:04:47PM +0800, Li Zefan wrote:
> >  0001-cgroup-remove-now-unused-css_depth.patch
> >  0002-cgroup-consistently-use-cset-for-struct-css_set-vari.patch
> >  0003-cgroup-bring-some-sanity-to-naming-around-cg_cgroup_.patch
> >  0004-cgroup-use-kzalloc-instead-of-kmalloc.patch
> >  0005-cgroup-clean-up-css_-try-get-and-css_put.patch
> >  0006-cgroup-rename-CGRP_REMOVED-to-CGRP_DEAD.patch
> >  0007-cgroup-drop-unnecessary-RCU-dancing-from-__put_css_s.patch
> >  0008-cgroup-remove-cgroup-count-and-use.patch
> >  0009-cgroup-reorder-the-operations-in-cgroup_destroy_lock.patch
> >  0010-cgroup-split-cgroup-destruction-into-two-steps.patch
> >  0011-cgroup-use-percpu-refcnt-for-cgroup_subsys_states.patch
> 
> Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Applied 0001-0008 to cgroup/for-3.11.  Will apply the reset once the
percpu-refcount side is settled.

Thanks!

-- 
tejun
