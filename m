From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/1] pid_ns: move pid_ns_release_proc() from
	proc_flush_task() to zap_pid_ns_processes()
Date: Wed, 23 Jun 2010 22:36:52 +0200
Message-ID: <20100623203652.GA25298@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100619190840.GA3424@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 06/19, Oleg Nesterov wrote:
>
> But first of all I think we should cleanup the pid_ns_prepare_proc()
> logic. Imho, this code is really ugly. Please see the patches.
>
> The last one, 4/4, is orthogonal to other changes.

And the last one on top of this series, before I go away from this
thread ;)

Since my further fixes were not approved, I think at least it makes
sense to cleanup pid_ns_release_proc() logic a bit.

Oleg.
