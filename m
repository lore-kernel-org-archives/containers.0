From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Date: Wed, 10 Apr 2013 11:30:32 +0400
Message-ID: <51651518.4010007__2236.68095791272$1365579033$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-3-git-send-email-glommer@parallels.com>
	<20130408084202.GA21654@lge.com> <51628412.6050803@parallels.com>
	<20130408090131.GB21654@lge.com> <51628877.5000701@parallels.com>
	<20130409005547.GC21654@lge.com> <20130409012931.GE17758@dastard>
	<20130409020505.GA4218@lge.com> <20130409123008.GM17758@dastard>
	<20130410025115.GA5872@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130410025115.GA5872-Hm3cg6mZ9cc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Joonsoo Kim <iamjoonsoo.kim-Hm3cg6mZ9cc@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/10/2013 06:51 AM, Joonsoo Kim wrote:
> As you can see, before this patch, do_shrinker_shrink() for
> "huge_zero_page_shrinker" is not called until we call shrink_slab() more
> than 13 times. *Frequency* we call do_shrinker_shrink() actually is
> largely different with before. With this patch, we actually call
> do_shrinker_shrink() for "huge_zero_page_shrinker" 12 times more
> than before. Can we be convinced that there will be no problem?
> 
> This is why I worry about this change.
> Am I worried too much? :)

Yes, you are. The amount of times shrink_slab is called is completely
unpredictable. Changing the size of cached data structures is a lot more
likely to change this than this shrinker change, for instance.

Not to mention, the amount of times shrink_slab() is called is not
changed directly here. But rather, the amount of times an individual
shrinker actually does work.
