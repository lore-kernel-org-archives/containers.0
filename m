From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: namespaces?: bug at mm/slub.c:2750
Date: Wed, 11 Feb 2009 19:00:41 +0100
Message-ID: <19f34abd0902111000k59b3f3f2yac92d132976ece74@mail.gmail.com>
References: <20090211163753.GA29372@us.ibm.com> <20090206113556.GA3161@alice>
	 <20090206161518.81e7d42c.akpm@linux-foundation.org>
	 <19f34abd0902102355o5bf51096o9aa3737e87104fb9@mail.gmail.com>
	 <20090211000740.f1de7cec.akpm@linux-foundation.org>
	 <19f34abd0902110248n22f8de12lccfa99faafafb942@mail.gmail.com>
	 <1538.1234371764@redhat.com> <20090211172416.GA30756@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757739AbZBKSAy@vger.kernel.org>
In-Reply-To: <20090211172416.GA30756@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Sesterhenn <snakebyte@gmx.de>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-Id: containers.vger.kernel.org

On Wed, Feb 11, 2009 at 6:24 PM, Serge E. Hallyn <serue@us.ibm.com> wrote:
> Quoting David Howells (dhowells@redhat.com):
>> Serge E. Hallyn <serue@us.ibm.com> wrote:
>>
>> >  static void uid_hash_remove(struct user_struct *up)
>> >  {
>> > +   put_user_ns(up->user_ns);
>> >     hlist_del_init(&up->uidhash_node);
>> >  }
>>
>> Don't you need to do the hlist_del_init() first?  Otherwise, mightn't the
>> put_user_ns() cause the namespace to be freed before hlist_del_init() removes
>> the user_struct from it?
>
> It's called under uidhash_lock spinlock so should be ok, but in
> principle you're right so it's probably a good idea.
>
> The main point is that without this patch, put_user_ns is done before
> the hlist_del_init and *not* atomically under uidhash_lock.

Congrats, your (unmodified) patch made it through the first 20 minutes
of testing! :-D

(In comparison, the unpatched kernel would usually crash after ~3 minutes)

I wonder why you couldn't reproduce it, though.

KOSAKI Motohiro: You might want to see if this patch helps too. It is
here: http://lkml.org/lkml/2009/2/11/251


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
