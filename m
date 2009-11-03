From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add a choosepid() syscall as a simpler alternative to
	clone_with_pids()
Date: Tue, 3 Nov 2009 15:43:27 -0600
Message-ID: <20091103214327.GA14693@us.ibm.com>
References: <1257194293-12099-1-git-send-email-danms@us.ibm.com>
	<4AF04FE9.6090301@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AF04FE9.6090301-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> 
> Dan Smith wrote:
> > This proposed simpler interface builds on all the real work done by Suka's
> > early patches in his clone3() set.  Instead of passing in the pids we want
> > in the clone3() call itself, this interface lets us build that list ahead
> > of time, to be used on the next regular clone().
> > 
> > Some points about the implementation:
> >  - The first call to choosepid() allocates a pid_t array on current
> >  - All pids in that list start as zero, which do_fork_with_pids treats as
> >    undefined
> >  - A call to clone() or exec() always clears the current set of next pids
> >  - This was Serge's idea, based on a permutation of Daniel Lezcano's
> >    cloneat() suggestion
> >  - This is based on all Suka's hard work, with a trivial change to the
> >    do_fork_with_pids() function to eliminate the copy_from_user() of the
> >    pid_t list
> > 
> > Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> I don't recall the details, but you probably wanna look at how/when
> kernel threads are created and also at usermode helpers created from
> the kernel (e.g. to load a module on-demand) - make sure they don't
> intentionally (or not) consume the nextpid prepared by the program.

Yup, great point.  Looks like we would want to check for usermode(regs)
and, if that's false, then pass in NULL for target_pids (either from
do_fork_with_pids to copy_process, or from copy_process to alloc_pid()).

-serge
