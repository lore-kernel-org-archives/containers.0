From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: A question about group CFS scheduling
Date: Thu, 26 Jun 2008 13:08:27 +0200
Message-ID: <1214478507.4922.0.camel@twins.programming.kicks-ass.net>
References: <ac8af0be0806260019q45fa7285oa0fc79fb02254d28@mail.gmail.com>
	 <1214468112.2794.9.camel@twins.programming.kicks-ass.net>
	 <ac8af0be0806260133u68a5692flab65e4bb6dcf2a13@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758263AbYFZLIy@vger.kernel.org>
In-Reply-To: <ac8af0be0806260133u68a5692flab65e4bb6dcf2a13@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: vatsa@linux.vnet.ibm.com, mingo@elte.hu, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Thu, 2008-06-26 at 16:33 +0800, Zhao Forrest wrote:
> >
> > Let me explain the cgroup case (the sanest option IMHO):
> >
> > initially all your tasks will belong to the root cgroup, eg:
> >
> > assuming:
> > mkdir -p /cgroup/cpu
> > mount none /cgroup/cpu -t cgroup -o cpu
> >
> > Then the root cgroup (cgroup:/) is /cgroup/cpu/ and all tasks will be
> > found in /cgroup/cpu/tasks.
> >
> > You can then create new groups as sibling from this root group, eg:
> >
> > cgroup:/foo
> > cgroup:/bar
> >
> > They will get a weigth of 1024 by default, exactly as heavy as a nice 0
> > task.
> >
> > That means that no matter how many tasks you stuff into foo, their
> > combined cpu time will be as much as a single tasks in cgroup:/ would
> > get.
> >
> > This is fully recursive, so you can also create:
> >
> > cgroup:/foo/bar and its tasks in turn will get as much combined cpu time
> > as a single task in cgroup:/foo would get.
> >
> > In theory this should go on indefinitely, in practise we'll run into
> > serious numerical issues quite quickly.
> >
> >
> > The USER grouping basically creates a fake root and all uids (including
> > 0) are its siblings. The only special case is that uid-0 (aka root) will
> > get twice the weight of the others.
> >
> 
> Thank you for your detailed explanation! I have one more question:
> cgrouping and USER grouping is mutual exclusive, am I right? That is,
> when enabling cgrouping, USER grouping need to be disabled, vice
> versa.

Yes indeed. That is set at kernel build time. So the kernel either
supports cgroup scheduling or uid stuff.
