From: James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>
Subject: Re: memcg: fix fatal livelock in kswapd
Date: Mon, 02 May 2011 18:58:18 -0500
Message-ID: <1304380698.15370.36.camel__39936.0937685289$1304380890$gmane$org@mulgrave.site>
References: <1304366849.15370.27.camel@mulgrave.site>
	<20110502224838.GB10278@cmpxchg.org>
	<BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ying Han <yinghan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Chris Mason <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2011-05-02 at 16:14 -0700, Ying Han wrote:
> On Mon, May 2, 2011 at 3:48 PM, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org> wrote:
> > I am very much for removing this hack.  There is still more scan
> > pressure applied to memcgs in excess of their soft limit even if the
> > extra scan is happening at a sane priority level.  And the fact that
> > global reclaim operates completely unaware of memcgs is a different
> > story.
> >
> > However, this code came into place with v2.6.31-8387-g4e41695.  Why is
> > it only now showing up?
> >
> > You also wrote in that thread that this happens on a standard F15
> > installation.  On the F15 I am running here, systemd does not
> > configure memcgs, however.  Did you manually configure memcgs and set
> > soft limits?  Because I wonder how it ended up in soft limit reclaim
> > in the first place.

It doesn't ... it's standard FC15 ... the mere fact of having memcg
compiled into the kernel is enough to do it (conversely disabling it at
compile time fixes the problem).

> curious as well. if we have workload to reproduce it, i would like to try

Well, the only one I can suggest is the one that produces it (large
untar).  There seems to be something magical about the memory size (mine
is 2G) because adding more also seems to make the problem go away.

James
