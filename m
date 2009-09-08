From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] cr: pty: don't use required_id, change ptmx_open()
Date: Tue, 8 Sep 2009 14:51:31 -0500
Message-ID: <20090908195131.GA23683@us.ibm.com>
References: <20090902233111.GA27125@us.ibm.com> <4AA69EEB.9040706@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AA69EEB.9040706-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> > +	file = alloc_file(nd.path.mnt, ptmxdentry, FMODE_READ|FMODE_WRITE, &tty_fops);
> > +	path_put(&nd.path);
> > +	if (!file) {
> > +		dput(ptmxdentry);
> > +		return ERR_PTR(-EINVAL);
> > +	}
> > +
> > +	ret = security_dentry_open(file, current_cred());
> > +	if (ret) {
> > +		fput(file);
> > +		return ERR_PTR(ret);
> > +	}
> > +	/* check write access perms to file */
> 
> I bet the above can be done by reusing lookup and __dentry_open()
> functions from fs/open.c and fs/namei.c ...

With lookup_create()?  Hmm, yeah - I think there are reasons I can't do
that, but I'll just try and see where it gets us.

> > +
> > +	lock_kernel();  /* tty_open does it... */
> > +	ret = open_create_pty(fdir, h->index, file);
> > +	unlock_kernel();
> > +	if (ret) {
> > +		fput(file);
> > +		return ERR_PTR(ret);
> > +	}
> > +	ckpt_debug("master file %p (obj %d)\n", file, h->file_objref);
> > +
> > +	/*
> > +	 * Add file to objhash to ensure proper cleanup later
> > +	 * (it isn't referenced elsewhere). Use h->file_objref
> > +	 * which was explicitly during checkpoint for this.
> > +	 */
> > +	ret = ckpt_obj_insert(ctx, file, h->file_objref, CKPT_OBJ_FILE);
> > +	if (ret < 0) {
> > +		fput(file);
> > +		return ERR_PTR(ret);
> > +	}
> 
> Can do this in caller. So
> 
> > +
> > +	tty = file->private_data;
> > +	fput(file);   /* objhash took a ref */
> > +
> > +	return tty;
> > +}
> > +
> > +struct tty_struct *pty_open_by_master(struct ckpt_ctx *ctx,
> > +		struct ckpt_hdr_tty *h)
> > +{
> > +	struct file *fdir;
> > +	struct tty_struct *tty;
> > +	/*
> > +	 * we need to pick a way to specify which devpts
> > +	 * mountpoint to use.  For now, we'll just use
> > +	 * whatever /dev/ptmx points to
> > +	 */
> > +	fdir = filp_open("/dev/pts", O_RDONLY, 0);
> > +	if (IS_ERR(fdir))
> > +		return ERR_PTR(PTR_ERR(fdir));
> 
> Does this mean that to restore a subtree on a system without
> devpts-ns it won't work ?  (no /dev/pts/ptmx)

Yes.  I figured once we settle on devpts ns handling, we can
trivially special-case the DEVPTS_MULTIPLE_INSTANCES=n case
to use /dev/ptmx.

Since we're punting on devpts namespaces anyway I guess the
pty_open_by_master() can just open /dev/ptmx directly for
now.

Or, maybe we're better off handling the namespaces.  Because
without doing that, we are hard-coding pathnames in the kernel
left and right, and that's Bad(tm).

thanks,
-serge
