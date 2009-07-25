From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: c/r, time, and virtualization
Date: Sat, 25 Jul 2009 00:26:50 -0700
Message-ID: <m1y6qdkyth.fsf@fess.ebiederm.org>
References: <4A6A93FC.7090209@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A6A93FC.7090209-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Sat\,
	25 Jul 2009 01\:11\:24 -0400")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> writes:

> Hi,
>
> I wonder what's that status of time namespaces and virtual time(rs) ?
>
> http://lwn.net/Articles/180375/  - "virtual time" coverage in LWN (2006)
> http://lkml.org/lkml/2006/4/13/172  - patchset and thread on LKML
> http://lwn.net/Articles/249080/  - kernel summit 2007 - containers
>
> It will be handy for c/r of timers (posix-timers) that I'm working on.
>
> A couple of obstacles off the top of my head:
>
> - Lack of clone flags -- we can use clone_with_pids() for that.
>
> - Fast gettimeofday() via vdso -- perhaps a vdso page per time-ns
> (containing the necessary deltas).
>
> Is anyone working on it ?

I proposed it, for the reason you care.
I have thought about the semantics.
But I haven't gotten as far as implementing something.

I will be happy to bounce ideas off, and review code
when I have a few seconds free.

Eric
