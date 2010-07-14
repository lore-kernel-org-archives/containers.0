From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] pidns: Fix wait for zombies to be reaped in zap_pid_ns_processes
Date: Tue, 13 Jul 2010 18:47:38 -0700
Message-ID: <m1oceakf5x.fsf@fess.ebiederm.org>
References: <20100625212758.GA30474@redhat.com>
	<20100625220713.GA31123@us.ibm.com>
	<m1r5jd5l0v.fsf_-_@fess.ebiederm.org>
	<m1mxu15kv4.fsf_-_@fess.ebiederm.org>
	<20100709121425.GB18586@hawkmoon.kerlabs.com>
	<m1lj9k4xfx.fsf@fess.ebiederm.org>
	<20100709141324.GC18586@hawkmoon.kerlabs.com>
	<m1aaq04ph2.fsf_-_@fess.ebiederm.org>
	<20100711141406.GD18586@hawkmoon.kerlabs.com>
	<m1tyo4shas.fsf_-_@fess.ebiederm.org>
	<20100713214234.GA21042@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100713214234.GA21042@hawkmoon.kerlabs.com> (Louis Rilling's message of "Tue\, 13 Jul 2010 23\:42\:35 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Emelyanov <xemul@openvz.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

Louis Rilling <Louis.Rilling@kerlabs.com> writes:

> This patch looks like it is working (only a small RCU issue shown below). I
> couldn't try it yet though.

It certainly worked in my testing. 

> I must admit that I am using a similar back-off solution in Kerrighed (not to
> solve the issue of proc_flush_task(), but for one of the reasons that you stated
> above: we want to be sure that all tasks of the namespace have been reaped), but
> I considered it too ugly to propose it for Linux ;)

Well sometimes you have to go with what works.

Thanks for spotting those issue with my patch.  I guess it needs one more
pass before I can call it done.

> That said, this is probably the least intrusive solution we have seen yet.

Thanks for the review.  The bug where processes can escape a pid
namespace is really the reason I did it this way.  I also have the
patches needed to cleanly fix the pid namespace ref counting.
(Hopefully I can get them posted soon).  So if there was just the
ref counting bug I would drop this patch.

Eric
