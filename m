From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.15] cgroup: more cleanups
Date: Thu, 13 Feb 2014 10:01:59 +0800
Message-ID: <52FC2797.90502@huawei.com>
References: <1391953964-22088-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391953964-22088-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2014/2/9 21:52, Tejun Heo wrote:
> Hello,
> 
> This series contains assorted cleanups which also prepare for the
> planned migration taskset handling update.
> 
> This patchset contains the following sixteen patches.
> 
>  0001-cgroup-disallow-xattr-release_agent-and-name-if-sane.patch
>  0002-cgroup-drop-CGRP_ROOT_SUBSYS_BOUND.patch
>  0003-cgroup-enable-task_cg_lists-on-the-first-cgroup-moun.patch
>  0004-cgroup-relocate-cgroup_enable_task_cg_lists.patch
>  0005-cgroup-implement-cgroup_has_tasks-and-unexport-cgrou.patch
>  0006-cgroup-reimplement-cgroup_transfer_tasks-without-usi.patch
>  0007-cgroup-make-css_set_lock-a-rwsem-and-rename-it-to-cs.patch
>  0008-cpuset-use-css_task_iter_start-next-end-instead-of-c.patch
>  0009-cgroup-remove-css_scan_tasks.patch
>  0010-cgroup-separate-out-put_css_set_locked-and-remove-pu.patch
>  0011-cgroup-move-css_set_rwsem-locking-outside-of-cgroup_.patch
>  0012-cgroup-drop-skip_css-from-cgroup_taskset_for_each.patch
>  0013-cpuset-don-t-use-cgroup_taskset_cur_css.patch
>  0014-cgroup-remove-cgroup_taskset_cur_css-and-cgroup_task.patch
>  0015-cgroup-cosmetic-updates-to-cgroup_attach_task.patch
>  0016-cgroup-unexport-functions.patch
> 
> The notables ones are
> 
>  0003-0004 move task_cg_list enabling to the first mount instead of
>  the first css task iteration.
> 
>  0005-0009 make css_set_lock a rwsem so that css_task_iter allows
>  blocking during iteration and removes css_scan_tasks().
> 
>  0010-0015 clean up migration path to prepare for the planned
>  migration taskset handling update.
> 

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
