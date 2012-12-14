From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] user namespace and namespace infrastructure changes
	for 3.8
Date: Fri, 14 Dec 2012 09:48:54 -0800
Message-ID: <87vcc47ce1.fsf@xmission.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com>
	<CALCETrWxXZ1OzZeH_SGeg1E16rssxBwg+hjG09N5dkqweVKeRA@mail.gmail.com>
	<87mwxhff2e.fsf@xmission.com>
	<CALCETrXagfjy4o0_JCZpMfdocYK-MpOp3eH-tPZhgazvJAy-EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrXagfjy4o0_JCZpMfdocYK-MpOp3eH-tPZhgazvJAy-EQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Thu, 13 Dec 2012 21:34:22 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> On Thu, Dec 13, 2012 at 8:11 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>>
>>> One more issue: the requirement that both upper and lower uids (etc.)
>>> in the maps are in order is rather limiting.  I have no objection if
>>> you only require upper ids to be monotonic, but currently there's no
>>> way to may root outside to uid n (for n > 0) and some nonroot user
>>> outside to uid 0.
>>
>> There is.  You may set up to 5 (extents).  You just have to use a second
>> extent for the non-contiguous bits.  My reader is lazy and you have to
>> set all of the extents with a single write, so you may have missed the
>> ability to set more than one extent.
>>
>
> If I'm wrong, I'll happily eat my words.  Both:
>
> 0 1 1
> 1 0 1
>
> and
>
> 1 0 1
> 0 1 1
>
> are rejected, unless I totally messed up.

Duh.  You are right.  

It is this check:

		/* For now only accept extents that are strictly in order */
		if (last &&
		    (((last->first + last->count) > extent->first) ||
		     ((last->lower_first + last->count) > extent->lower_first)))
			goto out;

Fundamentally every value mapped must be distinct.  Aka the direction of
the mapping must be reversible without loss of information.  

Ensuring all of the values were increasing in the extents was just a
lame way of ensuring that the same value was not mapped twice in either
the upper or lower ranges.

That check can most certainly be relaxed (patches welcome).  But that
probably isn't 3.8 material as that is feature work.

Not having bumped into this limitation myself I'm not certain the value
in removing this check.  But there is no good reason not to replace the
current check with a more general one either.

So your example should work, and that it doesn't is a misfeature.

Eric
