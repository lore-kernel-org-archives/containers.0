From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.12] cgroup: factor out css creation into
	create_css()
Date: Thu, 5 Sep 2013 11:24:57 +0800
Message-ID: <5227F989.10907@huawei.com>
References: <1377723829-22814-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377723829-22814-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On 2013/8/29 5:03, Tejun Heo wrote:
> Hello,
> 
> For unified hierarchy, a css's (cgroup_subsys_state) lifetime will be
> different from that of the associated cgroup.  css's may be created
> and destroyed dynamically over the lifetime of a single cgroup.  The
> previous changes decoupled css destruction from cgroup's.  This
> patchset decouples css creation from cgroup's.
> 
> This patchset contains the following nine patches.
> 
>  0001-cgroup-fix-css-leaks-on-online_css-failure.patch
>  0002-cgroup-css-iterations-and-css_from_dir-are-safe-unde.patch
>  0003-cgroup-make-for_each_subsys-useable-under-cgroup_roo.patch
>  0004-cgroup-move-css_id-commit-from-cgroup_populate_dir-t.patch
>  0005-cgroup-reorder-operations-in-cgroup_create.patch
>  0006-cgroup-combine-css-handling-loops-in-cgroup_create.patch
>  0007-cgroup-factor-out-cgroup_subsys_state-creation-into-.patch
>  0008-cgroup-implement-for_each_css.patch
>  0009-cgroup-remove-for_each_root_subsys.patch
> 

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
