From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Mon, 21 Jun 2010 16:38:13 +0200
Message-ID: <20100621143813.GA6630@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100621111554.GJ16877@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100621111554.GJ16877@hawkmoon.kerlabs.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 06/21, Louis Rilling wrote:
>
> On 18/06/10 19:55 +0200, Oleg Nesterov wrote:
>
> > Yes, this should be fixed, I already realized this. work->func(ns) is
> > called when ns is already fixed.
> >
> > Otherwise, nobody should use ns->proc_mount when ns is already dead/freed.
>
> I meant the opposite. proc_mnt can be kept mounted somewhere,

I think, no. If it is kept mounted vfsmount should be different.

> and accesses to it
> will likely try to access (freed) pid_ns from it.

Not sure, there must be no tasks (and pids) in this ns.

By anyway I agree. This needs more thinking and we should do something
with sb->s_fs_info.

But given that nobody (including me) seem to like this approach - let's
forget this patch.

Thanks,

Oleg.
