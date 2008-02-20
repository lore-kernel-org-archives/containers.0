From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 1/7] CGroup API: Add cgroup.api control file
Date: Tue, 19 Feb 2008 18:51:29 -0800
Message-ID: <6599ad830802191851l66281e67rb49c766c2b1427c9__3545.17427408627$1203476011$gmane$org@mail.gmail.com>
References: <20080215204418.535025000@menage.corp.google.com>
	<20080215204820.734926000@menage.corp.google.com>
	<47B6B5CA.7040201@linux.vnet.ibm.com>
	<6599ad830802160944v6d529570k1ade6df273ca3d0d@mail.gmail.com>
	<47B953A8.9030206@cn.fujitsu.com> <20080219155742.0298f25f.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080219155742.0298f25f.pj-sJ/iWh9BUns@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Feb 19, 2008 1:57 PM, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> wrote:
>
> Finally, it goes against the one thingie per file (at most, one scalar
> vector) that has worked well for us when tried.

Right, I like the idea of keeping things simple. But if you're going
to accept that a vector is useful, then it seems reasonable that some
other *simple* structured datatypes can be useful. An N-element
key/value map (a la /proc/meminfo) is, I think, nicer than having to
read values from N separate files.

>
> As to the motivations Paul M gives:
>  1) Avoid "an arbitrary mess of ad-hoc APIs":
>         We can still do that, whether or not we "self-document" these
>         API's in this manner.

We can, but this file makes it more clear what control files have a
well-defined API and which are just returning some ad-hoc string.

I guess it's not essential, I just figured that if we had that
information, it made sense to make it available to userspace. I guess
I'm happy with dropping the actual exposed cgroup.api file for now as
long as we can work towards reducing the number of control files that
just return strings, and make use of the structured output such as
read_uint() miore.

>  2) binary APIs versus ASCII APIs:
>         Well, I have an ASCII API bias, not surprising.  But I'd
>         suggest not doing things "in anticipation" of some future
>         fuzzy binary API support.  Wait until that day actually arrives.

I have a reasonably clear idea of how we can do the binary API.

That's mostly for a separate RFC. But for example, reading a map via
the binary API would be able to just return a list values since the
keys could be parsed once from the ascii map (provided that the
subsystem guaranteed that the map keys and their order wouldn't change
between reboots).


>  3) The memory controller currently has files with the "_in_bytes":
>         The traditional way to handle this is Documentation and man
>         pages; good enough for my granddad, good enough for me ;).

I've tried submitting patches to remove the in_bytes suffix and just
rely on the documentation, and people didn't seem to like it ...

Paul
