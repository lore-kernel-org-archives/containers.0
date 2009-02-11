From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: namespaces?: bug at mm/slub.c:2750
Date: Wed, 11 Feb 2009 15:21:42 -0600
Message-ID: <20090211212142.GA3696@us.ibm.com>
References: <20090211172416.GA30756@us.ibm.com> <20090211163753.GA29372@us.ibm.com> <20090206113556.GA3161@alice> <20090206161518.81e7d42c.akpm@linux-foundation.org> <19f34abd0902102355o5bf51096o9aa3737e87104fb9@mail.gmail.com> <20090211000740.f1de7cec.akpm@linux-foundation.org> <19f34abd0902110248n22f8de12lccfa99faafafb942@mail.gmail.com> <1538.1234371764@redhat.com> <2532.1234375381@redhat.com> <6369.1234384961@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757891AbZBKVWL@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6369.1234384961@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Cc: Vegard Nossum <vegard.nossum@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Sesterhenn <snakebyte@gmx.de>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells@redhat.com):
> Serge E. Hallyn <serue@us.ibm.com> wrote:
> 
> > Yes, but noone will pull the user_struct off the list without
> > taking the lock.
> > 
> > what am I missing?
> 
> I believe that the hash link (uidhash_node) in the user_struct that is passed
> to uid_hash_remove() points to, and is pointed to by the user_namespace to
> which the user_struct belongs.
> 
> In which case calling put_user_ns() may kfree the head pointer of the list
> _before_ hlist_del_init() is invoked - in which case hlist_del_init() will act
> upon freed memory.
> 
> At least, I think it works like this.

Yikes, you're right.  I was thinking there was on hash table with
the key calculated from ns+uid, but instead each ns has its own
hash table keyed on uid.

> Anyway, I have no objection to your new patch.
> 
> Acked-by: David Howells <dhowells@redhat.com>

thanks,
-serge
