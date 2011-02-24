From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 9/9] userns: check user namespace for task->file uid
	equivalence checks
Date: Thu, 24 Feb 2011 03:24:16 +0000
Message-ID: <20110224032415.GA5555__42846.3201890283$1298517966$gmane$org@mail.hallyn.com>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217150406.GI26395@mail.hallyn.com>
	<20110218155935.66e7782d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110218155935.66e7782d.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Thu, 17 Feb 2011 15:04:07 +0000
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > Cheat for now and say all files belong to init_user_ns.  Next
> > step will be to let superblocks belong to a user_ns, and derive
> > inode_userns(inode) from inode->i_sb->s_user_ns.  Finally we'll
> > introduce more flexible arrangements.
> > 
> >
> > ...
> >
> > +
> > +/*
> > + * return 1 if current either has CAP_FOWNER to the
> > + * file, or owns the file.
> > + */
> > +int is_owner_or_cap(const struct inode *inode)
> > +{
> > +	struct user_namespace *ns = inode_userns(inode);
> > +
> > +	if (current_user_ns() == ns && current_fsuid() == inode->i_uid)
> > +		return 1;
> > +	if (ns_capable(ns, CAP_FOWNER))
> > +		return 1;
> > +	return 0;
> > +}
> 
> bool?
> 
> > +EXPORT_SYMBOL(is_owner_or_cap);
> 
> There's a fairly well adhered to convention that global symbols (and
> often static symbols) have a prefix which identifies the subsystem to
> which they belong.  This patchset rather scorns that convention.
> 
> Most of these identifiers are pretty obviously from the capability
> subsystem, but still...

Would 'inode_owner_or_capable' be better and and make sense?

-serge
