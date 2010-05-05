From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v21 011/100] eclone (11/11): Document sys_eclone
Date: Wed, 5 May 2010 15:25:53 -0700
Message-ID: <20100505222553.GA6555__24512.6858041205$1273098037$gmane$org@us.ibm.com>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
	<1272723382-19470-12-git-send-email-orenl@cs.columbia.edu>
	<20100505141447.fc2397f6.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100505141447.fc2397f6.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Randy Dunlap [randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org] wrote:
| > +		base of the region allocated for stack. These architectures
| > +		must pass in the size of the stack-region in ->child_stack_size.
| 
| 		                             stack region
| 
| Seems unfortunate that different architectures use the fields differently.

Yes and no. The field still has a single purpose, just that some architectures
may not need it. We enforce that if unused on an architecture, the field must
be 0. It looked like the easiest way to keep the API common across
architectures.

| 
| Is this example program meant to build only on i386?

Yes. Will add a pointer to the clone*.[chS] and libeclone.a files in

	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git

for other architectures (currently x86_64, ppc, s390).

Thanks for the review. Will fix the errors and repost.

Sukadev
