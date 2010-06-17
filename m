From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Thu, 17 Jun 2010 23:36:38 +0200
Message-ID: <20100617213638.GB4182@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <4C19F0A3.2050707@parallels.com> <m1631hdbdu.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1631hdbdu.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Louis Rilling <louis.rilling@kerlabs.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 06/17, Eric W. Biederman wrote:
>
> The task->children isn't changed until __unhash_process() which runs
> after flush_proc_task().

Yes. But this is only the current implementation detail.
It would be nice to cleanup the code so that EXIT_DEAD tasks are
never sit in ->children list.

> So we should be able to come up with
> a variant of do_wait() that zap_pid_ns_processes can use that does
> what we need.

See above...

Even if we modify do_wait() or add the new variant, how the caller
can wait for EXIT_DEAD tasks? I don't think we want to modify
release_task() to do __wake_up_parent() or something similar.

Oleg.
