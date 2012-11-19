From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/17] cgroup: remove incorrect dget/dput() pair in
	cgroup_create_dir()
Date: Mon, 19 Nov 2012 16:08:04 +0800
Message-ID: <50A9E8E4.4050004__21810.5182088495$1353312534$gmane$org@huawei.com>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
	<1352775704-9023-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012/11/13 11:01, Tejun Heo wrote:
> cgroup_create_dir() does weird dancing with dentry refcnt.  On
> success, it gets and then puts it achieving nothing.  On failure, it
> puts but there isn't no matching get anywhere leading to the following
> oops if cgroup_create_file() fails for whatever reason.
> 
>   ------------[ cut here ]------------
>   kernel BUG at /work/os/work/fs/dcache.c:552!
>   invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>   Modules linked in:
>   CPU 2
>   Pid: 697, comm: mkdir Not tainted 3.7.0-rc4-work+ #3 Bochs Bochs
>   RIP: 0010:[<ffffffff811d9c0c>]  [<ffffffff811d9c0c>] dput+0x1dc/0x1e0
>   RSP: 0018:ffff88001a3ebef8  EFLAGS: 00010246
>   RAX: 0000000000000000 RBX: ffff88000e5b1ef8 RCX: 0000000000000403
>   RDX: 0000000000000303 RSI: 2000000000000000 RDI: ffff88000e5b1f58
>   RBP: ffff88001a3ebf18 R08: ffffffff82c76960 R09: 0000000000000001
>   R10: ffff880015022080 R11: ffd9bed70f48a041 R12: 00000000ffffffea
>   R13: 0000000000000001 R14: ffff88000e5b1f58 R15: 00007fff57656d60
>   FS:  00007ff05fcb3800(0000) GS:ffff88001fd00000(0000) knlGS:0000000000000000
>   CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>   CR2: 00000000004046f0 CR3: 000000001315f000 CR4: 00000000000006e0
>   DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>   DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>   Process mkdir (pid: 697, threadinfo ffff88001a3ea000, task ffff880015022080)
>   Stack:
>    ffff88001a3ebf48 00000000ffffffea 0000000000000001 0000000000000000
>    ffff88001a3ebf38 ffffffff811cc889 0000000000000001 ffff88000e5b1ef8
>    ffff88001a3ebf68 ffffffff811d1fc9 ffff8800198d7f18 ffff880019106ef8
>   Call Trace:
>    [<ffffffff811cc889>] done_path_create+0x19/0x50
>    [<ffffffff811d1fc9>] sys_mkdirat+0x59/0x80
>    [<ffffffff811d2009>] sys_mkdir+0x19/0x20
>    [<ffffffff81be1e02>] system_call_fastpath+0x16/0x1b
>   Code: 00 48 8d 90 18 01 00 00 48 89 93 c0 00 00 00 4c 89 a0 18 01 00 00 48 8b 83 a0 00 00 00 83 80 28 01 00 00 01 e8 e6 6f a0 00 eb 92 <0f> 0b 66 90 0f 1f 44 00 00 55 48 89 e5 41 57 41 56 49 89 fe 41
>   RIP  [<ffffffff811d9c0c>] dput+0x1dc/0x1e0
>    RSP <ffff88001a3ebef8>
>   ---[ end trace 1277bcfd9561ddb0 ]---
> 
> Fix it by dropping the unnecessary dget/dput() pair.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  kernel/cgroup.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 0f8fa6a..d0803f0 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2684,9 +2684,7 @@ static int cgroup_create_dir(struct cgroup *cgrp, struct dentry *dentry,
>  		dentry->d_fsdata = cgrp;
>  		inc_nlink(parent->d_inode);
>  		rcu_assign_pointer(cgrp->dentry, dentry);
> -		dget(dentry);
>  	}
> -	dput(dentry);
>  

The code has been there since cgroup was merged into mainline!

>  	return error;
>  }
> 
