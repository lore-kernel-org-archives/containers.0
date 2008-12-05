From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] checkpoint/restart: refuse checkpoint on detached file
Date: Fri, 05 Dec 2008 14:53:39 -0800
Message-ID: <1228517619.11768.14.camel@nimitz>
References: <20081205044141.GA1444@us.ibm.com>
	<1228516454.11768.8.camel@nimitz> <20081205224643.GA29599@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081205224643.GA29599-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-12-05 at 16:46 -0600, Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > On Thu, 2008-12-04 at 22:41 -0600, Serge E. Hallyn wrote:
> > > 
> > > @@ -158,6 +173,12 @@ cr_write_fd_ent(struct cr_ctx *ctx, struct
> > > files_struct *files, int fd)
> > >                 goto out;
> > >         }
> > > 
> > > +       /* Make sure this isn't under some detached tree */
> > > +       if (file_in_detached_tree(file)) {
> > > +               ret = -EBADF;
> > > +               goto out;
> > > +       }
> > 
> > Looks fine to me.  This is racy, though.  Right?
> > 
> > There's no locking to keep the thing mounted for the duration of the
> > checkpoint.
> 
> Oh, hahah, yeah.  We have the file pinned so we're not going to
> lose any vfsmnt/dentries, but you're right, someone else could
> come along and umount -l in the middle.
> 
> I suppose we could hold the namespace sem but it doesn't seem worth
> it and could deadlock.
> 
> Patch withdrawn for now  :)

Well, it is better than nothing.  We don't have to worry about people
messing with it if we have complete control over the entire
mnt_namespace.  

-- Dave
