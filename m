From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Fri, 31 Oct 2008 08:48:41 -0500
Message-ID: <20081031134841.GA11140@us.ibm.com>
References: <1225219047.12673.182.camel@nimitz>
	<m163n9y7yb.fsf@frodo.ebiederm.org>
	<1225411757.12673.383.camel@nimitz>
	<m1k5bpwj8j.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1k5bpwj8j.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> With a file descriptor I can push the data onto a network socket and
> the receiving process is on another computer.  0 copies, 0 trips
> to user space.  I'm not certain how you would achieve that with filesystem
> approach.

This has been Oren's most convincing argument for all sorts of little
choices (his precise data format, the use of an fd and cr_kwrite()).

I wonder (a) what neat things Dave could come up with to to bridge that
gap, and (b) how much of that gap becomes less meaningful with a proper
use of pre-dump (and post-dump).

> >> Reading the memory of another process is a problem, to the point
> >> that the /proc/<pid>/mem interface has been removed from the kernel.
> >
> > Yes, this is certainly true.  All of the ptrace-related security issues
> > surely tell us something.  But, I'm not sure of your point here.  Are
> > you saying that using sys_checkpoint() to dump a process's pages is
> > inherently safer than approach that uses a filesystem in order to do the
> > same?
> 
> I'm saying inspecting another process is a very racy operation so something
> we need to be especially careful with. 

I don't see any difference there between Dave's and Oren's approaches.
In either case, the container is frozen while the kernel walks the
container's task's pages and dumps them... somewhere.

-serge
