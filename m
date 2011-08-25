From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v2
Date: Thu, 25 Aug 2011 21:36:42 +0400
Message-ID: <20110825173642.GA3288@albatros>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110825082944.GH10030@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 12:29 +0400, Cyrill Gorcunov wrote:
> +static struct dentry *proc_map_files_lookup(struct inode *dir,
> +		struct dentry *dentry, struct nameidata *nd)
> +{
> +	struct task_struct *task;
> +	unsigned long vm_start;
> +	struct vm_area_struct *vma;
> +	struct map_files_info info;
> +	struct mm_struct *mm;
> +	struct dentry *result;
> +	char *endp;
> +
> +	result = ERR_PTR(-ENOENT);
> +	task = get_proc_task(dir);
> +	if (!task)
> +		goto out_no_task;
> +
> +	result = ERR_PTR(-EPERM);
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ));
> +		goto out_no_mm;

Probably

    result = ERR_PTR(-ENOENT);

belongs here?

> +	vm_start = simple_strtoul(dentry->d_name.name, &endp, 16);
> +	if (*endp != '\0')
> +		goto out_no_mm;
> +
> +	mm = get_task_mm(task);
> +	if (!mm)
> +		goto out_no_mm;
> +
> +	down_read(&mm->mmap_sem);
> +	vma = find_exact_vma(mm, vm_start);
> +	if (!vma)
> +		goto out_no_vma;
> +
> +	memset(&info, 0, sizeof(info));
> +	info.file	= vma->vm_file;
> +	info.vm_start	= vm_start;
> +
> +	result = proc_map_files_instantiate(dir, dentry, task, &info);
> +
> +out_no_vma:
> +	up_read(&mm->mmap_sem);
> +	mmput(mm);
> +out_no_mm:
> +	put_task_struct(task);
> +out_no_task:
> +	return result;
> +}

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
