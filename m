From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH 10/30] cr: core stuff
Date: Fri, 10 Apr 2009 11:35:20 +0200
Message-ID: <20090410093520.GH17962@elte.hu>
References: <20090410023539.GK27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410023539.GK27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


* Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> +int cr_restore_file(struct cr_context *ctx, loff_t pos)
> +{

I tried to review this code, but it's almost unreadable to me, due 
to basic code structure mistakes like:

> +	struct cr_image_file *i, *tmp;
> +	struct file *file;
> +	struct cr_object *obj;
> +	char *cr_name;
> +	int rv;
> +
> +	i = kzalloc(sizeof(*i), GFP_KERNEL);
> +	if (!i)
> +		return -ENOMEM;
> +	rv = cr_pread(ctx, i, sizeof(*i), pos);
> +	if (rv < 0) {
> +		kfree(i);
> +		return rv;
> +	}
> +	if (i->cr_hdr.cr_type != CR_OBJ_FILE) {
> +		kfree(i);
> +		return -EINVAL;
> +	}
> +	/* Image of struct file is variable-sized. */
> +	tmp = i;
> +	i = krealloc(i, i->cr_hdr.cr_len + 1, GFP_KERNEL);
> +	if (!i) {
> +		kfree(tmp);
> +		return -ENOMEM;
> +	}
> +	cr_name = (char *)(i + 1);
> +	rv = cr_pread(ctx, cr_name, i->cr_name_len, pos + sizeof(*i));
> +	if (rv < 0) {
> +		kfree(i);
> +		return -ENOMEM;
> +	}
> +	cr_name[i->cr_name_len] = '\0';
> +
> +	file = filp_open(cr_name, i->cr_f_flags, 0);
> +	if (IS_ERR(file)) {
> +		kfree(i);
> +		return PTR_ERR(file);
> +	}
> +	if (file->f_dentry->d_inode->i_mode != i->cr_i_mode) {
> +		fput(file);
> +		kfree(i);
> +		return -EINVAL;
> +	}
> +	if (vfs_llseek(file, i->cr_f_pos, SEEK_SET) != i->cr_f_pos) {
> +		fput(file);
> +		kfree(i);
> +		return -EINVAL;
> +	}
> +
> +	obj = cr_object_create(file);
> +	if (!obj) {
> +		fput(file);
> +		kfree(i);
> +		return -ENOMEM;
> +	}

This contains 7 kfree()s of the same thing (!), 3 fput()s of the 
same thing, replicated all over the place obscuring the real essence 
of the code.

This should be restructured to move all the failure exception cases 
into a clean out of line inverse teardown sequence with proper goto 
labels. That way it will be 70% real code 30% teardown - not 10% 
real code mixed into 90% teardown like above.

Also, whoever named a local variable with a type of
"struct cr_image_file *" as 'i' should be sent back to
coding primary school.

You really should not write new kernel code until you know, follow 
and respect basic code cleanliness principles. I am not inserting 
any more review feedback value into this code until it does not meet 
_basic_ quality standards that make review efforts smooth and 
efficient.

Oh, and then i saw this sequence:

> +	/* Known good and unknown bad flags. */
> +	vm_flags &= ~VM_READ;
> +	vm_flags &= ~VM_WRITE;
> +	vm_flags &= ~VM_EXEC;
> +//	vm_flags &= ~VM_SHARED;
> +	vm_flags &= ~VM_MAYREAD;
> +	vm_flags &= ~VM_MAYWRITE;
> +	vm_flags &= ~VM_MAYEXEC;
> +//	vm_flags &= ~VM_MAYSHARE;
> +	vm_flags &= ~VM_GROWSDOWN;
> +//	vm_flags &= ~VM_GROWSUP;
> +//	vm_flags &= ~VM_PFNMAP;
> +	vm_flags &= ~VM_DENYWRITE;
> +	vm_flags &= ~VM_EXECUTABLE;
> +//	vm_flags &= ~VM_LOCKED;
> +//	vm_flags &= ~VM_IO;
> +//	vm_flags &= ~VM_SEQ_READ;
> +//	vm_flags &= ~VM_RAND_READ;
> +//	vm_flags &= ~VM_DONTCOPY;
> +	vm_flags &= ~VM_DONTEXPAND;
> +//	vm_flags &= ~VM_RESERVED;
> +	vm_flags &= ~VM_ACCOUNT;
> +//	vm_flags &= ~VM_NORESERVE;
> +//	vm_flags &= ~VM_HUGETLB;
> +//	vm_flags &= ~VM_NONLINEAR;
> +//	vm_flags &= ~VM_MAPPED_COPY;
> +//	vm_flags &= ~VM_INSERTPAGE;
> +	vm_flags &= ~VM_ALWAYSDUMP;
> +	vm_flags &= ~VM_CAN_NONLINEAR;
> +//	vm_flags &= ~VM_MIXEDMAP;
> +//	vm_flags &= ~VM_SAO;
> +//	vm_flags &= ~VM_PFN_AT_MMAP;

No comment ...

	Ingo
