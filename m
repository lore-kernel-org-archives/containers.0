From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/10] cgroups: Task counter subsystem v8
Date: Mon, 1 Apr 2013 17:07:49 -0700
Message-ID: <CAAAKZwt+7w67Kft+MbCXqtCQpOU5B6+6PAdZTCDyAGQQPCGz=w@mail.gmail.com>
References: <1328067470-5980-1-git-send-email-fweisbec@gmail.com>
	<CAAAKZwv9=NFmt6xj1KF2va1i6=UCvka0YkmdOY9JNUMHDOWpGw@mail.gmail.com>
	<20130401184617.GB31435@htj.dyndns.org>
	<CAAAKZwvemKDLeuKr6wWMUSVczkRVDZKSzYrXXEMcZ8qvcFR0zQ@mail.gmail.com>
	<20130401202943.GC31435@htj.dyndns.org>
	<CAAAKZwuZwN68vtk1qO08GXB_OnQNVtqqp+v_NQfP27W0P_aWZw@mail.gmail.com>
	<20130401220309.GA2487@htj.dyndns.org>
	<CAAAKZwuev7Y58ZQNtG+XdFRt0=NedD7zbYTAZbJ95ahBKLVhKA@mail.gmail.com>
	<20130401223500.GB2487@htj.dyndns.org>
	<CAAAKZwvdMUAZ+N5d-cdCJbKUq=t9M6BbCxzOTWnVQQBrg55vhw@mail.gmail.com>
	<20130401231824.GC2487@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130401231824.GC2487-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Apr 1, 2013 at 4:18 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello,
>
> On Mon, Apr 01, 2013 at 03:57:46PM -0700, Tim Hockin wrote:
>> I am not limited by kernel memory, I am limited by PIDs, and I need to
>> be able to manage them.  memory.kmem.usage_in_bytes seems to be far
>> too noisy to be useful for this purpose.  It may work fine for "just
>> stop a fork bomb" but not for any sort of finer-grained control.
>
> So, why are you limited by PIDs other than the arcane / weird
> limitation that you have whereever that limitation is?

Does anyone anywhere actually set PID_MAX > 64K?  As far as I can
tell, distros default it to 32K or 64K because there's a lot of stuff
out there that assumes this to be true.  This is the problem we have -
deep down in the bowels of code that is taking literally years to
overhaul, we have identified a bad assumption that PIDs are always 5
characters long.  I can't fix it any faster.  That said, we also
identified other software that make similar assumptions, though they
are less critical to us.

>> > If you think you can tilt it the other way, please feel free to try.
>>
>> Just because others caved, doesn't make it less of a hack.  And I will
>> cave, too, because I don't have time to bang my head against a wall,
>> especially when I can see the remnants of other people who have tried.
>>
>> We'll work around it, or we'll hack around it, or we'll carry this
>> patch in our own tree and just grumble about ridiculous hacks every
>> time we have to forward port it.
>>
>> I was just hoping that things had worked themselves out in the last year.
>
> It's kinda weird getting this response, as I don't think it has been
> particularly walley.  The arguments were pretty sound from what I
> recall and Frederic's use case was actually better covered by kmemcg,
> so where's the said wall?  And I asked you why your use case is
> different and the only reason you gave me is some arbitrary PID
> limitation on whatever thing you're using, which you gotta agree is a
> pretty hard sell.  So, if you think you have a valid case, please just
> explain it.  Why go passive agressive on it?  If you don't have a
> valid case for pushing it, yes, you'll have to hack around it - carry
> the patches in your tree, whatever, or better, fix the weird PID
> problem.

Sorry Tejun, you're being very reasonable, I was not.  The history of
this patch is what makes me frustrated.  It seems like such an obvious
thing to support that it blows my mind that people argue it.

You know our environment.  Users can use their memory budgets however
they like - kernel or userspace.  We have good accounting, but we are
PID limited.  We've even implemented some hacks of our own to make
that hurt less because the previously-mentioned assumptions are just
NOT going away any time soon.  I literally have user bugs every week
on this.  Hopefully the hacks we have put in place will make the users
stop hurting.  But we're left with some residual problems, some of
which are because the only limits we can apply are per-user rather
than per-container.

From our POV building the cluster, cgroups are strictly superior to
most other control interfaces because they work at the same
granularity that we do.  I want more things to support cgroup control.
 This particular one was double-tasty because the ability to set the
limit to 0 would actually solve a different problem we have in
teardown.  But as I said, we can mostly work around that.

So I am frustrated because I don't think my use case will convince you
(at the root of it, it is a problem of our own making, but it LONG
predates me), despite my belief that it is obviously a good feature.
I find myself hoping that someone else comes along and says "me too"
rather than using a totally different hack for this.

Oh well.  Thanks for the update.  Off to do our own thing again.


> --
> tejun
