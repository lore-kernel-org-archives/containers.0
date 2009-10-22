From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] Send checkpoint and restart debug info to a log
	file (v2)
Date: Wed, 21 Oct 2009 19:51:57 -0500
Message-ID: <20091022005157.GA11608@us.ibm.com>
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
> > BTW it occurs to me that self-restart with a logfd must be kinda
> > hosed early on :)
> 
> Why would that be a problem ?  I actually think it's useful for
> those doing self-restart:  you open a file, the kernel takes a
> reference to it, then sys_restart() will eventually close that
> file descriptor - but kernel still keeps a reference - so debug
> data keeps flowing. When restart completes -- data is gone; If
> restart fails - user will have information in that file.

Hmm, good point.  No problem then.

...

> >>> Changelog:
> >>> 	Oct 21: split ckpt_debug into ckpt_debug and ckpt_err.
> >>> 		Git rid of the split by memory debug info etc.
> >> The split is useful to control the amount of log.
> > 
> > It's a stupid split!  And I've never used it.  Besides, when a log is
> > for a single c/r, it's really not very big.
> 
> It may be stupid split!, yet it did prove very useful to me.

Sorry, stupid isn't right.  Clearly it made sense.

> Maybe it's because you never debugged the memory checkpoint
> page by page.
> 
> A typical scenario: you hit a bug -> you enable debugging ->
> the bug disappears -> you disable debugging -> you hit the bug ...
> 
> IOW, debugging output in big doses affects the execution in a
> way that makes heisen-bugs hide. Control over verbosity means you
> get better chances at reproducing the behavior and still have
> enough meaningful data.

So I guess it should stay in there at least for syslog output.
Then you could debug by not passing an fd for the logfile to
sys_restart, and tweaking the syslog output.

> > More practically, requiring userspace to pass over a flag
> > consisting of CKPT_DBG_MEM|CKPT_DBG|FILE|CKPT_DBG|TASK, and
> > handle corresponding usage flags, is not nice.
> 
> I agree with you on about this. Maybe we want a better
> interface ?
> 
> Which brings me to this random thought: maybe we want to
> make the fourth argument of sys_{checkpoint,restart} a
> structure, to make it easier to extend it in the future
> without having to go throw a clone3-like hell...
> 
> Specifically, this structure could now be:
> 
> struct ckpt_args {
> 	int version;
> 	int logfd;
> 	int logmask;
> };
> 
> (or use union checkpoint {} and union restart {} to tell
> between checkpoint- and restart-related args.

Well I don't like passing structs to the kernel actually (and
don't like that in the clone3 patchset :), but can't think of
anything better offhand.  I'll think about it a bit more, but
maybe this'll be the way to go - long as a very simple program
can pass NULL to mean no debug.

-serge
