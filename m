From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.12] cgroup: decouple cgroup_subsys_state
	lifetime from that of cgroup
Date: Tue, 13 Aug 2013 09:19:06 +0800
Message-ID: <5209898A.6040304@huawei.com>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On 2013/8/9 4:13, Tejun Heo wrote:
> Hello,
> 
> Currently a css's (cgroup_subsys_state) lifetime is tied to that of
> the cgroup it's attached to.  css's are created when the cgroup is
> created and destroyed together.  The access rules depend on it too -
> e.g. css's can be dereferenced while holding RCU read lock because
> cgroup is protected with RCU.
> 
> With the planned unified hierarchy, we'll be dynamically creating and
> destroying css's through the lifetime of a cgroup, so we can no longer
> hitch css lifetime management onto cgroup's.  This patchset separates
> out css lifetime management from that of cgroup.  After the patchset,
> each css is individually RCU protected.
> 
> This patchset contains the following 14 patches.
> 
>  0001-cgroup-always-use-cgroup_css.patch
>  0002-cgroup-rename-cgroup_subsys_state-dput_work-and-its-.patch
>  0003-cgroup-add-cgroup_subsys_state-parent.patch
>  0004-cgroup-cgroup_css_from_dir-now-should-be-called-with.patch
>  0005-cgroup-make-cgroup_file_open-rcu_read_lock-around-cg.patch
>  0006-cgroup-add-__rcu-modifier-to-cgroup-subsys.patch
>  0007-cgroup-reorganize-css-init-exit-paths.patch
>  0008-cgroup-move-cgroup-subsys-assignment-to-online_css.patch
>  0009-cgroup-bounce-cgroup_subsys_state-ref-kill-confirmat.patch
>  0010-cgroup-replace-cgroup-css_kill_cnt-with-nr_css.patch
>  0011-cgroup-decouple-cgroup_subsys_state-destruction-from.patch
>  0012-cgroup-factor-out-kill_css.patch
>  0013-cgroup-move-subsys-file-removal-to-kill_css.patch
>  0014-cgroup-RCU-protect-each-cgroup_subsys_state-release.patch
> 

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
