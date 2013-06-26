From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] procfs: add pidnr file
Date: Wed, 26 Jun 2013 15:26:47 -0500
Message-ID: <20130626202647.GA3001@sergelap>
References: <20130626161820.GA32142@tp>
 <877ghg4q6i.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877ghg4q6i.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Add a file called pidnr under /proc/task/.  Reading this file gives the
> > pid of /proc/task in the reading task's namespace (or 0 if there is no
> > valid pid).
> >
> > This fills a need currently not solvable at all.  The particular need I
> > have for it is so that a task inside a container can pass requests to a
> > task outside the container (using an open fd for /proc/task) to have the
> > target task moved to a new cgroup.  Others have asked for this ability
> > for other reasons.
> 
> This is solvable today.  Just pass the pid using SCM_CREDENTIALS over a
> unix domain socket between the two processes.  That is actually better
> because a task can't claim to be a member of another task.  You already
> have the unix domain socket if you are using SCM_RIGHTS to pass file
> descriptors.

Hm, yeah, that should work.  (I was thinking I had to do a
getpeercon-like thing where I could only get the ucreds of the
task which opened the socket).  I'll try it to see if there are 
any gotchas.

Note though that this doesn't help the general admin case, because
it requires a program (and not a one-liner) running in the container.
So I can't just do

	cat /proc/`pidof container-init`/root/proc/200/pidnr"

to figure out the corresponding pid in my own ns.  Whereas that cat
doesn't require me to execute anything inside that container.

Wonder if coreutils should ship a program which clones a task in
same netns but target pidns, and sends ucred.pid = atoi(argv[1])
from that pidns to the first task which prints out what it reads.

That should be a tidy, purely userspace solution to the general admin
problem.  Only downside being that it requires the rights to setns to
the pidns, instead of just read access to its /proc.

thanks,
-serge
