From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix possible use after free
Date: Tue, 10 Feb 2009 02:15:36 -0800
Message-ID: <6599ad830902100215o185edd31k8731e033717dbb49__14146.9524628066$1234261074$gmane$org@mail.gmail.com>
References: <4991497B.4030200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4991497B.4030200-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 10, 2009 at 1:31 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> In cgroup_kill_sb(), root is freed before sb is detached from the list,
> so another sget() may find this sb and call cgroup_test_super(),
> which will access the root that has been freed.

I think that I'd assumed that by the time we get to cgroup_kill_sb()
there's no chance of the sb being resurrected by sget().

If anyone can call cgroup_test_super() on the sb that we're trying to
free, isn't that bad? Since even with this patch we free root just
after calling kill_litter_sb(), if anyone tries to reuse that super
block then they're toast.

Would it be better to set sb->s_fs_info to NULL, before calling
kill_litter_sb(), and have cgroup_test_super() just return 0 for any
sb with a NULL sb->s_fs_info.

Paul

>
> Reported-by: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 5a54ff4..42fd3f2 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1122,8 +1122,8 @@ static void cgroup_kill_sb(struct super_block *sb) {
>
>        mutex_unlock(&cgroup_mutex);
>
> -       kfree(root);
>        kill_litter_super(sb);
> +       kfree(root);
>  }
>
>  static struct file_system_type cgroup_fs_type = {
> --
> 1.5.4.rc3
>
