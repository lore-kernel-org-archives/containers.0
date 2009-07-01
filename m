From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add AF_INET c/r support
Date: Wed, 01 Jul 2009 09:10:07 -0700
Message-ID: <87vdmcxu3k.fsf@caffeine.danplanet.com>
References: <1245697976-29159-1-git-send-email-danms@us.ibm.com>
	<4A42EA32.4070809@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A42EA32.4070809-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Wed\, 24 Jun 2009 23\:08\:34 -0400")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

OL> Adding a comment about it would clearly show that you thought
OL> about it, and warn others.

Done.

OL> Network developers are probably the right audience for this kind
OL> of audit.

Yep, agreed.  I suppose I'll copy netdev on the next round unless
there are more comments...

OL> Relocating the function below generates confusing noise in the
OL> patch.

Yep, and made for a bunch of collisions when changing the UNIX patch
underneath.  Sorry about that.

OL> What about sockets that aren't either TCP_{LISTEN,ESTABLISHED} ?

Yep, I caused it to fail to restart with an unconnected UDP socket.
I've got that fixed up now.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
