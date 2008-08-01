From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] namespaces: introduce sys_hijack (v11)
Date: Fri, 1 Aug 2008 12:38:17 -0500
Message-ID: <20080801173817.GA21367@us.ibm.com>
References: <20080731183213.GA12033@us.ibm.com>
	<20080801092318.GA2002@wavehammer.waldi.eu.org>
	<20080801141152.GA11553@us.ibm.com>
	<20080801155148.GA16760@wavehammer.waldi.eu.org>
	<20080801163905.GA4647@us.ibm.com>
	<20080801171951.GA23754@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080801171951.GA23754-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> On Fri, Aug 01, 2008 at 11:39:05AM -0500, Serge E. Hallyn wrote:
> > Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > > Why is it not enough to use the pid of the ns creator? The ns cgroups
> > 
> > pids wrap around
> 
> Ups, yes.
> 
> > > But I think I have a different problem. Currently, namespaces are
> > > destructed if the last process using them exits. You change that, they
> > > will survive until the cgroup dies. Or is that cgroup destructed when
> > > there are no longer processes using the nsproxy? As the commit message
> > > speaks about "pid wraparound" as problem, I doubt that.
> > 
> > Correct.  Having the namespaces stick around, and being able to attach
> > to an empty container, was something Paul Menage had wanted IIRC.
> 
> It may produce problems with pid namespaces. The namespace is cleared if
> the child reaper dies and I'm not sure how well it behaves without a new
> one, which you can't create.
> 
> > But I'll leave that as is for now, until I hear something other than
> > "this is so wrong it isn't funny" from Pavel :)
> 
> I'm not sure if it is funny to add another piece which may hold
> filesystems open. Currently we can have different namespaces. All of
> them are attached to processes and can be removed with kill. Now this
> code adds another copy to an (automatically created) cgroup.
> 
> IMHO, the cgroup should be destructed automatically if the nsproxy is
> about to be die.

I certainly don't think your caution is unwarranted.  I like to keep the
refcounting in all of this as simple as possible.

However, it does place you at odds with one of the few people who has
expressed an existing need for this functionality :)

Paul, could you respond with precisely what your needs are?  I.e. do
you really only care about the network namespace sticking around?  Need
all of it?  Not need this at all anymore?

thanks,
-serge
