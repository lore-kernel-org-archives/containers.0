From: David Howells <dhowells@redhat.com>
Subject: Re: namespaces?: bug at mm/slub.c:2750
Date: Wed, 11 Feb 2009 18:03:01 +0000
Message-ID: <2532.1234375381@redhat.com>
References: <20090211172416.GA30756@us.ibm.com> <20090211163753.GA29372@us.ibm.com> <20090206113556.GA3161@alice> <20090206161518.81e7d42c.akpm@linux-foundation.org> <19f34abd0902102355o5bf51096o9aa3737e87104fb9@mail.gmail.com> <20090211000740.f1de7cec.akpm@linux-foundation.org> <19f34abd0902110248n22f8de12lccfa99faafafb942@mail.gmail.com> <1538.1234371764@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757802AbZBKSD1@vger.kernel.org>
In-Reply-To: <20090211172416.GA30756@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: dhowells@redhat.com, Vegard Nossum <vegard.nossum@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Sesterhenn <snakebyte@gmx.de>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serue@us.ibm.com> wrote:

> It's called under uidhash_lock spinlock so should be ok, but in
> principle you're right so it's probably a good idea.

The lock is nothing to do with it.  put_user_ns() may call kfree() on the
user_namespace, but the user_struct given to uid_hash_remove() may still be
attached to it.

David
