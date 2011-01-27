From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: linux-cr:  v23-rc1 pushed
Date: Thu, 27 Jan 2011 05:23:02 -0800
Message-ID: <20110127132302.GF29064@count0.beaverton.ibm.com>
References: <4D2BAFD4.1080400@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D2BAFD4.1080400-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jan 10, 2011 at 08:18:12PM -0500, Oren Laadan wrote:
> Folks,
> 
> I just pushed out a new v23-rc1 branch of linux-cr. This one is
> rebased to 2.6.37, and contains nearly all the patches pulled
> on v22-dev. I only gave it a brief test drive... feel free to 
> throw all your ammo it.
> 
> Rebasing was fairly straightforward, but I'd feel more comfortable 
> with more eyes looking at some code, specifically:
> 
> userns [Serge ?]
> sockets [Dan ?]
> cgroup_freezer [Matt ?]

Other than the nit I just sent a patch for it looks fine.

> 
> I skipped PowerPC patches and ARM patches. Nathan, Christoffer -
> can you take a look at those, respectively, and re-post to list ?

I looked at the powerpc patches. The only "difficult" part to
forward-port is the debug register checkpoint/restart code. 
It's more difficult because additional debug register support has
since been added to the kernel and those ought to be supported
by c/r too.

I think we'd be better off splitting that out the debug register
c/r code into a separate patch. We can just error ou if it's obvious
that debug registers have been setup. An untested patch for erroring
out is forthcoming. For now I'll let Nathan look into adding the new
debug register support.

Cheers,
	-Matt Helsley
