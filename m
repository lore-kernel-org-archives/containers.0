From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: Wiki for LXC with Checkpoint/Restart
Date: Wed, 14 Apr 2010 14:34:21 -0500
Message-ID: <1271273662.18251.105.camel@localhost>
References: <20100412222727.GA5759@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100412222727.GA5759-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Mon, 2010-04-12 at 15:27 -0700, Sukadev Bhattiprolu wrote:
> Hi,
> 
> We created following wiki to describe the process to build/test LXC
> with checkpoint/restart.
> 
> 	https://ckpt.wiki.kernel.org/index.php/Link-LXC-USERCR
> 
> The USERCR and LXC patches that are needed are in:
> 
>         http://lxc.sourceforge.net/patches/lxc+usercr/usercr-patches/
>         http://lxc.sourceforge.net/patches/lxc+usercr/lxc-patches/
> 
> (and also referred to in the above wiki).
> 
> For now, the wiki identifies specific "commit-id"s to identify the
> commit with which the instructions in the wiki were tested. We hope
> to create more meaningful tags to the commits and if so, we will update
> the wiki with the tags.

Commit IDs are ugly but unambiguous.  I didn't have a problem just
copy/pasting the commands.

> Please let me know if you have any comments on the wiki or run into
> problems. 

I took the liberty of cleaning up a few stray '|' characters in the last
code snippet and fixed up the deprecated old-style git invocations (e.g.
"git-clone" becomes "git clone").  Not trying to be picky about the git
thing, but the hyphenated commands don't work on newer distributions.

I ran into an issue trying to follow the instructions on a SLES11 x86_64
system.  When building lxc I get:

gcc -fPIC -DPIC -I../../src -DLIBCR -I/home/nathanl/user-cr
-I/home/nathanl/user-cr/include -g -O2 -Wall
-shared /home/nathanl/user-cr/checkpoint.o /home/nathanl/user-cr/restart.o /home/nathanl/user-cr/libeclone.a -Wl,-soname,liblxc.so.0  -o liblxc.so liblxc_so-arguments.o liblxc_so-commands.o liblxc_so-start.o liblxc_so-stop.o liblxc_so-monitor.o liblxc_so-console.o liblxc_so-freezer.o liblxc_so-checkpoint.o liblxc_so-restart.o liblxc_so-error.o liblxc_so-parse.o liblxc_so-cgroup.o liblxc_so-utils.o liblxc_so-namespace.o liblxc_so-conf.o liblxc_so-confile.o liblxc_so-state.o liblxc_so-log.o liblxc_so-network.o liblxc_so-nl.o liblxc_so-rtnl.o liblxc_so-genl.o liblxc_so-mainloop.o liblxc_so-af_unix.o -lutil
/usr/lib64/gcc/x86_64-suse-linux/4.3/../../../../x86_64-suse-linux/bin/ld: /home/nathanl/user-cr/checkpoint.o: relocation R_X86_64_32 against `.rodata' can not be used when making a shared object; recompile with -fPIC

Not sure what to do about it immediately; user-cr/checkpoint.o should be
built with -fPIC I guess?
