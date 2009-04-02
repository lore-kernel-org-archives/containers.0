From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add UTS support (v6)
Date: Thu, 2 Apr 2009 12:58:04 -0500
Message-ID: <20090402175804.GC21178@us.ibm.com>
References: <1238533107-11796-1-git-send-email-danms@us.ibm.com>
	<1238533107-11796-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238533107-11796-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> This patch adds a "phase" of checkpoint that saves out information about any
> namespaces the task(s) may have.  Do this by tracking the namespace objects
> of the tasks and making sure that tasks with the same namespace that follow
> get properly referenced in the checkpoint stream.
> 
> I tested this with single and multiple task restore, on top of Oren's
> v13 tree.
> 
> Changes:
>   - Remove the kernel restore path
>   - Punt on nested namespaces
>   - Use __NEW_UTS_LEN in nodename and domainname buffers
>   - Add a note to Documentation/checkpoint/internals.txt to indicate where
>     in the save/restore process the UTS information is kept
>   - Store (and track) the objref of the namespace itself instead of the
>     nsproxy (based on comments from Dave on IRC)
>   - Remove explicit check for non-root nsproxy
>   - Store the nodename and domainname lengths and use cr_write_string()
>     to store the actual name strings
>   - Catch failure of cr_obj_add_ptr() in cr_write_namespaces()
>   - Remove "types" bitfield and use the "is this new" flag to determine
>     whether or not we should write out a new ns descriptor
>   - Replace kernel restore path
>   - Move the namespace information to be directly after the task
>     information record
>   - Update Documentation to reflect new location of namespace info
>   - Support checkpoint and restart of nested UTS namespaces
> 
> Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Yup, ignore my first reply.  This does seem like the way to go.

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Except for two comments:

> ---
>  Documentation/checkpoint/internals.txt |    1 +
>  checkpoint/Makefile                    |    1 +
>  checkpoint/checkpoint.c                |   66 ++++++++++++++++++++-
>  checkpoint/objhash.c                   |    7 ++
>  checkpoint/restart.c                   |  101 ++++++++++++++++++++++++++++++++
>  include/linux/checkpoint.h             |    1 +
>  include/linux/checkpoint_hdr.h         |   11 ++++
>  7 files changed, 185 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/checkpoint/internals.txt b/Documentation/checkpoint/internals.txt
> index c741b6c..bdd202c 100644
> --- a/Documentation/checkpoint/internals.txt
> +++ b/Documentation/checkpoint/internals.txt
> @@ -17,6 +17,7 @@ The order of operations, both save and restore, is as follows:
>    -> thread state: elements of thread_struct and thread_info
>    -> CPU state: registers etc, including FPU
>    -> memory state: memory address space layout and contents
> +  -> namespace information
>    -> filesystem state: [TBD] filesystem namespace state, chroot, cwd, etc
>    -> files state: open file descriptors and their state
>    -> signals state: [TBD] pending signals and signal handling state
> diff --git a/checkpoint/Makefile b/checkpoint/Makefile
> index 607d864..55c5c3d 100644
> --- a/checkpoint/Makefile
> +++ b/checkpoint/Makefile
> @@ -4,3 +4,4 @@
> 
>  obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o objhash.o \
>  		ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o
> +EXTRA_CFLAGS += -DDEBUG
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index c2f0e16..5f83e83 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -213,6 +213,65 @@ static int cr_write_tail(struct cr_ctx *ctx)
>  	return ret;
> +static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_namespaces *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct nsproxy *nsp = t->nsproxy;
> +	int ret;
> +	int uts;
> +
> +	h.type = CR_HDR_NS;
> +	h.len = sizeof(*hh);
> +
> +	uts = cr_obj_add_ptr(ctx, nsp->uts_ns, &hh->uts_ref, CR_OBJ_UTSNS, 0);

I would prefer this be called 'uts_was_new' or something, though.

> +	if (uts < 0)
> +		goto out;
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	if (ret)
> +		goto out;
> +
> +	if (uts) {
> +		ret = cr_write_utsns(ctx, &nsp->uts_ns->name);
> +		if (ret < 0)
> +			goto out;
> +	}
> +
> +	/* FIXME: Write other namespaces here */
> + out:
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}
> +

...

> +	ns = t->nsproxy->uts_ns;

Should probably memset them to 0 first.  I realize it doesn't
really seem like security-relevant information leakage, but
sys_hostname() does it, so it seems like we ought to as well.

> +	memcpy(ns->name.nodename, nn, hh.nodename_len);
> +	memcpy(ns->name.domainname, dn, hh.domainname_len);
> +
> + out:
> +	kfree(nn);
> +	kfree(dn);
> +
> +	return ret;
> +}

-serge
