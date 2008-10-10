From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] first callers of process_deny_checkpoint()
Date: Fri, 10 Oct 2008 12:13:50 -0500
Message-ID: <20081010171350.GA28112__1243.021808523$1223659051$gmane$org@us.ibm.com>
References: <20081009190405.13A253CB@kernel> <20081009190406.1B257119@kernel>
	<48EF2BAB.1010009@fr.ibm.com> <20081010140430.GA14640@us.ibm.com>
	<1223657132.10017.42.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1223657132.10017.42.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
Cc: arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Greg Kurz (gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> On Fri, 2008-10-10 at 09:04 -0500, Serge E. Hallyn wrote:
> > Remember a part of Ingo's motivation is to push c/r developers to
> > address the lacking features that users use most, earlier.  So the
> > warnings and subsequent email complaints are what we're after.  Hence a
> > single 'checkpointable or not' flag.
> > 
> > Given the single flag, how do you know at sys_mq_unlink() whether the
> > process also has an opensocket?
> > 
> > Rather than make this tracking facility more complicated and intrusive,
> > if people complain that they couldn't checkpoint bc of a warning about
> > aio, then we implement aio c/r!  We don't just try and reduce the amount
> > of time that you can't checkpoint bc of lack of aio c/r support  :)
> > 
> > -serge
> 
> Serge,
> 
> It's exactly what I meant before, the tracking facility would be awfully
> complicated. It cannot be done that way.
> But there's also something awkward with the flag thing : can you provide
> right now an exhaustive list of all the places where you must raise it ?
> 
> I'd rather do some heavy checking at checkpoint time.

Noone is saying that we are not going to do that.

-serge
