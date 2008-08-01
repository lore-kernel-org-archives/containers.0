From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] namespaces: introduce sys_hijack (v11)
Date: Fri, 1 Aug 2008 11:39:05 -0500
Message-ID: <20080801163905.GA4647@us.ibm.com>
References: <20080731183213.GA12033@us.ibm.com>
	<20080801092318.GA2002@wavehammer.waldi.eu.org>
	<20080801141152.GA11553@us.ibm.com>
	<20080801155148.GA16760@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080801155148.GA16760-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> On Fri, Aug 01, 2008 at 09:11:53AM -0500, Serge E. Hallyn wrote:
> > Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > > On Thu, Jul 31, 2008 at 01:32:13PM -0500, Serge E. Hallyn wrote:
> > > > The effect is a sort of namespace enter.  The following program
> > > > uses sys_hijack to 'enter' all namespaces of the specified
> > > > cgroup.
> > > 
> > > I currently fail to see what the differences to a normal cgroup attach
> > > is.
> > 
> > A normal cgroup attach doesn't switch a task's root and nsproxies.
> 
> > Current functionality doesn't suffice because namespaces and
> > fs_struct are not switched with cgroup attach.  Cgroup attach is
> > just about tracking tasks, and keeping stats and enforcing limits or
> > guarantees on the groups.
> 
> If you apply a nsproxy to a cgroup, it is part of its limits.
> 
> > The problem with implementing this feature using the attach
> > semantics is that it would move an existing task into the new
> > cgroup.  That would get much more complicated, especially when
> > you consider pid namespaces, where we explicitly refuse to
> > unshare for the same reason.
> 
> Okay, this is a reason. But I think it should disallow attach after the
> nsproxy is set, otherwise you can use attach and hijack for the same
> cgroup and produce different behaviour. The description of the
> can_attach method does not mention such a test, but it seems to do one.

Hmm, the description should mention that.  Yes, you can onlly attach
to an empty cgroup.  Obviously that behavior was changed in the
patchset which implemented namespace entering through attach, but
that patchset was tossed.

> Why is it not enough to use the pid of the ns creator? The ns cgroups

pids wrap around

> are created including the pid in the name. And it would avoid using that
> weird interface with fd of a cgroups file.
> 
> > That is why, with hijack, we clone a new task which is started
> > afresh in the new namespaces.
> 
> Why did you name it "hijack"? If I had not read the mail, I'd no idea
> what this is about. It does not take away the information from something
> else, it overrides the information (nsprox, fs) on the new task.

We can call it whatever we want, but originally it amounted to hijacking
the namespace info from an existing task so it seemed as good a name as
any for an RFC.

> But I think I have a different problem. Currently, namespaces are
> destructed if the last process using them exits. You change that, they
> will survive until the cgroup dies. Or is that cgroup destructed when
> there are no longer processes using the nsproxy? As the commit message
> speaks about "pid wraparound" as problem, I doubt that.

Correct.  Having the namespaces stick around, and being able to attach
to an empty container, was something Paul Menage had wanted IIRC.

Hmm, and now that you mention it, I notice that actually the /proc for
a container doesn't behave right after all tasks in a container exit.

But I'll leave that as is for now, until I hear something other than
"this is so wrong it isn't funny" from Pavel :)

-serge
