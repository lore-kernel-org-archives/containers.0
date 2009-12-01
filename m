From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: how to handle devpts
Date: Tue, 1 Dec 2009 09:02:17 -0600
Message-ID: <20091201150217.GC32117@us.ibm.com>
References: <20091130202223.GA20224@us.ibm.com>
	<20091201093708.GC2430@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091201093708.GC2430-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Louis Rilling (Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org):
> Hi Serge,
> =

> On 30/11/09 14:22 -0600, Serge E. Hallyn wrote:
> > We currently checkpoint and restart unix98 ptys in the kernel.
> > So what do we want to do about the userspace part?  In particular,
> > if I run the following test program and checkpoint it, it
> > has `tty` open.  What do we want to do about that?
> > =

> > Just having user-cr/restart.c take an option to mount a new
> > instance of devpts isn't enough - we don't get hooked up to
> > restart.c's stdin/out obviously, and restart succeeds but the
> > restarted program exists with -EIO.  At the same time, just
> > doing a cradvise type of thing to plug fds 0,1,2 suffice for
> > this testcase, but not for something more complicated which
> > also has other unix98 ptys open.
> =

> In Kerrighed we are implementing something =E0-la-cradvise: we allow the
> caller of sys_restart() to give replacement fds for arbitrary files. To a=
chieve
> this, each checkpointed file descriptor (struct file) has a unique key, a=
nd
> sys_restart() takes a substitution table in parameter, where an entry is a
> pair (key, fd).

Thanks - that sounds somewhat like what I was leaning toward last
night.  In particular, I was thinking that a user-space tool could
walk over the checkpoint image and replace certain checkpointed
filenames with a string like "\0RESERVED_FD0".  Sys_restart() would
see that filename at restore_file() and plug in the coordinator task's
fd 0.

The thing I don't like about it is that I'm replacing pathnames,
and so I worry that applications playing with mounts namespaces
will be a problem for the program rewriting the checkpoint image.
Not insurmountable, but requiring a lot more work...

> In Kerrighed sys_checkpoint() exports a human-readable table of checkpoin=
ted
> file descriptors, with types, fd in each checkpointed task, etc.
> With Oren's patchset, I presume that some userspace tool could extract su=
ch a
> table from the checkpoint.

Yeah, I guess such a program for analyzing and rewriting resources
in a checkpoint image would be very useful.  Could perhaps also
be used for network interfaces, internal mounts, uids, in-kernel
keyring...

> Hope this makes the discussion progress...

Yup, thanks!

-serge
