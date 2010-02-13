From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: containerized syslog
Date: Sat, 13 Feb 2010 08:03:20 -0800
Message-ID: <20100213160320.GV3714@count0.beaverton.ibm.com>
References: <1265915683.19130.166.camel@Mercier.safe.ca>
	<20100211192952.GA20191@us.ibm.com>
	<20100213155813.GU3714@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100213155813.GU3714-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Feb 13, 2010 at 07:58:13AM -0800, Matt Helsley wrote:

<snip>

> Your comments seem good. However, I do have an issue with the
> idea of finding a single syslog corresponding to the netns for
> a hypothetical printk in iptables.
> 
> What happens with:
> 
> /* in init_syslog_ns */
> clone(CLONE_SYSLOG) /* syslog_ns 1 */
> clone(CLONE_SYSLOG) /* syslog_ns 2 */
> <do something with iptables in the netns which triggers a printk>
> 
> Even though that same printk is relevant to three "syslogs", it'll
> only go to one, correct? If so, my feeling is that nsprintk
> shouldn't take a syslog_ns directly. It should take some other
> form of namespace and then write to the syslog of all the

Sorry, I don't think I worded this clearly. "some other form" means a
non-syslog_ns which is "relevant" to the printk e.g. a netns for
iptables code.

Cheers,
	-Matt Helsley
