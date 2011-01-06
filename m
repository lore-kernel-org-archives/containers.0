From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Containers and /proc/sys/vm/drop_caches
Date: Thu, 6 Jan 2011 14:08:41 -0800
Message-ID: <20110106220841.GK29064@count0.beaverton.ibm.com>
References: <20110105094022.GA5366@glandium.org> <4D243EC3.1050101@free.fr>
	<20110105140159.GC2718@hallyn.com>
	<AANLkTi=x=6gUZTxJC8LXxYNu029+firyzKqjMa6m+R-x@mail.gmail.com>
	<20110106214315.GJ29064@count0.beaverton.ibm.com>
	<1294350605.26733.3.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1294350605.26733.3.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Hommey <mh-YmoObPS1fuhg9hUCZPvPmw@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 06, 2011 at 01:50:05PM -0800, Dave Hansen wrote:
> On Thu, 2011-01-06 at 13:43 -0800, Matt Helsley wrote:
> > That said, the more important question is why should we provide
> > drop_caches inside a container? My understanding is it's largely a
> > workload-debugging tool and not something meant to truly solve
> > problems. If that's the case then we shouldn't provide it at all or it
> > should actually interfere with the host cache. 
> 
> Yeah, what's the problem that you're solving with drop_caches?  The odds
> are, there's a better way.
> 
> That said, it _might_ be worth doing things like dropping (inode or
> dentry) caches per-sb.  That's a much better fit than using big, ugly,
> loosely-defined, system-wide knobs like drop_caches.

Yup. Since many containers will have their own mount namespaces with
separate sbs it's a more reasonable approximation of per-container
dropping of caches.

> 
> Also, unless we start giving containers real ownership of devices or
> partitions, it's going to be pretty darn hard to let things clear caches
> in a meaningful way.  What if one container wants an object cleared
> while another doesn't?

Good point. First reaction: we'd want to keep it cached if any of the
containers want it. But even that's a bad policy under certain
circumstances containers (aka VPS) might be used for.

Is drop_caches well-defined? IOW would it be permissible to
not actually drop all or any of the cache entries or to do nothing and
still report success instead of, say, EPERM, to a container?

Cheers,
	-Matt Helsley
