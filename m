From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 43/54] sysvipc-shm: checkpoint
Date: Fri, 15 May 2009 14:20:37 -0500
Message-ID: <20090515192037.GA29623@us.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-44-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1240961064-13991-44-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> +int checkpoint_ipc_shm(int id, void *p, void *data)
> +{
> +	struct ckpt_hdr_ipc_shm *h;
> +	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
> +	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
> +	struct shmid_kernel *shp;
> +	struct inode *inode;
> +	int first, objref;
> +	int ret;
> +
> +	shp = container_of(perm, struct shmid_kernel, shm_perm);
> +	inode = shp->shm_file->f_dentry->d_inode;
> +
> +	objref = ckpt_obj_lookup_add(ctx, inode, CKPT_OBJ_INODE, &first);
> +	if (objref < 0)
> +		return objref;
> +	/* this must be the first time we see this region */
> +	BUG_ON(!first);
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_SHM);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	ret = fill_ipc_shm_hdr(ctx, h, shp);
> +	if (ret < 0)
> +		goto out;
> +
> +	h->objref = objref;
> +	ckpt_debug("shm: objref %d\n", h->objref);
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = checkpoint_memory_contents(ctx, NULL, inode);

Of course all of the ipc checkpointing will have to actually
use ipc_perms() to check access rights.  Until that's done
we might need to just disable unprivileged checkpoints...

-serge
