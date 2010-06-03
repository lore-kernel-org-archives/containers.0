From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH 2/2] cgroups: make procs file writable
Date: Thu, 3 Jun 2010 00:44:16 -0400
Message-ID: <20100603044416.GB21006@ghc02.ghc.andrew.cmu.edu>
References: <20100531180446.GA16249@redhat.com>
	<AANLkTimcrX0TjzDMNJdubR92pAO4IPATbVpyvvVt0qIV@mail.gmail.com>
	<20100602140659.GA5324@redhat.com>
	<AANLkTin-T6ij3xf0ceGoCamwcoayxyf0GdAKY6yXDMVl@mail.gmail.com>
	<20100602202048.GB28663@redhat.com>
	<AANLkTimrJFiidM8BlUNvmzfapUAv8369R9PYnTscasEf@mail.gmail.com>
	<20100602205855.GA30039@redhat.com>
	<AANLkTimfHlapl7mbRyAazWW5q5Wzs23n6i9wIhVtSv6r@mail.gmail.com>
	<20100602213832.GB31949@redhat.com>
	<AANLkTimsusetA9B95-LvKsDdAB_PegYH7Zljyi4Doe_q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimsusetA9B95-LvKsDdAB_PegYH7Zljyi4Doe_q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jun 02, 2010 at 03:03:49PM -0700, Paul Menage wrote:
> On Wed, Jun 2, 2010 at 2:38 PM, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > cgroup_attach_task() does, and this time PF_EXITING is understandable.
> >
> 
> Oh, OK, I was talking about the one in cgroup_attach_task(), which is
> called by attach_task_by_pid(), and assumed that you were referring to
> the same one. I'd forgotten about the pre-check in
> attach_task_by_pid(). Yes, that one could probably be removed without
> affecting any final outcomes.
> 
> Paul

Yes, I agree. The check should be moved into cgroup_attach_task before
the ss->can_attach calls, so the "optimization" stays in the case where
it's wanted.

And the use of __task_cred after the exiting check seems safe too if the
check is gone - from cred.h: "The caller must make sure task doesn't go
away, either by holding a ref on task or by holding tasklist_lock to
prevent it from being unlinked." So that means it'd be safe to take a
reference, task sets exiting and does everything before unhashing, then
access the cred pointer; since we hold tasklist lock it's the same case.

-- Ben
