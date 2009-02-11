From: David Howells <dhowells@redhat.com>
Subject: Re: [CRED bug?] 2.6.29-rc3 don't survive on stress workload
Date: Wed, 11 Feb 2009 12:54:06 +0000
Message-ID: <27972.1234356846@redhat.com>
References: <20090211212208.C3C6.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210142443.629E.KOSAKI.MOTOHIRO@jp.fujitsu.com> <19f34abd0902092310g513fb776s2e4d37285c8fa7be@mail.gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756232AbZBKMz3@vger.kernel.org>
In-Reply-To: <20090211212208.C3C6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: dhowells@redhat.com, Vegard Nossum <vegard.nossum@gmail.com>, Serge Hallyn <serue@us.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Eric Sesterhenn <snakebyte@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> f6  : 1003e6b6b6b6b6b6b6b6b f7  : 0ffe6af8e85a500000000

I'd guess you now have CONFIG_DEBUG_SLAB turned on.  That looks like slab
poisoning in register f6.

> r17 : 00000000dead4ead r18 : a000000100cd2274 r19 : a000000100d6b6c0

And that looks like SPINLOCK_MAGIC in r17, so I'd guess something just
successfully validated a spinlock, possibly atomic_dec_and_lock() in
free_uid().

This may mean that the user_struct being released is valid, but the
user_namespace it refers to is already released.

David
