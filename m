From: Benny Amorsen <benny+usenet-sjWZyPj6pFx/SzgSGea1oA@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH] IP address restricting cgroup subsystem
Date: Sun, 11 Jan 2009 01:25:05 +0100
Message-ID: <m37i523d0e.fsf@ursa.amorsen.dk>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	<6599ad830901091358m11effdbegeff6cbb7ee28e262@mail.gmail.com>
	<20090110112009.GA12336@megiteam.pl>
	<6599ad830901100821q2c943d38i314c00f7db51b4f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830901100821q2c943d38i314c00f7db51b4f0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Paul Menage's message of "Sat\, 10 Jan 2009 08\:21\:53 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <public-menage-hpIqsD4AKlfQT0dZR+AlfA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>
Cc: Grzegorz Nosek <public-root-AfQBxy1nhrQ00sYp1HPQUA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>, public-containers-qjLDD68F18O7TbgM5vRIOg-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org
List-Id: containers.vger.kernel.org



Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org> writes:

> Oh, and don't forget being able to control remote addresses/ports too.
> E.g. you might not care what local port/address something binds to (or
> there may only be one local address anyway) but you might want to
> restrict a cgroup from e.g. connecting outside your data center, etc.
> (Something that I'm interested in).

If it's going to be that advanced, it will end up either like iptables
or like routing tables.

It is a bit much to expect normal applications to use either, but
iptables is especially complicated. I am a little bit tempted by
something resembling routing/rule tables, but it would obviously have
to be a bit more limited. E.g. gateway addresses should not be stored
there at all.

There is also the classic question: What happens if you invoke a
setuid or setgid executable with restrictions in effect? It is hard to
guarantee that this isn't exploitable in any way.


/Benny
