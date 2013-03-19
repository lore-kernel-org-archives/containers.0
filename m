From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/4] fs: allow dev accesses in userns in controlled
	situations
Date: Tue, 19 Mar 2013 16:29:13 -0700
Message-ID: <87y5djhsty.fsf@xmission.com>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<1363338823-25292-3-git-send-email-glommer@parallels.com>
	<20130315142045.GD3782@sergelap>
	<CAE=Ncradvs_twWT8b6NQz85dm-Y8ayTH7NFv=i0vjYXpRBW9sg@mail.gmail.com>
	<20130319153740.GA21908@sergelap>
	<CAE=NcrYeKQYqkPsB9FG5PpYd2VTqmTszfpY39aRJqR=vsXfa7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAE=NcrYeKQYqkPsB9FG5PpYd2VTqmTszfpY39aRJqR=vsXfa7w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Janne Karhunen's message of "Tue, 19 Mar 2013 18:52:38 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Tue, Mar 19, 2013 at 5:37 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
>
>>> > Well the devcg was meant to be a temporary stopgap solution until we
>>> > have device namespaces, and this seems to entrench them further, but
>>> > it does make sense.
>>>
>>> Just out of interest, what would such device namespace actually
>>> do other than switch the device access on/off according to callers
>>> namespace?
>>
>> It could also support mapping of <type>:maj:min inside namespace to
>> a different device on host.  In most cases we probably don't actually
>> want that, but it's an interesting enough thing to be worth thinking
>> through.
>
> It sounds to me that what you really want to do is likely use case and
> device specific. Hence the idea about namespace specific ioctl device
> action(s) might not be so bad. It would certainly be less intrusive than
> tampering with device registrations or rerouting nod file_operations for
> instance.
>
> Classic on/off toggle case is easy though, but are there enough
> reasons for merging such 'noop' namespace?

The two most compelling cases are:
- Container migration.
- Safe creation of virtual devices.

Now I think we can solve container migration by effectively hotuplugging
and hotplugging all of our devices.

The safe creation of virtual devices that I am thinking of are
essentially ptys (already covered with devpts) and loopback devices.
There are probably a couple more that I don't know off the top of my
head.

So far I haven't found any case that is sufficiently compelling, and
can't be replaced by acting like devtmpfs and controlling all device
creation.  Although I have heard of cases where applications still call
mknod even with devtmpfs and udev doing most of the work.

I am of the general thought that we should explore what we can do with
what we have now, at least until we find a compelling case for doing
more in the kernel.

Eric
