From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 16/29] A new file type (CR_FD_OBJREF) for
	a file descriptor already setup
Date: Fri, 03 Apr 2009 09:54:08 -0700
Message-ID: <1238777648.8846.84.camel@nimitz>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-17-git-send-email-orenl@cs.columbia.edu>
	<87y6uhyc3j.fsf@caffeine.danplanet.com>
	<49D63865.1030807@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49D63865.1030807-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-04-03 at 12:25 -0400, Oren Laadan wrote:
> > As far as I can tell, hh->fd_objref never gets set anywhere.  On my
> > system, this causes restart to always fail because there is garbage in
> > that field, thus triggering the above check.  If I remove this,
> > restart completes successfully.  The following grep tells me that
> > maybe this check isn't valid:
> > 
> >   % grep fd_objref checkpoint/*.c include/linux/checkpoint*.h
> >   checkpoint/rstr_file.c: file = cr_obj_get_by_ref(ctx, hh->fd_objref, CR_OBJ_FILE);
> >   checkpoint/rstr_file.c: file = cr_obj_add_file(ctx, fds[1-which], hh->fd_objref);
> >   checkpoint/rstr_file.c:static int cr_read_fd_objref(struct cr_ctx *ctx, struct cr_hdr_file *hh)
> >   checkpoint/rstr_file.c: file = cr_obj_get_by_ref(ctx, hh->fd_objref, CR_OBJ_FILE);
> >   checkpoint/rstr_file.c: if (hh->fd_objref < 0)
> >   checkpoint/rstr_file.c:     fd = cr_read_fd_objref(ctx, hh);
> >   include/linux/checkpoint_hdr.h:     __s32 fd_objref;
> 
> hh->fd_objref is set, for pipes, in fs/pipe.c (outcome of the move to f_ops).
> So the problem is that the field isn't explicitly zeroed otherwise. I'll fix
> that for the next round. Meanwhile, you can add:
> 
>         hh->fd_objref = 0;
> 
> in cr_write_file() before the call to file->f_ops->checkpoint().

If fd_objref isn't necessary for all fds, then why do we have it in the
'cr_hdr_fd_ent' object?  It would make a heck of a lot more sense to me
if 'cr_hdr_file' truly contained only the common pieces for all fds.

This all just seems misdesigned to me.  The hh->fd_type should always
say 'PIPE'.  Then we call into the pipe write function.  It can either
write out a real, whole pipe record or it can write out a reference to a
pipe it has already seen.

That way, we can have pipe->inode_objref that actually explains what
kind of objref we're looking for.  We can have something like a
CR_HDR_FD_PIPE_REF or a CR_HDR_FD_INODE_REF object in place of the full
pipe the second time we see it.

-- Dave
