From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/2] sys_restore prototype
Date: Mon, 28 Jul 2008 15:00:08 -0700
Message-ID: <m1sktthdp3.fsf@frodo.ebiederm.org>
References: <20080725225655.GA28276@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080725225655.GA28276-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri, 25 Jul 2008 17:56:56 -0500")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> We were talking this morning about what trivial patchset to begin
> with to get a start on checkpoint and restart.  We thought that
> rather than start with checkpoint, maybe we should start with
> something that reads a "checkpoint file" and "restarts" a single
> task.  In this case, restart means it sets the process id and
> executes the file which are found in the checkpoint file.
>
> So here's what we whipped up for a half hour this morning,
> and during some of Mark's talk this afternoon.
>
> It refuses to run if it isn't the container init, so you must
> unshare your pidns before calling sys_restore().

A reasonable approximation. 

Dave Hansen made a good point when he asked how do we graft a restored
checkpoint into the rest of the system.  Requiring us to unshare
everything we intend to unshare before restore achieves this easily,
and you are following in that model.

That leads to an interesting implication.  We don't need to set the pid
of the first process.  At most we can verify that the pid is the same.
If we have unshared the pid namespace the pid will be 1 and the needed
pid of the first process will be 1.

More later.

Eric
