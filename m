From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/3] ftrace: add function tracing to single thread
Date: Tue, 25 Nov 2008 19:11:44 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0811251909320.26424@gandalf.stny.rr.com>
References: <20081125223421.795046329@goodmis.org> <20081125223456.976670734@goodmis.org> <20081125144221.66eb99ad.akpm@linux-foundation.org> <alpine.DEB.1.10.0811251800130.26424@gandalf.stny.rr.com> <20081125153104.ecdceed4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753338AbYKZAL5@vger.kernel.org>
In-Reply-To: <20081125153104.ecdceed4.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, fweisbec@gmail.com, srostedt@redhat.com, containers@lists.osdl.org
List-Id: containers.vger.kernel.org




On Tue, 25 Nov 2008, Andrew Morton wrote:

> On Tue, 25 Nov 2008 18:01:06 -0500 (EST)
> Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > 
> > On Tue, 25 Nov 2008, Andrew Morton wrote:
> > 
> > > On Tue, 25 Nov 2008 17:34:22 -0500
> > > Steven Rostedt <rostedt@goodmis.org> wrote:
> > > 
> > > > This patch adds the ability to function trace a single thread.
> > > > The file:
> > > > 
> > > >   /debugfs/tracing/set_ftrace_pid
> > > > 
> > > > contains the pid to trace.
> > > 
> > > What happens if the same pid exists in two or more pid namespaces?
> > 
> > I think we had this discussion before.
> 
> Oh.  What did we end up concluding?
> 
> > It tests current->pid, would that 
> > be different among the name spaces?
> 
> I think those are non-unique.  containers@lists.osdl.org would have
> better ideas..

Added list in CC.

I think the end result was, if this file can only be changed by root, then 
we do not need to worry about namespaces. This file is a privileged file 
that can only be modified by root.

If someday we decide to let non admin users touch this file, then we would
need to care about this.  This file may actually be modified in the future 
by users, so this may become an issue.

-- Steve
