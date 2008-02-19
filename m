From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC][PATCH 1/7] CGroup API: Add cgroup.api control file
Date: Tue, 19 Feb 2008 15:57:42 -0600
Message-ID: <20080219155742.0298f25f.pj__26073.1224473149$1203458527$gmane$org@sgi.com>
References: <20080215204418.535025000@menage.corp.google.com>
	<20080215204820.734926000@menage.corp.google.com>
	<47B6B5CA.7040201@linux.vnet.ibm.com>
	<6599ad830802160944v6d529570k1ade6df273ca3d0d@mail.gmail.com>
	<47B953A8.9030206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47B953A8.9030206-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> It seems to me this is a little messy.

Agreed.  It looks too finicky to base real software on;  that is, I
doubt that any robust application or user level software is going to
depend on it for serious automated self-configuration.

I haven't seen a serious problem with cpuset documentation, which is
the earlier API of this flavor (though, granted, I'd be the last
person on the planet to see such ;).  It seems to me that this style
of API is easy enough for a variety of people to figure out that this
won't help that much.  And certainly the more interesting details that
need documentation are far too verbose for this presentation.

So ... little or no programmatic use, little or no human use.

It also reminds me a bit, in a very loose way, of efforts in sysfs that
have taken us a while, and too many changes, to get right.  One needs to
be -selective- in what one exposes, in order to minimize maintenance costs
and maximize the signal-to-noise ratio, over time.  This feels like it
exposes too much.

Finally, it goes against the one thingie per file (at most, one scalar
vector) that has worked well for us when tried.

As to the motivations Paul M gives:
 1) Avoid "an arbitrary mess of ad-hoc APIs":
	We can still do that, whether or not we "self-document" these
	API's in this manner.
 2) binary APIs versus ASCII APIs:
	Well, I have an ASCII API bias, not surprising.  But I'd
	suggest not doing things "in anticipation" of some future
	fuzzy binary API support.  Wait until that day actually arrives.
 3) The memory controller currently has files with the "_in_bytes":
	The traditional way to handle this is Documentation and man
	pages; good enough for my granddad, good enough for me ;).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.940.382.4214
