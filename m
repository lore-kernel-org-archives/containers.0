From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/4][user-cr]: First try at integrating LXC and
	USER-CR
Date: Wed, 24 Feb 2010 09:15:24 -0600
Message-ID: <20100224151524.GA6425@us.ibm.com>
References: <20100224083452.GB18758@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100224083452.GB18758-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> Following two sets of patches is an early attempt to integrate LXC and
> USER-CR. 
> 
> Overview:
> 
> Have USER-CR export the core checkpoint and restart functionality into a
> library (/lib/libcheckpoint.a and <usercr.h>) and have LXC link with this
> library.
> 
> TODO: 
> 
> 	1. For now, libcheckpoint.a implements only the restart functionality
> 	   and so only lxc_restart command is implemented. Implementing the
> 	   checkpoint functionality and lxc_checkpoint command can be done
> 	   similarly and is hopefully easier than the restart functionality.
> 
> 	2. The restart() functionality in user-cr makes extensive use of global
> 	   variables and debug code. The API must be extended to properly
> 	   include these variables/debug code in the API.
> 
> 	   Similarly, the 'struct restart_args' may need to be sanitized for
> 	   use in a formal API.
> 
> 	3. lxc_restart command  restarts entire containers only (specifically
> 	   it simulates the --pidns --pids --mount-pty arguments to
> 	   /bin/restart).
> 
> 	4. Link lxc_restart and lxc_checkpoint with the shared library
> 	   liblxc.so (currently links statically)
> 
> 	5. ...
> 
> 
> STATUS:
> 	I was able to checkpoint/restart a simple '/bin/sleep 1000' LXC
> 	container, except for a cgroup naming issue after restart (see below).

Very nice, Suka.

-serge
