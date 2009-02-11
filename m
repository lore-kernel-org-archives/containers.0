From: David Howells <dhowells@redhat.com>
Subject: Re: namespaces?: bug at mm/slub.c:2750
Date: Wed, 11 Feb 2009 20:42:41 +0000
Message-ID: <6369.1234384961@redhat.com>
References: <20090211193846.GB1344@us.ibm.com> <20090211172416.GA30756@us.ibm.com> <20090211163753.GA29372@us.ibm.com> <20090206113556.GA3161@alice> <20090206161518.81e7d42c.akpm@linux-foundation.org> <19f34abd0902102355o5bf51096o9aa3737e87104fb9@mail.gmail.com> <20090211000740.f1de7cec.akpm@linux-foundation.org> <19f34abd0902110248n22f8de12lccfa99faafafb942@mail.gmail.com> <1538.1234371764@redhat.com> <2532.1234375381@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757692AbZBKUoN@vger.kernel.org>
In-Reply-To: <20090211193846.GB1344@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: dhowells@redhat.com, Vegard Nossum <vegard.nossum@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Sesterhenn <snakebyte@gmx.de>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serue@us.ibm.com> wrote:

> Yes, but noone will pull the user_struct off the list without
> taking the lock.
> 
> what am I missing?

I believe that the hash link (uidhash_node) in the user_struct that is passed
to uid_hash_remove() points to, and is pointed to by the user_namespace to
which the user_struct belongs.

In which case calling put_user_ns() may kfree the head pointer of the list
_before_ hlist_del_init() is invoked - in which case hlist_del_init() will act
upon freed memory.

At least, I think it works like this.


Anyway, I have no objection to your new patch.

Acked-by: David Howells <dhowells@redhat.com>
