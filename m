From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
	Vpid:)
Date: Thu, 16 Jun 2011 16:51:10 +0200
Message-ID: <20110616145044.GA25379@redhat.com>
References: <20110615145527.4016.70157.stgit@bahia.local> <20110615184625.GA15573@redhat.com> <1308222107.8230.49.camel@bahia.local> <20110616123554.GA7230@hawkmoon.kerlabs.com> <1308229251.8230.77.camel@bahia.local> <20110616132551.GB7230@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110616132551.GB7230@hawkmoon.kerlabs.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>, linux-kernel@vger.kernel.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On 06/16, Louis Rilling wrote:
>
> On 16/06/11 15:00 +0200, Greg Kurz wrote:
> > peeking into pid->numbers.
>
> It ends like open-coding an optimized version of task_pid_vnr(). If the
> optimization is really important (I guess this depends on the depth of recursive
> pid namespaces), it would be better to re-write task_pid_vnr().

No, task_pid_vnr(p) is different, it should use the caller's namespace.

Just in case, I agree there is no need to optimize this code. The simpler
the better. I mentioned pid->numbers[pid->level] just to point that all
we need is task_pid() itself, there are no subtle races which need the
locking.

Oleg.
