From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/4][user-cr] Rename libeclone.a to libcheckpoint.a
Date: Wed, 24 Feb 2010 14:26:01 -0800
Message-ID: <20100224222601.GA27934@us.ibm.com>
References: <20100224083452.GB18758@us.ibm.com>
	<20100224083726.GF18758@us.ibm.com>
	<20100224151919.GB6425@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100224151919.GB6425-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| > diff --git a/restart.c b/restart.c
| > index b1518f2..a163862 100644
| > --- a/restart.c
| > +++ b/restart.c
| > @@ -530,6 +530,12 @@ int app_restart(struct restart_args *args)
| >  		ret = ckpt_coordinator(&ctx);
| >  	}
| > 
| > +	/*
| > +	 * Hack for LXC - which currently only uses pidns == 1, pid0 == 1;
| > +	 */
| > +	if (ret >= 0)
| > +		ret = global_child_pid;
| > +
| 
| Hmm?  Maybe I'm looking at the wrong context, but isn't this specifically
| the existing pidns case?

Yes it is.

| Should the second block ("new pidns with init")
| be the one to execute if your comment is correct?

Oh, you mean I could just return the global_child_pid from within the
"new pid ns with init" block ?. I could do that for now.

BTW, from a long-term API pov, should app_restart():

	- support the other two types of restart ("new pidns without
	  init" and "subtree in current pidns"). LXC may not use those,
	  but any reason for the API to not support those cases ?

	- If the API supports them, should app_restart() always return the
	  pid of the coordinator (i.e global_child_pid). That way the
	  caller knows the root of the restarted process-tree ?

	- Also, like the kernel's API, how about app_checkpoint() and
	  app_restart() take a logfp/logfd and we send all the debugging
	  output to that file ?

Thanks,

Sukadev


| 
| >  	return ret;
| >  }
| > 
| > -- 
| > 1.6.6.1
