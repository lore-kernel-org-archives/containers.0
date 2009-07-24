From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by tgid
	at once
Date: Fri, 24 Jul 2009 14:36:18 -0700
Message-ID: <6599ad830907241436n7c004e01j349a473554236f65__7026.85491783104$1248471415$gmane$org@mail.gmail.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
	<20090724155041.GF5878@count0.beaverton.ibm.com>
	<6599ad830907240901w4fc02097k83d0c1012708e6ee@mail.gmail.com>
	<20090724172320.GH5878@count0.beaverton.ibm.com>
	<6599ad830907241047w9a9fff9q4dc68f26a9544398@mail.gmail.com>
	<2f86c2480907241353l63818dfehb20c9d4918a3f069@mail.gmail.com>
	<20090724210657.GL5878@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724210657.GL5878-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 24, 2009 at 2:06 PM, Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> Global rwsem: only needs one lock, but prevents all forking when a
>> write is in progress. It should be quick enough, if it's just "iterate
>> down the threadgroup list in O(n)". In the good case, fork() slows
>> down by a cache miss when taking the lock in read mode.
>
> I noticed your point about only one process contending for write on
> the new semaphore since cgroup_mutex is also held on the write side.
> However won't there be cacheline bouncing as lots of readers contend not
> for the read side of the lock itself but the cacheline needed to take it?

Yes, that's the "cache miss when taking the lock in read mode"
referred to by Ben in the paragraph above yours.

Paul
