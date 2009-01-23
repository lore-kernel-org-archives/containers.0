From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] cgroup: Fix root_count when mount fails due to busy
	subsystem
Date: Fri, 23 Jan 2009 19:36:53 +0100
Message-ID: <20090123183653.GC5984@elte.hu>
References: <20090123004703.25103.29754.stgit@menage.corp.google.com> <20090123181056.GA31142@elte.hu> <6599ad830901231032h76a301ceica371145eca30388@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932145AbZAWSiS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6599ad830901231032h76a301ceica371145eca30388@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, serue@us.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org


* Paul Menage <menage@google.com> wrote:

> On Fri, Jan 23, 2009 at 10:10 AM, Ingo Molnar <mingo@elte.hu> wrote:
> >
> > * Paul Menage <menage@google.com> wrote:
> >
> >> cgroup: Fix root_count when mount fails due to busy subsystem
> >>
> >> root_count was being incremented in cgroup_get_sb() after all error
> >> checking was complete, but decremented in cgroup_kill_sb(), which can be
> >> called on a superblock that we gave up on due to an error.  This patch
> >> changes cgroup_kill_sb() to only decrement root_count if the root was
> >> previously linked into the list of roots.
> >
> > i'm wondering, what happens in the buggy case: does cgroup_kill_sb() get
> > called twice (if yes, why?),
> 
> No.
> 
> > or do we call cgroup_kill_sb() on a not yet
> > added sb and hence root_count has not been elevated yet?
> 
> Right.
> 
> > (if yes, which
> > codepath does this?)
> 
> It's via the call to deactivate_super().

Which exact call chain is that?

> The code could be restructured such that:
> 
> - we don't set sb->s_fs_info until we've linked the new root into the root_list
> - do any necessary cleanup for a failed root in cgroup_get_sb()
> - have cgroup_kill_sb() handle either no root or a fully-initialized root
> 
> But then you're replacing "only decrement root_count if root was linked 
> in to list" with "only do root cleanup if root was atached to sb" in 
> cgroup_kill_sb(). I don't see that one is much cleaner than the other.

Agreed, that's not an improvement.

> For 2.6.29, we should fix this by reverting the broken part of the patch 
> that made it into 2.6.29-rcX

Agreed too - i withdraw my objection.

Nevertheless my observation remains: kernel/cgroup.c has a complex looking 
error paths which should be cleaned up. (independently of this issue)

	Ingo
