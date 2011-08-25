From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 19:01:47 +0200
Message-ID: <20110825170147.GM2803@mtj.dyndns.org>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110825082944.GH10030@sun>
Sender: linux-kernel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

Hello,

On Thu, Aug 25, 2011 at 12:29:44PM +0400, Cyrill Gorcunov wrote:
>  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73a00000 -> /lib64/ld-2.5.so
>  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73c1b000 -> /lib64/ld-2.5.so
>  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73c1c000 -> /lib64/ld-2.5.so
>  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73e00000 -> /lib64/libc-2.5.so
>  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73f4e000 -> /lib64/libc-2.5.so

I would prefer if the filename included both start and end addresses
so that it matches the first column of /proc/PID/maps and ls'ing the
directory is more useful.  What do other people think?

> +static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
> +{
> +	struct task_struct *task;
> +	struct vm_area_struct *vma;
> +	struct mm_struct *mm;
> +	struct inode *inode;
> +
> +	if (nd && nd->flags & LOOKUP_RCU)
> +		return -ECHILD;
> +
> +	inode = dentry->d_inode;
> +	task = get_proc_task(inode);
> +	if (!task)
> +		goto out;
> +
> +	mm = get_task_mm(task);
> +	put_task_struct(task);
> +	if (!mm)
> +		goto out;
> +
> +	down_read(&mm->mmap_sem);
> +	vma = find_exact_vma(mm, PROC_I(inode)->vm_start);
> +	up_read(&mm->mmap_sem);
> +	mmput(mm);
> +
> +	if (vma)
> +		return 1;

Hmm... don't we need the same credential update as
tid_fd_revalidate()?  If the task seteuid's, we want the permissions
to change accordingly, right?

Thanks.

-- 
tejun
