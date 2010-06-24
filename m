From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/1] pid_ns: move pid_ns_release_proc() from
	proc_flush_task() to zap_pid_ns_processes()
Date: Thu, 24 Jun 2010 15:01:11 +0200
Message-ID: <20100624130111.GB7257@redhat.com>
References: <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <20100623203652.GA25298@redhat.com> <20100623203735.GB25298@redhat.com> <m1zkykgb8u.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1zkykgb8u.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On 06/24, Eric W. Biederman wrote:
>
> Oleg Nesterov <oleg@redhat.com> writes:
>
> > This is mostly cleanup and optimization, but also fixes the bug.
>
> Oleg with respect to your other patches I think they are some of
> the best ones we have on the table.
>
> > proc_flush_task() checks upid->nr == 1 to detect the case when
> > a sub-namespace exits. However, this doesn't work in case when
> > a multithreaded init execs and calls release_task(old_leader),
> > the old leader has the same pid 1.
> >
> > Move pid_ns_release_proc() to zap_pid_ns_processes(), it is called
> > when we know for sure that init is exiting.
>
> This actually guarantees a use after free for the namespace init:

Yes, thanks. I am stupid.

Please ignore the patch.

Oleg.
