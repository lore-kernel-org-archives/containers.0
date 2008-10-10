From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC][PATCH 1/2] Track in-kernel when we expect
	checkpoint/restart to work
Date: Fri, 10 Oct 2008 17:28:31 +0200
Message-ID: <20081010152831.GA28977__40475.4233699807$1223652814$gmane$org@elte.hu>
References: <20081009190405.13A253CB@kernel>
	<1223626834.8787.8.camel@localhost.localdomain>
	<48EF144D.1050906@fr.ibm.com> <20081010145934.GF11695@elte.hu>
	<48EF7211.2000303@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48EF7211.2000303-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


* Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

> 
> 
> Ingo Molnar wrote:
> > * Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> >>> By the way, why don't you introduce the reverse operation ?
> >> I think implementing the reverse operation will be a nightmare, IMHO 
> >> it is safe to say we deny checkpointing for the process life-cycle 
> >> either if the created resource was destroyed before we initiate the 
> >> checkpoint.
> > 
> > it's also a not too interesting case. The end goal is to just be able to 
> > checkpoint everything that matters - in the long run there simply wont 
> > be many places that are marked 'cannot checkpoint'.
> > 
> > So the ability to deny a checkpoint is a transitional feature - a 
> > flexible CR todo list in essence - but also needed for 
> > applications/users that want to rely on CR being a dependable facility.
> > 
> > It would be bad for most of the practical usecases of checkpointing to 
> > allow the checkpointing of an app, just to see it break on restore due 
> > to lost context.
> 
> Actually it need not wait for restore to fail - it can fail during the 
> checkpoint, as soon as the unsupported feature is encountered.

correct, that is the idea.

	Ingo
