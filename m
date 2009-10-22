From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] Send checkpoint and restart debug info to a log
	file (v2)
Date: Thu, 22 Oct 2009 13:25:35 -0500
Message-ID: <20091022182535.GA6053@us.ibm.com>
References: <20091021210507.GA2098@us.ibm.com> <4ADF853F.6080807@librato.com>
	<20091021224922.GA5827@us.ibm.com> <4ADF95D0.8060806@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ADF95D0.8060806-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
...
> > More practically, requiring userspace to pass over a flag
> > consisting of CKPT_DBG_MEM|CKPT_DBG|FILE|CKPT_DBG|TASK, and
> > handle corresponding usage flags, is not nice.
> 
> I agree with you on about this. Maybe we want a better
> interface ?

I'm looking at tracehooks right now.  So the way it would work is:

1. Error messages using ckpt_error() are always compiled in, are
sent to ctx->logfile if that exists, and are sent to syslog if
CONFIG_CHECKPOINT_DEBUG (or some sysctl is set).

2. Debug messages could be tracehooks which can be enabled per
subsystem as above - for mem, file, task, etc - using code we add
under linux-cr/samples/.  It would basically do:

	  ret = register_trace_ckpt_mem(ckpt_trace_mem, ckpt_logprobe);
	  ret = register_trace_ckpt_task(ckpt_trace_mem, ckpt_logprobe);

where ckpt_logprobe does the printing of info to ctx->logfile and
syslog.

Or,

at first of course we can just let CONFIG_CHECKPOINT_DEBUG determine
the printing of ckpt_debugs() as we do now.

I'm going to start slowly, first defining the ckpt_error() helpers
and introducing/converting some callers.

-serge
