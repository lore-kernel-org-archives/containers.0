From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: netns: Issues with deleting virtual interfaces during namespace
	cleanup
Date: Sun, 27 Feb 2011 01:02:47 -0800
Message-ID: <m18vx197ew.fsf@fess.ebiederm.org>
References: <4D69316F.4000606@ll.mit.edu> <4D697F6A.9000907@free.fr>
	<AANLkTinQQHKiujHNet07kbK5eqYvp6-2iBnn27v2-85+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTinQQHKiujHNet07kbK5eqYvp6-2iBnn27v2-85+-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Renato Westphal's message of "Sun, 27 Feb 2011 02:16:23 -0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Renato Westphal <renatowestphal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, "Ward,
	David - 0663 - MITLL" <david.ward-OVIABD91gjs3uPMLIKxrzw@public.gmane.org>
List-Id: containers.vger.kernel.org

Renato Westphal <renatowestphal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Hello David,
>
> You may try the patch below (kernel v2.6.35) and see if that helps. It
> basically does what you asked for: during namespace cleanup, move back the
> virtual interfaces to their original namespaces. I did some tests with veth
> pairs and nested netns's and everything worked fine.
>
> I think this should be the default behaviour, I would like if someone could
> review/fix this patch and push it upstream.

I think this approach of pushing virtual network devices back where they
came from is a bad idea.  All of the desired benefits can be obtained by
using an extra veth pair and ethernet bridging.  The current semantics
make it difficult to leak virtual network devices by accident.  The
suggested patch fails hard when the originating network namespace exits
before the target network namespace, and I would contend that is a
fundamentally hard problem and will lead to complicated code.  Finally I
don't see what is gained by changing the current semantics.

Eric
