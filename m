From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] pid_ns: move pid_ns_release_proc() from
	proc_flush_task() to zap_pid_ns_processes()
Date: Wed, 23 Jun 2010 23:36:30 -0700
Message-ID: <20100624063630.GB3016@us.ibm.com>
References: <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com> <20100623203652.GA25298@redhat.com> <20100623203735.GB25298@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100623203735.GB25298@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| This is mostly cleanup and optimization, but also fixes the bug.
| 
| proc_flush_task() checks upid->nr == 1 to detect the case when
| a sub-namespace exits. However, this doesn't work in case when
| a multithreaded init execs and calls release_task(old_leader),
| the old leader has the same pid 1.
| 
| Move pid_ns_release_proc() to zap_pid_ns_processes(), it is called
| when we know for sure that init is exiting.

Hmm, I almost agreed, but have a question :-)

Yes, we know that the container-init is exiting. But if its parent (in
the parent ns) waits on it and calls release_task(), won't we call
proc_flush_task_mnt() on this container-init ? This would happen after
dropping the mnt in zap_pid_ns_processes() no ?

At the time zap_pid_ns_processes() is called, the container-init is still
not in EXIT_ZOMBIE state right ? (Or does your statement below include
EXIT_DEAD and EXIT_ZOMBIE tasks ?)

| 
| Note: with or without this change this mntput() can happen before the
| EXIT_DEAD tasks not visible to do_wait() have passed proc_flush_task().
| We need more fixes.
| 

Sukadev
