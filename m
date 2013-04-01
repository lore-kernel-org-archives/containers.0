From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 00/28] memcg-aware slab shrinking
Date: Mon, 1 Apr 2013 09:12:17 -0500
Message-ID: <20130401141217.GA9336@sergelap>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<20130401123843.GC5217@sergelap> <51598168.4050404@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51598168.4050404-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 04/01/2013 04:38 PM, Serge Hallyn wrote:
> > Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> >> Hi,
> >>
> >> Notes:
> >> ======
> >>
> >> This is v2 of memcg-aware LRU shrinking. I've been testing it extensively
> >> and it behaves well, at least from the isolation point of view. However,
> >> I feel some more testing is needed before we commit to it. Still, this is
> >> doing the job fairly well. Comments welcome.
> > 
> > Do you have any performance tests (preferably with enough runs with and
> > without this patchset to show 95% confidence interval) to show the
> > impact this has?  Certainly the feature sounds worthwhile, but I'm
> > curious about the cost of maintaining this extra state.
> > 
> > -serge
> > 
> Not yet. I intend to include them in my next run. I haven't yet decided
> on a set of tests to run (maybe just a memcg-contained kernel compile?)
> 
> So if you have suggestions of what I could run to show this, feel free
> to lay them down here.

Perhaps mount a 4G tmpfs, copy kernel tree there, and build kernel on
that tmpfs?

-serge
