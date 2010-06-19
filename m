From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/4] pid_ns_prepare_proc/unshare cleanups
Date: Sat, 19 Jun 2010 21:08:40 +0200
Message-ID: <20100619190840.GA3424@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com> <20100618212355.GA29478@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100618212355.GA29478@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 06/18, Oleg Nesterov wrote:
>
> I only try to discuss the idea to break the circular reference.

I don't know what I have missed, but this looks really right to me.
Besides, we have yet another problem: proc_flush_task()->mntput()
is just wrong. Consider the multithreaded execing init.

I am going to simplify, test, and send the fix which moves mntput()
into free_pid_ns() paths.

But first of all I think we should cleanup the pid_ns_prepare_proc()
logic. Imho, this code is really ugly. Please see the patches.

The last one, 4/4, is orthogonal to other changes.

Oleg.
