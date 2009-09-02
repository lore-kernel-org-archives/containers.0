From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH 3/3] c/r: [pty 2/2] support for pseudo terminals
Date: Wed, 02 Sep 2009 19:43:31 -0400
Message-ID: <4A9F0323.2090000@librato.com>
References: <1250642549-23656-1-git-send-email-orenl@librato.com>
	<1250642549-23656-4-git-send-email-orenl@librato.com>
	<20090902144837.GA15116@us.ibm.com> <4A9EF7A9.4060507@librato.com>
	<20090902230549.GB26324@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090902230549.GB26324-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>> Thanks for the patches (the first was already in). I'll leave
>> out the change to signed type, though.
> 
> Yup, "oops".
> 
>> Serge E. Hallyn wrote:
>>> All right, I'm not sure how to go about this - i want to have a conversation
>>> involving patches without making it seem like I want any of the patches
>>> pushed yet :)  To get this working on s390, I needed the two attached
>>> patches.  Then the testcase under git://git.sr71.net/~hallyn/cr_tests.git
>>> under cr_tests/pty/ passes with your code.
>>>
>>> I'd still like to get a more invasive approach working where we directly
>>> ask the pty code to create the pty with the right index.  I'm playing with
>>> it right now, but of course having some trouble figuring out what to do
>>> for the master end and how best to construct a filp to pass to
>>> the main pty_create function.  I'll take a few more stabs and send out
>>> what I have later (or announce defeat).
>>>
>>> There is certainly something to be said for the un-invasiveness of
>>> your approach (and that it works).
>>>
>>> In either case, we will need to figure out how to deal with devpts
>>> namespaces.  Perhaps we separately checkpoint a 'devpts_mnt'.  It
>>> just stores the mountpoint of the mount.  At restart, we don't
>>> recreate those, we just confirm that the mountpoints still exist.
>>> Then, each pty entry has a ref to its devpts mount, and we use the
>>> mountpoint to construct ${mountpoint}/ptmx and pass that to
>>> filp_open() or ptmx_create)( to create the pty entry.
>> Yes, I was thinking along these lines. I think it's very much
>> related to the whole mount-namespaces issues; I guess it's time
>> to address both.
> 
> Ooooh, I'm not sure it is :)  In fact my approach to devpts should
> artfully avoid having to address generic mounts namespaces :)

lol .. I suppose I misinterpreted then. Perhaps you can take a
stab at it ?

> 
> Well, if we *were* to address mountsns now, I'd suggest we simply
> store meaningful /proc/pid/mountinfo data for each task in the
> checkpoint image, and just verify it at restart, returning error
> if they're not the same.  That way we can continue to defer
> the decision on whether mktree or the kernel will restore mounts.

What is "meaningful" data, and how would you "verify" it ?

At restart the mount data may be substantially (and intentionally)
different. For instance, what used to be a local mount at checkpoint
may be an NFS mount at restart....

Oren.
