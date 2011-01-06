From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Containers and /proc/sys/vm/drop_caches
Date: Thu, 06 Jan 2011 14:15:40 -0800
Message-ID: <1294352140.30082.3.camel@nimitz>
References: <20110105094022.GA5366@glandium.org> <4D243EC3.1050101@free.fr>
	<20110105140159.GC2718@hallyn.com>
	<AANLkTi=x=6gUZTxJC8LXxYNu029+firyzKqjMa6m+R-x@mail.gmail.com>
	<20110106214315.GJ29064@count0.beaverton.ibm.com>
	<1294350605.26733.3.camel@nimitz>
	<20110106220841.GK29064@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110106220841.GK29064-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Hommey <mh-YmoObPS1fuhg9hUCZPvPmw@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2011-01-06 at 14:08 -0800, Matt Helsley wrote:
> Is drop_caches well-defined? IOW would it be permissible to
> not actually drop all or any of the cache entries or to do nothing and
> still report success instead of, say, EPERM, to a container?

It's really just a hint or a request.  It's possible that an

	echo 3 > /proc/sys/vm/drop_caches

returns '2' (for the two bytes written), indicating success and yet, not
a single object was freed.  There's currently no way to tell how much
work it did, or to figure out why it did a certain amount of work.

Frankly, in a container, it probably just shouldn't even show up
in /proc.

-- Dave
