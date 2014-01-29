From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET v2 cgroup/for-3.15] cgroup: drop module support and
	cgroup_root_mutex
Date: Wed, 29 Jan 2014 14:32:38 +0800
Message-ID: <52E8A086.2050103@huawei.com>
References: <1390952641-15950-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390952641-15950-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On 2014/1/29 7:43, Tejun Heo wrote:
> Hello,
> 
> This is the second take.  Changes from the last take[L] are
> 
> * Updated to reflect changes in fe1217c4f3f7 ("net: net_cls: move
>   cgroupfs classid handling into core").
> 
> * Rebased on top of the current linus#master + some cgroup fix
>   patches.
> 
> There's only one controller which makes use of the module support -
> net_prio, which, non-coincidentally, isn't an actual resource
> controller.  It's highly unlikely that the actual resource controlling
> controllers are gonna be made modular and we aren't gonna add more
> non-resource controllers either, so the value of module support is
> strictly restricted to the particular controller.
> 
> The controller is fairly simple while module support in cgroup core
> adds quite a bit of complexity.  Building the one controller as module
> only saves less than half-page in vmlinux, which really can't justify
> the additional complexity and (minute but existing) runtime overhead.
> 
> This patchset makes net_prio config options bool so that it can't be
> built as modules and drops module support from cgroup core, which in
> turn facilitates further simplification leading to removal of
> cgroup_root_mutex by allowing iterating subsystems outside the
> mutexes.
> 
> This patchset contains the following six patches.
> 
>  0001-cgroup-make-CONFIG_CGROUP_NET_PRIO-bool-and-drop-unn.patch
>  0002-cgroup-drop-module-support.patch
>  0003-cgroup-clean-up-cgroup_subsys-names-and-initializati.patch
>  0004-cgroup-rename-cgroup_subsys-subsys_id-to-id.patch
>  0005-cgroup-update-locking-in-cgroup_show_options.patch
>  0006-cgroup-remove-cgroup_root_mutex.patch
> 
> 0001-0002 drop cgroup module support.
> 
> 0003-0004 are cleanups.
> 
> 0005-0006 remove cgroup_root_mutex.
> 

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
