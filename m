From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add a choosepid() syscall as a simpler alternative to
	clone_with_pids()
Date: Mon, 2 Nov 2009 16:10:16 -0600
Message-ID: <20091102221016.GA13766@us.ibm.com>
References: <1257194293-12099-1-git-send-email-danms@us.ibm.com>
	<4AEF45BB.4080609@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AEF45BB.4080609-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
> Hi Dan,
> 
> Two comments:
> 
> 1. We already tried a similar approach over a year ago - selecting pids
> using a /proc interface instead of a dedicated syscall - and received
> chilling reactions. (IIRC posted by Nadia Derbey).

The chilling reactions were due to (1) general objections to the functionality
of clone_with_pids() itself, (2) new procfiles, the way alloc_pid() was being
extended (i.e. that was solved by Suka as well as (1)) and especially (3) using
a generic, multiplexed 'next_id' file.

I don't think we can extrapolate from those objections to this patchset
being objectionable.

> 2. What do you expect to gain by splitting the work into two separate
> system calls ?

Two very simple syscalls which are both trivially correct and trivial
for userspace to use.

-serge
