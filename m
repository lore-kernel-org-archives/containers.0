From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
Date: Thu, 1 Mar 2018 17:44:14 +0000
Message-ID: <CALCETrWugC-M-b2hhKu+Zq6W4w6vDn+bDCURLw48Loa+_SQaqA@mail.gmail.com>
References: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
	<20180226230418.46nczgkh5csakyu7@ast-mbp>
	<CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g@mail.gmail.com>
	<CALCETrXNODxWkcwF-LbXBn+Ju7QJEyi3JR+spsRX4ecg8d1iMQ@mail.gmail.com>
	<CAGXu5j+64WzxjBnpQxYCU50ak+VqVw1y0W+MWygFodxsDqEZRw@mail.gmail.com>
	<db759dd2-31dc-d094-251d-d4c1e8af8704@oracle.com>
	<CAGXu5j+idW9AjZHVdeedqLOFXriObUJLvcw8-9k5WxyQF8EWrg@mail.gmail.com>
	<ddbefdda-f3b8-3956-fa0f-dcba8cf8e7d9@oracle.com>
	<f712a383-8e84-da64-a454-51fdebf28741@iogearbox.net>
	<7fc0fab8-c1bc-bc76-a892-b3faab7d16ad@oracle.com>
	<4fbef77e-92ad-b896-a259-492412ad4c55@oracle.com>
	<19cd2e07-5702-1713-6903-e5667250b09d@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <19cd2e07-5702-1713-6903-e5667250b09d-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 28, 2018 at 7:56 PM, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org> wrote:
> On 02/28/2018 12:55 AM, chris hyser wrote:
>>> On 02/27/2018 04:58 PM, Daniel Borkmann wrote: >> On 02/27/2018 05:59 PM, chris hyser wrote:
>>>>> On 02/27/2018 11:00 AM, Kees Cook wrote:
>>>>>> On Tue, Feb 27, 2018 at 6:53 AM, chris hyser <chris.hyser-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
>>>>>>> On 02/26/2018 11:38 PM, Kees Cook wrote:
>>>>>>>> On Mon, Feb 26, 2018 at 8:19 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
>>>>>>>> wrote:
>>>>>>>>>
>>>>>>>>> 3. Straight-up bugs.  Those are exactly as problematic as verifier
>>>>>>>>> bugs in any other unprivileged eBPF program type, right?  I don't see
>>>>>>>>> why seccomp is special here.
>>>>>>>>
>>>>>>>> My concern is more about unintended design mistakes or other feature
>>>>>>>> creep with side-effects, especially when it comes to privileges and
>>>>>>>> synchronization. Getting no-new-privs done correctly, for example,
>>>>>>>> took some careful thought and discussion, and I'm shy from how painful
>>>>>>>> TSYNC was on the process locking side, and eBPF has had some rather
>>>>>>>> ugly flaws in the past (and recently: it was nice to be able to say
>>>>>>>> for Spectre that seccomp filters couldn't be constructed to make
>>>>>>>> attacks but eBPF could). Adding the complexity needs to be worth the
>>>>
>>>> Well, not really. One part of all the Spectre mitigations that went upstream
>>>> from BPF side was to have an option to remove interpreter entirely and that
>>>> also relates to seccomp eventually. But other than that an attacker might
>>>> potentially find as well useful gadgets inside seccomp or any other code
>>>> that is inside the kernel, so it's not a strict necessity either.
>>>>
>>>>>>>> gain. I'm on board for doing it, I just want to be careful. :)
>>>>>>>
>>>>>>> Another option might be to remove c/eBPF from the equation all together.
>>>>>>> c/eBPF allows flexibility and that almost always comes at the cost of
>>>>>>> additional security risk. Seccomp is for enhanced security yes? How about a
>>>>>>> new seccomp mode that passes in something like a bit vector or hashmap for
>>>>>>> "simple" white/black list checks validated by kernel code, versus user
>>>>>>> provided interpreted code? Of course this removes a fair number of things
>>>>>>> you can currently do or would be able to do with eBPF. Of course, restated
>>>>>>> from a security point of view, this removes a fair number of things an
>>>>>>> _attacker_ can do. Presumably the performance improvement would also be
>>>>>>> significant.
>>>>
>>>> Good luck with not breaking existing applications relying on seccomp out
>>>> there.
>>>
>>> This wasn't in the context of an implementation proposal, but the assumption would be to add this in addition to the old way. Now, does that make sense to do? That is the discussion.
>
> I see; didn't read that out from the above when you also mentioned removing
> cBPF, but fair enough.
>
>>>>>>> Is this an idea worth prototyping?
>>>>>>
>>>>>> That was the original prototype for seccomp-filter. :) The discussion
>>>>>> around that from years ago basically boiled down to it being
>>>>>> inflexible. Given all the things people want to do at syscall time,
>>>>>> that continues to be true. So true, in fact, that here we are now,
>>>>>> trying to move to eBPF from cBPF. ;)
>>>>
>>>> Right, agree. cBPF is also pretty much frozen these days and aside from
>>>> that, seccomp/BPF also just uses a proper subset of it. I wouldn't mind
>>>> doing something similar for eBPF side as long as this is reasonably
>>>> maintainable and not making BPF core more complex, but most of it can
>>>> already be set in the verifier anyway based on prog type. Note, that
>>>> performance of seccomp/BPF is definitely a demand as well which is why
>>>> people still extend the old remaining cBPF JITs today such that it can
>>>> be JITed also from there.
>>>>
>>>>> I will try to find that discussion. As someone pointed out here though, eBPF is being used by more and more people in areas where security is not the primary concern. Differing objectives will make this a long term continuing issue. We ourselves were looking at eBPF simply as a means to use a hashmap for a white/blacklist, i.e. performance not flexibility.
>>>>
>>>> Not really, security of verifier and BPF infra in general is on the top
>>>> of the list, it's fundamental to the underlying concept and just because
>>>> it is heavily used also in tracing and networking, it only shows that the
>>>> concept is highly flexible that it can be applied in multiple areas.
>>
>> If you're implying that because seccomp would have it's own verifier and could therefore restrict itself to a subset of eBPF, therefore any future additions/features to eBPF would not necessarily make seccomp less secure, I mainly agree. Is that the argument?
>
> Ok, in addition to the current unpriv restrictions imposed by the verifier,
> what additional requirements would you have from your side in order to get
> to semantics that make sense for you wrt seccomp/eBPF? Just trying to
> understand how far we are away from that. Note that not every new feature,
> map or helper is enabled for every program type of course.
>

I haven't looked at the exact unpriv restrictions lately, but I think
I remember them.  Regardless, from my perspective, here's what I would
care about as a seccomp reviewer:

1. No extra information should become available to a seccomp filter
program without seccomp's explicit opt-in.  In other words, a seccomp
filter program should be able to access the fields in struct
seccomp_data, the return values of BPF_CALL helpers explicitly
authorized by seccomp, and the values in maps authorized by seccomp
(if any!), and that's it.  They should not be able to learn the
current time, any kernel pointers, user register state (except that
which is contained in seccomp_data), etc.  I believe that this is
already the case except insofar as core BPF_CALL helpers may violate
this.  (I'm not sure exactly what the policy is on the use of BPF_CALL
helpers.)

2. Filter evaluation should have no side effects except as explicitly
authorized by seccomp or by systemwide tracing.  So perf observing
that a seccomp filter ran is fine, but seccomp filters should not be
able to write to the system log, to perf ring buffers, to maps, etc.

3. Stability.  If a filter passes verification on two different
kernels, it should behave the same on both kernels, even if the filter
is buggy in some theoretical sense.

And that's it.  Obviously the attack surface provided by the ability
to load and run a filter should be minimized, but that's true for eBPF
in general and has little to do with seccomp in particular.

#1 and #2 are probably fairly straightforward using existing
mechanisms, unless the BPF_CALL hooks or map authorization hooks for
program types need to be extended a bit to get it right.  #3 is maybe
more interesting, but I imagine that XDP and any upcoming bpf-based
iptables replacement have the same requirement.  In contrast, bpf
*tracing* doesn't really require #3 to the same extent -- it's really
such an awful thing if a buggy or otherwise naughty bpf tracing
program behaves differently after a kernel upgrade.

I suppose that another way of saying this is that an eBPF seccomp
program should behave like a pure function except to the extent that
the seccomp core makes an explicit exception.

I'm not terribly concerned about the additional attack surface exposed
by eBPF itself.  Sure, it's more dangerous to allow a sandboxed
program to load its own eBPF programs than to allow a sandboxed
program to load its own cBPF programs, but such is the price of
progress.  If I'm writing a restrictive sandbox a la chromium's, I'm
not going to allow it to load eBPF programs, but I can still use eBPF
to enforce the sandbox policy.

--Andy
