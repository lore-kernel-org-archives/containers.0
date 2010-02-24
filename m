From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2][LXC] Rename --directory option to --statefile
Date: Wed, 24 Feb 2010 12:30:24 -0600
Message-ID: <20100224183024.GA22624@us.ibm.com>
References: <20100224084108.GG18758@us.ibm.com> <4B84E80A.7060208@fr.ibm.com>
	<4B84E94E.3000406@fr.ibm.com> <20100224181150.GA3276@us.ibm.com>
	<4B856BC8.5060000@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B856BC8.5060000-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> >>>This has some major impact on our side as it is a 9 year old API ...
> >>>We'll look into it to see how painful it is to change.
> >
> >Ah, did not realize it caused that much pain.
> 
> bah. we should change anyway.
> 
> >>We can keep --directory and add --statefile.
> >>For --statefile option we can use a switch for IS_DIR, IS_REG.
> >>
> >>--directory becomes deprecated and we switch to the statefile option
> >>step by step.
> >>
> >>Does it make sense ?
> >
> >Yes, I think it will work.
> >
> >BTW, what was the rationale for a directory ?  Is it meant to be used
> >with predefined file names in the specified directory ?
> 
> the mcr statefile use to be a directory, organized in such a way it was
> easy to analyze its contents and easy to restart concurrently tasks
> and shared states. it's still a directory but it's shrinking to be a
> file and even a stream.
> 
> your request makes sense for the long term so we should take it.
> 
> c.

Are we sure that we won't find other information which lxc_checkpoint
will want to store which sys_checkpoint() ignores?  A link to a btrfs
snapshot, for instance.

-serge
