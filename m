From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Skip down interfaces (v2)
Date: Thu, 1 Apr 2010 10:37:26 -0500
Message-ID: <20100401153726.GA14962@hallyn.com>
References: <1270052634-8170-1-git-send-email-danms@us.ibm.com>
	<4BB4BA26.1050707@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BB4BA26.1050707-VXdhtT5mjnY@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Brian Haley (brian.haley-VXdhtT5mjnY@public.gmane.org):
> Dan Smith wrote:
> > This makes the netns checkpoint code skip interfaces that are not up.
> > Later, we want to make it possible to checkpoint down interfaces with
> > a flag, but for now this helps prevent people from getting stuck on
> > stock kernels with various unsupported and persistent virtual interfaces,
> > such as tunnel devices.
> 
> But devices that are not IFF_UP can still have addresses associated
> with them, wouldn't this cause those addresses to not be
> checkpointed?

Only if it's a device that wouldn't have supported checkpoint anyway.
So if veth0 is down, it'll be checkpointed.  If tunl0 is up, checkpoint
will be refused.  But if tunl0 is down, then it'll just be ignored.
The container didn't want that jerk around anyway, it just couldn't
get rid of it.

-serge
