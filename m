From: =?UTF-8?B?xYF1a2FzeiBTb3dh?= <luksow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] cgroup: syscalls limiting subsystem
Date: Thu, 03 Nov 2011 20:18:51 +0100
Message-ID: <4EB2E91B.5060705@gmail.com>
References: <4E9E17F4.7080306@gmail.com>
	<CALdu-PDzw=6oGBU25K0TSAckuRmfQOnA6Aw-WZJkxLj1LyvNWg@mail.gmail.com>
	<4EA0935C.4020605@gmail.com>
	<CABqD9hY0A4EBP+C4uJvrhtFZKr=S3GV_js5Z2bhmmZbVgOkKUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CABqD9hY0A4EBP+C4uJvrhtFZKr=S3GV_js5Z2bhmmZbVgOkKUw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Thanks a lot for all valuable remarks and for supporting the idea!

> 
> Have you considered doing this as a system call namespace instead of a
> cgroup?  (Just curious!)
> 

Yes, I have but I didn't see any advantages of system call namespace
over cgroup (maybe I missed something?). However, I think that using
namespace is in this particular case harder - less dynamic and thus less
useful.

> Have you considered using the semi-slow path used by auditsc? It uses
> a thread_info flag but doesn't take the completely slow-path if _only_
> audit is selected.  You may be able to get by with a new TIF flag that
> fits in with the same mask that is always called for all syscalls,
> then only fork if the process is in a filtered cgroup.  It will be
> messy to ensure all the paths work correctly, but it should mean that
> the overhead for normal applications is unchanged, and you might avoid
> the total slow-path overhead (just something similar to audit
> overhead).

I will try thread_info flag in next patch series. However, what I am
worried about is breaking consistency when you end up having processes
in a cgroup that does nothing because of TIF flags set. Another dirty
thing is that the TIF flag cannot be hierarchical (cannot be inherited)
so it's somehow breaking the idea of cgroups.
Another thing - what's better in using TIF flag instead of a per-cgroup
variable (held internally in struct) - is the performance that makes the
difference?

> That said, your approach won't work on platforms which offset system
> call start points, have gaps, and different ABI modes which change
> those.  You might want to consider a btree or something that doesn't
> need a pre-allocated array, etc.
> 
> (If not, you'll need to populate helpers for arches that need it to
> get their starting number for the current abi and the max numbers and
> then make sure processes either can't flip-flop, like CONFIG_COMPAT,
> and exceed the sized array.  But perhaps the btree lookup cost is too
> much.)

That sounds worrying. Could you elaborate on that? I'm not very
other-arches-aware and those things may be important for future work.

> 
> Have you considered supporting ftrace filters?
> 

No I haven't yet. Now, I'm reading through the seccomp patchset (and
discussion) you mentioned. At first glance it seems a nice idea but it
looks like a hard task to get it right. Another thing - isn't the
performance really bad when using those filters?

> Good luck - I look forward to seeing your next patch series!

I hope to post another patch for RFC next week. I will implement Paul's
remarks and TIF flag option and measure the performance again. I'm
looking forward to a nice and fruitful discussion then :).

Thanks,
Lukasz Sowa
