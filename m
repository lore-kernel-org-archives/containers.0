From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 2/5] Generic notifiers for SLUB events
Date: Mon, 1 Oct 2007 13:39:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0710011338190.19779@schroedinger.engr.sgi.com>
References: <46F91841.9070708@openvz.org> <46F918D9.3020406@openvz.org>
	<4700F083.1070706@linux.vnet.ibm.com> <4700F120.2070302@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4700F120.2070302-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 1 Oct 2007, Pavel Emelyanov wrote:

> > Should the default be on? Shouldn't it depend on KMEM?
> 
> Well... I think that is should be N by default and has
> noting to do with the KMEM :) Thanks for noticing.

Right.

> >> +#ifdef CONFIG_SLUB_NOTIFY
> >> +	srcu_init_notifier_head(&slub_nb);
> > 
> > Can we get rid of the #ifdef CONFIG_SLUB_NOTIFY?
> 
> I don't think this is really useful in the __init code :)

You could define some macros that avoid the #ifdefs?
