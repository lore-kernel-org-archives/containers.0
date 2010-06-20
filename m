From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/6] Unshare support for the pid namespace.
Date: Sun, 20 Jun 2010 01:42:37 -0700
Message-ID: <m1pqzmqema.fsf_-_@fess.ebiederm.org>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<20100617212003.GA4182@redhat.com>
	<20100618082033.GD16877@hawkmoon.kerlabs.com>
	<20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com>
	<20100618173320.GG16877@hawkmoon.kerlabs.com>
	<20100618175541.GA13680@redhat.com>
	<20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100619190840.GA3424@redhat.com> (Oleg Nesterov's message of "Sat\, 19 Jun 2010 21\:08\:40 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg@redhat.com> writes:

> On 06/18, Oleg Nesterov wrote:
>>
>> I only try to discuss the idea to break the circular reference.
>
> I don't know what I have missed, but this looks really right to me.
> Besides, we have yet another problem: proc_flush_task()->mntput()
> is just wrong. Consider the multithreaded execing init.
>
> I am going to simplify, test, and send the fix which moves mntput()
> into free_pid_ns() paths.

free_pid_ns is comparatively late, to release the kern_mount.

> But first of all I think we should cleanup the pid_ns_prepare_proc()
> logic. Imho, this code is really ugly. Please see the patches.

Since I have a patchset that makes it possible to unshare the pid
namespace about ready to send I figure we should combine the two
efforts.

This patchset is a prerequisite to my patches for giving namespaces
file descriptors and allowing you to join and existing namespace.
When I look over my old notes it appears there Daniel managed to hit
this proc_mnt reference counting in that context.  So that is definitely
interesting.

Oleg take a look I think I have combined the best of our two patchsets.

Eric
