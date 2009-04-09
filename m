From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 11/36] add generic checkpoint f_op to ext fses
Date: Wed, 8 Apr 2009 21:29:40 -0500
Message-ID: <20090409022940.GA22284@us.ibm.com>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
	<1239107264-21775-12-git-send-email-orenl@cs.columbia.edu>
	<20090409015926.GA20112@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090409015926.GA20112-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > 
> > This marks ext[234] as being checkpointable.  There will be many
> > more to do this to, but this is a start.
> > 
> > Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > ---
> >  fs/ext2/dir.c  |    1 +
> >  fs/ext2/file.c |    2 ++
> >  fs/ext3/dir.c  |    1 +
> >  fs/ext3/file.c |    1 +
> >  fs/ext4/dir.c  |    1 +
> >  fs/ext4/file.c |    1 +
> >  6 files changed, 7 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/ext2/dir.c b/fs/ext2/dir.c
> > index 2999d72..4f1dd79 100644
> > --- a/fs/ext2/dir.c
> > +++ b/fs/ext2/dir.c
> > @@ -721,4 +721,5 @@ const struct file_operations ext2_dir_operations = {
> >  	.compat_ioctl	= ext2_compat_ioctl,
> >  #endif
> >  	.fsync		= ext2_sync_file,
> > +	.checkpoint	= generic_file_checkpoint,
> 
> The checkpoint() method is only defined in struct file_operations if
> CONFIG_CHECKPOINT=y.  So this can't possibly compile when
> CONFIG_CHECKPOINT=n...

BTW i think the better way to handle it is not to put everything under
ifdefs, but rather always let file_operations have the ->checkpoint()
fn, and just make generic_file_checkpoint() a dummy function when
CONFIG_CHECKPOINT=n.

-serge
