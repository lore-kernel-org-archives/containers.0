From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Remaining work for userns (WAS Re: [PATCH 3/3] cgroup : remove the
	ns_cgroup)
Date: Thu, 29 Jul 2010 16:00:52 -0700
Message-ID: <20100729230052.GB2785__36494.7729315192$1280444634$gmane$org@count0.beaverton.ibm.com>
References: <20100729195629.GA13378@hallyn.com>
	<20100729195812.GB19015@hallyn.com>
	<20100729214008.GA2785@count0.beaverton.ibm.com>
	<20100729223957.GA12387@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100729223957.GA12387-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 29, 2010 at 05:39:57PM -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > On Thu, Jul 29, 2010 at 02:58:12PM -0500, Serge E. Hallyn wrote:

<snip>

> 
> BTW in the past the only reason I saw for keeping ns cgroup was
> to lock tasks into a devices cgroup.  Until that lazy guy who was
> going to do it gets off his butt and implements user namespaces,
> you'll just have to use LSMs, which is the right way.

And the only missing piece of userns is replacing the cred checks
right? If so, it might be possible to come up with a coccinelle semantic
patch which would do all/most of the hard work -- depends on whether the
all the checks fit a small number of semantic patterns.

Cheers,
	-Matt Helsley
