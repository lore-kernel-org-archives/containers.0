From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 1/2] Track in-kernel when we expect
	checkpoint/restart to work
Date: Mon, 13 Oct 2008 11:46:00 -0500
Message-ID: <20081013164559.GA31636__21770.1556314298$1223916504$gmane$org@us.ibm.com>
References: <20081009190405.13A253CB@kernel>
	<1223626834.8787.8.camel@localhost.localdomain>
	<48EF144D.1050906@fr.ibm.com> <20081010145934.GF11695@elte.hu>
	<48EF7211.2000303@cs.columbia.edu>
	<1223656489.10017.33.camel@localhost.localdomain>
	<48EF8E77.8050000@nortel.com>
	<1223885897.4404.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1223885897.4404.5.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Chris Friesen <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Greg Kurz (gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> On Fri, 2008-10-10 at 11:18 -0600, Chris Friesen wrote:
> > Greg Kurz wrote:
> > 
> > > This flag is weak... testing it gives absolutly no hint whether the
> > > checkpoint may succeed or not. As it is designed now, a user can only be
> > > aware that checkpoint is *forever* denied. I agree that it's only useful
> > > as a "flexible CR todo list".
> > 
> > I don't think it's true that it gives "absolutly no hint".
> > 
> > If the flag is not set, then checkpoint will succeed, right?  Whereas if 
> 
> Wrong. Unless you test_and_checkpoint atomically, the flag doesn't help.

Atomically wrt what?  Presumably you test and checkpoint while the
container is frozen...

> > the flag is set, then it's an indication that checkpoint could fail (but 
> > may still succeed if whatever condition caused the flag to be set is no 
> > longer true).
> > 
> > Chris
> > 
> -- 
> Gregory Kurz                                     gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
> Software Engineer @ IBM/Meiosys                  http://www.ibm.com
> Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420
> 
> "Anarchy is about taking complete responsibility for yourself."
>         Alan Moore.
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
