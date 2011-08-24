From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v2
Date: Wed, 24 Aug 2011 15:18:06 +0400
Message-ID: <20110824111806.GA7191@albatros>
References: <20110824085329.GL29452@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110824085329.GL29452@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Hi Cyrill,

On Wed, Aug 24, 2011 at 12:53 +0400, Cyrill Gorcunov wrote:
> +static struct dentry *proc_map_files_lookup(struct inode *dir,
> +		struct dentry *dentry, struct nameidata *nd)
> +{
> +	struct task_struct *task;
> +	unsigned long vm_start;
> +	struct vm_area_struct *vma;
> +	struct mm_struct *mm;
> +	struct dentry *result;
> +	char *endp;
> +
> +	result = ERR_PTR(-ENOENT);
> +
> +	task = get_proc_task(dir);
> +	if (!task)
> +		goto out_no_task;
> +
> +	vm_start = simple_strtoul(dentry->d_name.name, &endp, 16);
> +	if (*endp != '\0')
> +		goto out_no_mm;
> +
> +	mm = get_task_mm(task);
> +	if (!mm)
> +		goto out_no_mm;
> +
> +	down_read(&mm->mmap_sem);
> +	vma = find_vma(mm, vm_start);
> +	if (!vma || vma->vm_start != vm_start)
> +		goto out_no_vma;
> +	result = proc_map_files_instantiate(dir, dentry, task, vma);
> +
> +out_no_vma:
> +	up_read(&mm->mmap_sem);
> +	mmput(mm);
> +out_no_mm:
> +	put_task_struct(task);
> +out_no_task:
> +	return result;
> +}

You have no ptrace_may_access() check in ->lookup(), only in ->readdir().

> +static const struct inode_operations proc_map_files_inode_operations = {
> +	.lookup		= proc_map_files_lookup,
> +	.setattr	= proc_setattr,
> +};
> +
> +static int proc_map_files_readdir(struct file *filp, void *dirent, filldir_t filldir)
> +{
...
> +	ret = -EPERM;
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ))
> +		goto out;
...
> +	}

Thanks,

-- 
Vasiliy
