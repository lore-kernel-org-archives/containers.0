From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup: move the one-off opts sanity check in
	cgroup_root_from_opts() to parse_cgroupfs_options()
Date: Wed, 29 Jan 2014 12:02:44 +0800
Message-ID: <52E87D64.30800@huawei.com>
References: <1390923125-4369-1-git-send-email-tj@kernel.org>
	<1390923125-4369-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390923125-4369-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On 2014/1/28 23:32, Tejun Heo wrote:
> cgroup_root_from_opts() checks whether (!opts->subsys_mask &&
> !opts->none) and returns NULL if so.  After that, if allocation fails,
> returns ERR_PTR(-ENOMEM).  The caller, cgroup_mount(), doesn't treat
> NULL as an error but set opts.new_root to NULL; however, later on,
> cgroup_set_super() fails with -EINVAL if new_root is NULL.

This patch changes mount semantics.

If cgroup_root_from_opts() returns NULL, it means we should be looking
for existing superblock only.

This will fail:

  # mount -t cgroup -o name=abc xxx /mnt

But this is ok:

  # mount -t cgroup -o none,name=abc xxx /mnt
  # mkdir /mnt/sub
  # umount /mnt
  # mount -t cgroup -o name=abc xxx /mnt   <-- this won't work with your patch

> 
> This is one bizarre error handling sequence especially when all other
> opts sanity checks including the very close (!opts->subsys_mask &&
> !opts->name) check are done in parse_cgroupfs_options().
> 
> Let's move the one-off check in cgroup_root_from_opts() to
> parse_cgroupfs_options() where it can be combined with the
> (!opts->subsys_mask && !opts->name) check.  cgroup_root_from_opts() is
> updated to return NULL on memory allocation failure.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
