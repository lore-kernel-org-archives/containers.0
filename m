From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] User namespaces: general cleanups
Date: Mon, 13 Oct 2008 16:41:08 -0500
Message-ID: <20081013214108.GA4701@us.ibm.com>
References: <20081010011917.GA8046@us.ibm.com> <30854.1223633214@redhat.com>
	<20081013160144.GA10359@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081013160144.GA10359-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> > Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> > > +		new->uid = new->euid = new->suid = new->fsuid = 0;
> > > +		new->gid = new->egid = new->sgid = new->fsgid = 0;
> > 
> > Should the supplementary groups be zapped too?  Do the GIDs therein still have
> > meaning in the new user namespace?
> > 
> > Note also that eCryptFS is broken by your patch. 
> > 
> > I suggest adding the attached incremental patch.  It makes the following
> > changes:
> > 
> >  (1) Provides a current_user_ns() macro to wrap accesses to current's user
> >      namespace.
> > 
> >  (2) Fixes eCryptFS.
> > 
> >  (3) Renames create_new_userns() to create_user_ns() to be more consistent
> >      with the other associated functions and because the 'new' in the name is
> >      superfluous.
> > 
> >  (4) Moves the argument and permission checks made for CLONE_NEWUSER to the
> >      beginning of do_fork() so that they're done prior to making any attempts
> >      at allocation.
> > 
> >  (5) Calls create_user_ns() after prepare_creds(), and gives it the new creds
> >      to fill in rather than have it return the new root user.  I don't imagine
> >      the new root user being used for anything other than filling in a cred
> >      struct.
> > 
> >      This also permits me to get rid of a get_uid() and a free_uid(), as the
> >      reference the creds were holding on the old user_struct can just be
> >      transferred to the new namespace's creator pointer.
> > 
> >  (6) Makes create_user_ns() reset the UIDs and GIDs of the creds under
> >      preparation rather than doing it in copy_creds().
> 
> Hmm, with this patch, with CONFIG_KEYS=y users in child user_namespaces
> never get freed.  Ones in the init_user_ns do, and with CONFIG_KEYS=n,
> those in child user_namespaces do as well.
> 
> I don't see anything obvious in copy_creds() that would cause this...

Ok, actually I was mis-interpreting through inconsistent testing.  User
namespaces have nothing to do with it.

With the following patch applied to the base next-creds-subsys branch,
you can track that if you login as root, then do 'su hallyn', where
hallyn is uid 500, then uid 500 gets allocated twice.  So free is never
called on it.

I assume the problem is somewhere in kernel/sys.c and kernel/cred.c, but
haven't quite figured it out yet.

-serge
