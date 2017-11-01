From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 3/5] userns: Don't read extents twice in m_start
Date: Wed, 1 Nov 2017 19:15:46 +0100
Message-ID: <20171101181546.d7rw4tojr4nlf275@hirez.programming.kicks-ass.net>
References: <20171024220441.10235-1-christian.brauner@ubuntu.com>
	<20171024220441.10235-2-christian.brauner@ubuntu.com>
	<871sliubhj.fsf_-_@xmission.com> <87k1zaswu6.fsf_-_@xmission.com>
	<143adb61-fb8e-fc1b-396b-b18836e68766@suse.com>
	<87a806ntn0.fsf@xmission.com>
	<1509555601.31043.44.camel@perches.com>
	<87h8udj4p7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87h8udj4p7.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: tycho-E0fblnxP3wo@public.gmane.org, Nikolay Borisov <nborisov-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 01, 2017 at 12:20:52PM -0500, Eric W. Biederman wrote:

> Well the way I was hearing the conversation was that there was a patch
> that fixed a real bug, but it was wrong because checkpatch complained
> about it.
> 
> So I don't even know if the warning is a problem.  But blocking bug
> fixes because there is a warning certainly is.
> 
> If someone wants to change coding style in practice so that every
> smp_rmb and every smp_wmb has detailed comments that everyone must
> include they need to follow the usual rule and update the entire kernel
> when making an interface change.  As that did not happen I don't see
> any problems with incremental updates in the style the code is already
> in.

Reverse engineering all the memory barriers in the code is a massive
undertaking. We are looking at it, but its slow progress. Mostly an
update when touched approach.

Although some searching for dodgy patterns; see for example commit:

  a7af0af32171 ("blk-mq: attempt to fix atomic flag memory ordering")

which was the result of people looking at creative
smp_mb__{before,after}_atomic() usage -- in specific use of those
barriers not immediately adjacent to the respective atomic operation.

But to use the lack of completion of that work to not write comments on
code you understand is complete bollocks though.

> Not that I will mind a patch that updates the code, but I am not going
> to hold up a perfectly good bug fix waiting for one either.

If both you and the submitter actually understand the ordering, asking
them to write the comment isn't onerous and should not hold up anything
much at all.

In fact, if you cannot write that comment you cannot claim it to be a
good fix. And I'm saying the lack of the comment means its not a
perfectly good fix at all, since a perfect fix would indeed explain
memory ordering.
