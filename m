From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] cgroup: Fix root_count when mount fails due to busy
	subsystem
Date: Fri, 23 Jan 2009 18:50:28 +0100
Message-ID: <20090123175028.GC16348@elte.hu>
References: <20090123004703.25103.29754.stgit@menage.corp.google.com> <20090123102253.GF15188@elte.hu> <6599ad830901230859p5453b166tfb384caad210f84b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759774AbZAWRu7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6599ad830901230859p5453b166tfb384caad210f84b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, serue@us.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org


* Paul Menage <menage@google.com> wrote:

> On Fri, Jan 23, 2009 at 2:22 AM, Ingo Molnar <mingo@elte.hu> wrote:
> >> --- a/kernel/cgroup.c
> >> +++ b/kernel/cgroup.c
> >> @@ -1115,8 +1115,10 @@ static void cgroup_kill_sb(struct super_block *sb) {
> >>       }
> >>       write_unlock(&css_set_lock);
> >>
> >> -     list_del(&root->root_list);
> >> -     root_count--;
> >> +     if (!list_empty(&root->root_list)) {
> >> +             list_del(&root->root_list);
> >> +             root_count--;
> >> +     }
> >
> > That's ugly. It is _much_ cleaner to always keep the link head consistent
> > - i.e. initialize it with INIT_LIST_HEAD()
> 
> It is initialized with INIT_LIST_HEAD().
> 
> > and then remove from it via
> > list_del_init().
> 
> There's not much point doing list_del_init() rather than list_del()
> here since we're about to delete the root.
> 
> >
> > That way the error path will do the right thing automatically, and there's
> > no need for that ugly "if !list_empty" construct either.
> 
> The important part here is avoiding decrementing root_count.

that should be done via proper placement of err_* labels. An assymetric 
exit path like the one you did is always the sign of bad code structure.

	Ingo
