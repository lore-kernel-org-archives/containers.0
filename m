From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [patch 2/2] fs, proc: Introduce the
 /proc/<pid>/map_files/ directory v6
Date: Sat, 10 Sep 2011 17:21:01 +0400
Message-ID: <20110910132101.GA14535@albatros>
References: <20110906172952.GA28055@albatros>
 <20110906173341.GM18425@mtj.dyndns.org>
 <20110907112301.GA12157@albatros>
 <20110907215329.GB28162@sun>
 <20110907151323.613e62e7.akpm@linux-foundation.org>
 <20110907224234.GD28162@sun>
 <20110907155332.beda7d3d.akpm@linux-foundation.org>
 <20110908054826.GF28162@sun>
 <20110908055025.GG28162@sun>
 <20110908060405.GH28162@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110908060405.GH28162@sun>
Sender: linux-kernel-owner@vger.kernel.org
To: kernel-hardening@lists.openwall.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

Hi Cyrill,

On Thu, Sep 08, 2011 at 10:04 +0400, Cyrill Gorcunov wrote:
> +static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
> +{
> +	unsigned long vm_start, vm_end;
> +	bool exact_vma_exists = false;
> +	struct task_struct *task;
> +	const struct cred *cred;
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
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ))

        put_task_struct(task) belongs here.

> +		goto out;
> +
> +	mm = get_task_mm(task);
> +	put_task_struct(task);
> +	if (!mm)
> +		goto out;
> +
> +	if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
> +		down_read(&mm->mmap_sem);
> +		exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
> +		up_read(&mm->mmap_sem);
> +	}
> +
> +	mmput(mm);
> +
> +	if (exact_vma_exists) {
> +		if (task_dumpable(task)) {
> +			rcu_read_lock();
> +			cred = __task_cred(task);
> +			inode->i_uid = cred->euid;
> +			inode->i_gid = cred->egid;
> +			rcu_read_unlock();
> +		} else {
> +			inode->i_uid = 0;
> +			inode->i_gid = 0;
> +		}
> +		security_task_to_inode(task, inode);
> +		return 1;
> +	}
> +out:
> +	d_drop(dentry);
> +	return 0;
> +}

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
