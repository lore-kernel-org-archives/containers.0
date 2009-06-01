From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 7/7] Define clone_with_pids syscall
Date: Mon, 01 Jun 2009 15:35:02 -0400
Message-ID: <4A242D66.2070907@cs.columbia.edu>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000350.GF4191@us.ibm.com>
	<20090601151650.GA20295@us.ibm.com>
	<4A240213.70001@cs.columbia.edu>
	<20090601164232.GA23252@us.ibm.com>
	<4A2407B2.8030304@cs.columbia.edu>
	<20090601171943.GA23878@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090601171943.GA23878-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>> One last thought - should there be an explicit check to make sure that
>>> if CLONE_NEWPID, then at the end pid[knum_pids+1] = 0?  Or is that
>>> there and I just missed it?
>> the wonders of kzalloc() ...
> 
> No.  I'm saying that I don't see anything stopping the user from
> doing CLONE_NEWPID while specifying an extra pid, so that they
> end up trying to create a pidns init with vpid 5

The last slot in the array is always zero. The size of the array
is parent's nesting level + 2 (one for counting from zero, and
one for the new pidns, if any).

In your example, the parent is in level 2, so the array is of
size 4. The parent should provide an array of size 2, and then
clone_with_pid() will attempt to set pids of the child at levels
1 and 2 (level 0 is set by the kernel).

If however the parent gives an array of size 3, clone_with_pid()
will try to set pids of the child at level 0, 1 and 2 instead.
level 3 is below the parent, and will always use the last slot
in the (kernel) array.

Finally, for an array of size 4, clone_with_pid() will return
an error.

Did I entirely misread your question ?

Oren.
