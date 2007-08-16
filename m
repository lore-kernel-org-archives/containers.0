From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 19/20] Changes to show virtual ids to user
Date: Thu, 16 Aug 2007 07:13:54 -0500
Message-ID: <20070816121354.GB13302@sergelap.austin.ibm.com>
References: <46BC508C.mailGLJ118R5H@openvz.org> <20070814131202.73b7d559.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758595AbXHPMOP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070814131202.73b7d559.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, oleg@tv-sign.ru
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm@linux-foundation.org):
> On Fri, 10 Aug 2007 15:48:28 +0400
> xemul@openvz.org wrote:
> 
> > This is the largest patch in the set. Make all (I hope) the places where
> > the pid is shown to or get from user operate on the virtual pids.
> > 
> > The idea is:
> >  - all in-kernel data structures must store either struct pid itself
> >    or the pid's global nr, obtained with pid_nr() call;
> >  - when seeking the task from kernel code with the stored id one
> >    should use find_task_by_pid() call that works with global pids;
> >  - when showing pid's numerical value to the user the virtual one
> >    should be used, but however when one shows task's pid outside this
> >    task's namespace the global one is to be used;
> >  - when getting the pid from userspace one need to consider this as
> >    the virtual one and use appropriate task/pid-searching functions.
> > 
> > ...
> >
> > -	si.si_pid = current->pid;
> > +	si.si_pid = task_pid_vnr(current);
> 
> This is going to be an ongoing maintenance problem: people will sneak
> new references to current->pid into the tree and nobody will notice.
> 
> It'd be best to rename task_struct.pid to something else to catch such
> problems and to force people to use the right accessors.  Is that feasible?

It's certainly feasible, and something we'd previously done for instance
in http://marc.info/?l=linux-kernel&m=113751118609597&w=2

> Generally this is a tactic which should be used whenever things like this
> are virtualised.

Ok, it's a big invasive patchset, but there's no reason we can't do it.

thanks,
-serge
