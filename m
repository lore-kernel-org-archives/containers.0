From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Fri, 26 Aug 2011 16:06:20 +0200
Message-ID: <20110826140620.GE2632@htj.dyndns.org>
References: <20110825082944.GH10030@sun>
 <20110825170147.GM2803@mtj.dyndns.org>
 <20110825170705.GA6387@sun>
 <20110825205426.GO2803@mtj.dyndns.org>
 <20110825211213.GP2803@mtj.dyndns.org>
 <20110825213459.GA1929@sun>
 <20110825213931.GR2803@mtj.dyndns.org>
 <20110826112943.GI3903@sun>
 <20110826122851.GA25853@shutemov.name>
 <20110826131620.GM3903@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110826131620.GM3903@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, containers@lists.osdl.org, Andi Kleen <andi@firstfloor.org>, Nathan Lynch <ntl@pobox.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Vasiliy Kulikov <segoon@openwall.com>
List-Id: containers.vger.kernel.org

Hello, Cyrill.

On Fri, Aug 26, 2011 at 05:16:20PM +0400, Cyrill Gorcunov wrote:
> Index: linux-2.6.git/fs/proc/base.c
> ===================================================================
> --- linux-2.6.git.orig/fs/proc/base.c
> +++ linux-2.6.git/fs/proc/base.c
> @@ -165,7 +165,7 @@ static int get_task_root(struct task_str
>  	return result;
>  }
>  
> -static int proc_cwd_link(struct inode *inode, struct path *path)
> +static int proc_cwd_link(struct dentry *dentry, struct inode *inode, struct path *path)

I don't think it's necessary to pass around both @dentry and @inode.
@inode can always be dereferenced from @dentry.

> +static int map_name_to_addr(const unsigned char *name, unsigned long *start, unsigned long *end)
> +{
> +	int ret = -1;

Very minor but functions returning -1 for error bugs me a bit.  Maybe
-EINVAL is better?  Not a big deal either way.

> +static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
> +{
...
> +	if (vma) {
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

Another minor point.  Maybe it would be nice to factor this into a
function and share it w/ the fd one (and maybe sprinkle some comments
while at it too :)

> +struct map_files_info {
> +	struct file	*file;
> +	unsigned char	name[16+16+2]; /* max: %016lx-%016lx\0 */
> +	unsigned long	len;
> +};

That's slightly above 50 bytes.

> +static struct dentry *proc_map_files_lookup(struct inode *dir,
> +		struct dentry *dentry, struct nameidata *nd)
> +{
> +	unsigned long vm_start, vm_end;
> +	struct task_struct *task;
> +	struct vm_area_struct *vma;
> +	struct mm_struct *mm;
> +	struct dentry *result;
> +
> +	result = ERR_PTR(-ENOENT);
> +	task = get_proc_task(dir);
> +	if (!task)
> +		goto out_no_task;
> +
> +	result = ERR_PTR(-EPERM);
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ));
> +		goto out_no_mm;
> +
> +	result = ERR_PTR(-ENOENT);
> +	if (map_name_to_addr(dentry->d_name.name,
> +			     &vm_start, &vm_end))
> +		goto out_no_mm;

Another nitpick: Maybe factor out the above three steps?

> +static int proc_map_files_readdir(struct file *filp, void *dirent, filldir_t filldir)
> +{
...
> +		if (nr_files) {
> +			info = kmalloc(nr_files * sizeof(*info), GFP_KERNEL);

I think we can just put this on stack.

All my comments are pretty cosmetic, so it generally looks good to me.
Andrew, what do you think?

Thanks.

-- 
tejun
