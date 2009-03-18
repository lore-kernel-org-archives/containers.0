From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Wed, 18 Mar 2009 16:46:39 +0100
Message-ID: <49C1175F.9060600@free.fr>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>	<20090312162954.4a4b8e00@thinkcentre.lan>	<87fxhipfrh.fsf@caffeine.danplanet.com>	<20090312224820.GA12723@hallyn.com>	<87bps6pcyf.fsf@caffeine.danplanet.com>	<49C0B069.6060300@cs.columbia.edu>
	<20090318134932.GC22636@us.ibm.com>
	<878wn353mf.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <878wn353mf.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dan Smith wrote:
> SH> (Note that in Dan's next version, he did move unshare into
> SH> userspace)
> 
> The idealist in me still wants it to be in the kernel.  However, after
> seeing it done I agree that it's the right thing to do, at least in
> this case.

I would say in all cases.

as you can't unshare(CLONE_NEWPID), you might consider doing a 

	clone(CLONE_NEW*|CLONE_WHATEVER)

to restart 1 and then restart the container process tree under it, block
them, restore the container namespaces and other shared resources in the
right order and then release the processes to let them restart themselves. 
that's how we've implemented restart. You might be doing that already, 
sorry I haven't had time to look at your code. 

1 being an invariant between checkpoint and restart.

C.
