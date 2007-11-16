From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: netns refcounting
Date: Fri, 16 Nov 2007 10:14:40 -0700
Message-ID: <m1mytew1rz.fsf@ebiederm.dsl.xmission.com>
References: <473DA358.9040705@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473DA358.9040705-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Fri, 16
	Nov 2007 17:04:08 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

> Hello, All!
>
> During port of Eric's patches I have noticed an interesting thing.
> The patch "net: Teach the ipv4 route cache to handle multiple network
> namespaces" call hold_net for each IPv4 DST cache entry.
>
> Though it is not possible to stop a namespace without stopping all the
> devices inside. Additionally, the device can't be unregistered if there
> are dst entries to it. These entries are moved to a namespace loopback
> and the namespace will block until these entries will gone from a loopback.
>
> So, I do not see a necessity to have an extra atomic on this hot path,
> i.e. hold_net can re moved away for this. Are there any holes?

So all hold_net is good for is to catch logic errors where people are
still using a network namespace but have freed it.  It is a bit like
the device reference count in that regard.

The usage of the dst cache from ipv4 looked complicated enough that making
some small mistake easy to have so I included the reference count for good
measure.

If the movement to loopback device is sufficient to prevent us from goofing
up in this area I am happy to avoid the reference count.

Eric
