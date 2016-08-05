From: "J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv5] locks: Filter /proc/locks output on proc pid ns
Date: Fri, 5 Aug 2016 10:58:11 -0400
Message-ID: <20160805145811.GA31396@pad>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<1470382204-21480-1-git-send-email-kernel@kyup.com>
	<1470394036.8100.2.camel@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1470394036.8100.2.camel-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Aug 05, 2016 at 06:47:16AM -0400, Jeff Layton wrote:
> On Fri, 2016-08-05 at 10:30 +0300, Nikolay Borisov wrote:
> > On busy container servers reading /proc/locks shows all the locks
> > created by all clients. This can cause large latency spikes. In my
> > case I observed lsof taking up to 5-10 seconds while processing around
> > 50k locks. Fix this by limiting the locks shown only to those created
> > in the same pidns as the one the proc fs was mounted in. When reading
> > /proc/locks from the init_pid_ns proc instance then perform no
> > filtering
> > =

> > > Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
> > > Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > ---
> > =A0fs/locks.c | 20 +++++++++++++++++---
> > =A01 file changed, 17 insertions(+), 3 deletions(-)
> > =

> > diff --git a/fs/locks.c b/fs/locks.c
> > index ee1b15f6fc13..484b7e106076 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -2574,9 +2574,19 @@ static void lock_get_status(struct seq_file *f, =
struct file_lock *fl,
> > > =A0	struct inode *inode =3D NULL;
> > > =A0	unsigned int fl_pid;
> > =A0
> > > -	if (fl->fl_nspid)
> > > -		fl_pid =3D pid_vnr(fl->fl_nspid);
> > > -	else
> > > +	if (fl->fl_nspid) {
> > > +		struct pid_namespace *proc_pidns =3D file_inode(f->file)->i_sb->s_=
fs_info;
> > +
> > > +		/* Don't let fl_pid change depending on who is reading the file */
> > > +		fl_pid =3D pid_nr_ns(fl->fl_nspid, proc_pidns);
> > +
> > > +		/* If there isn't a fl_pid don't display who is waiting on the lock
> > > +		=A0* if we are called from locks_show, or if we are called from
> > > +		=A0* __show_fd_info - skip lock entirely
> > > +		=A0*/
> > > +		if (fl_pid =3D=3D 0)
> > > +			return;
> > > +	} else
> > > =A0		fl_pid =3D fl->fl_pid;
> > =A0
> > > =A0	if (fl->fl_file !=3D NULL)
> > @@ -2648,9 +2658,13 @@ static int locks_show(struct seq_file *f, void *=
v)
> > =A0{
> > > =A0	struct locks_iterator *iter =3D f->private;
> > > =A0	struct file_lock *fl, *bfl;
> > > +	struct pid_namespace *proc_pidns =3D file_inode(f->file)->i_sb->s_f=
s_info;
> > =A0
> > > =A0	fl =3D hlist_entry(v, struct file_lock, fl_link);
> > =A0
> > > +	if (fl->fl_nspid && !pid_nr_ns(fl->fl_nspid, proc_pidns))
> > > +		return 0;
> > +
> > > =A0	lock_get_status(f, fl, iter->li_pos, "");
> > =A0
> > > =A0	list_for_each_entry(bfl, &fl->fl_block, fl_block)
> =

> Looks good to me. I'll go ahead and merge this into my locks branch for
> v4.9 and get it into -next.

Makes sense to me.  Thanks also to Eric for the help.

--b.
