From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/6][RFC] user-cr: restart: Make task table portable
Date: Mon, 08 Feb 2010 18:26:08 -0500
Message-ID: <4B709D90.6000605@cs.columbia.edu>
References: <1265666243-29046-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265666243-29046-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Matt,

Thanks for the patch-set.

Matt Helsley wrote:
> This series modifies the task table entries to use indexes rather than
> pointers to create the tree. This is one step that enables the same
> table to be shared between multiple restart processes regardless of
> whether they are 32 or 64-bit.
> 
> Further steps, not in this set, include:
> 	1. Mark bitness of each task in the table.
> 	2. Share the table contents.
> 		Probably via an fd passed during execve() then mmap()'ed

As I said before, I'm concerned about the security implications.

Assume the 'restart' is setuid.

When 'restart' starts with a switch, e.g. --cont-fd=FD --cont-nr=NN,
it will map that FD to memory and expect valid data there. But what
if the data is bogus ?

At the very least, we'll need to verify that the data in the array
is valid. That is, iterating through entries to verify contents.

(We might as well pass the data via a pipe and make a local copy of
the data at the exec'ed instance)


> 	3. Find/modify restart to do execve() at the right spot.
> 
> The patches:
> 	1/6 Make context global

I suppose this is only necessary to because the ->ctx pointer in
the @task will be invalid in the address space of the exec'ed
instance.

To avoid the need for @ctx as global, we can (as noted above) make
a local copy of the tasks array and set adjust the @ctx pointer in
each entry.

I actually want to remove globals altogether, so that we can make
the restart functionality available as a library. Unfortunately I'm
not sure it's possible because we use most of them in the signal
handling context.

Ideas are welcome.


> 	2/6 Replace children pointer with index
> 	3/6 Replace next_sib pointer with an index
> 	4/6 Replace prev_sib pointer with index
> 	5/6 Replace phantom pointer with index
> 	6/6 Replace creator pointer with index

The rest of them look clean.

Oren.


> 
> Each patch converts one of the fields to an index while leaving the
> others untouched. Should be bisect safe, but feel free to merge the
> patches if you like.
> 
> (These are RFC since they aren't properly tested and don't actually
> make restart do the 32/64-bit transitions but feel free to include
> them if you like.)
> 
> Cheers,
> 	-Matt Helsley
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
