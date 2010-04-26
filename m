From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/4] C/R: Fix storing IPv6 addresses and handle the
	"ipv6only" socket flag (v2)
Date: Mon, 26 Apr 2010 10:35:07 -0400
Message-ID: <4BD5A49B.9030605@cs.columbia.edu>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>	<1270748932-26745-5-git-send-email-danms@us.ibm.com>	<4BD4AF37.10504@cs.columbia.edu>
	<87d3xmfhzx.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d3xmfhzx.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Dan Smith wrote:
>>> +EXPORT_SYMBOL_GPL(inet_checkpoint);
> 
> OL> This belongs to a separate patch ?  Especially for as long as we
> OL> need to keep our patchset clean, until it makes it to -mm
> 
> Does it?  It's just exporting a symbol that is already in the tree so
> we can use it.  Are you saying you just want the export to be done in
> its own patch?
> 

I guess I was too quick on the trigger. If you have other future
users for inet_checkpoint and co., then yes, a separate patch -
since I would fold it into the original inet patches (assuming
we are not yet in -mm).

Oren.
