From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: user-cr: Extra unshare() calls ?
Date: Mon, 8 Mar 2010 14:58:51 -0600
Message-ID: <20100308205851.GB21490@us.ibm.com>
References: <20100308201338.GA16446@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100308201338.GA16446-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> Came across this while testing LXC.
> 
> 
> 1. Does ckpt_remount_proc() need to unshare() ? Or can we have the
>    clone() that calls __ckpt_coordinator() clone with CLONE_NEWNS|CLONE_FS
>    instead ?
> 
>    The problem with the unshare() in ckpt_remount_proc() is that it
>    creates an extra level in cgroup hierarchy (see below) after restart.
>    So applications expecting the cgroup hierarchy before chckpoint will
>    be surprised.
> 
> 2. When --mount-pty (or --mntns) is specified, do we need to unshare() 
>    in the parent process ? Considering only the full-container restart
>    for now (ignore self-restart and subtree restart), can we just
>    specify (CLONE_NEWNS|CLONE_FS) at the time of creating the first
>    restarted process ?

And then move remounting of devpts into ckpt_remount_proc() called
from __ckpt_coordinator() as well?

-serge
