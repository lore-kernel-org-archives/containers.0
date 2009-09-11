From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: add a few more ckpt_write_err()s
Date: Fri, 11 Sep 2009 16:27:42 -0500
Message-ID: <20090911212742.GB15329@us.ibm.com>
References: <20090910223344.GA11718@us.ibm.com> <4AAABE01.1080807@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AAABE01.1080807-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
> 
> I wonder if it can be useful to decide on a common "format", that
> can be useful in the future for automatic error analysis. E.g:
> 
> "[PID %d ERR %d]: .....", for error with a specific task, and
> "[PID %d ERR %d OBJ %d]: ......" for error with an object, and so on.
> 
> Or even a bit more fancy, like:
> 
> 	ckpt_write_err("EO", "error message %p blah", err, obj, ptr);
> 			SPEC   FMT		      VARS...
> 
> Which ckpt_write_err() will translate to
> 
> 	sprintf(s, "[PID %d ERR %d] FMT", VARS...);
> 
> So the SPEC "EO" (stands for ERR, OBJ) becomes "[PID %d ERR %d OBJ %d]: "
> (pid is mandatory, the rest requested by the caller):
> 	E -> ERR %d
> 	O -> OBJ %d
> 	P -> PTR %p
> 	S -> SYM %pS
> 	etc...

Yes, it'd be useful.  BTW it also would be useful to have mktree/
restart auto-detect such error strings and report them.

-serge
