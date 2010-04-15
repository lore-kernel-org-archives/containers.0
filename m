From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: Wiki for LXC with Checkpoint/Restart
Date: Thu, 15 Apr 2010 17:00:37 -0500
Message-ID: <1271368837.2539.220.camel@localhost>
References: <20100412222727.GA5759@us.ibm.com>
	<1271273662.18251.105.camel@localhost>
	<20100414204054.GA24411@us.ibm.com>
	<1271278502.18251.122.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1271278502.18251.122.camel@localhost>
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

On Wed, 2010-04-14 at 15:55 -0500, Nathan Lynch wrote:
> On Wed, 2010-04-14 at 13:40 -0700, Sukadev Bhattiprolu wrote:
> > 
> > Yes, I think thats what Michel or Daniel ran into. For some reason, I
> > did not run into on Fedora11. Can you add -fPIC to the usercr CFLAGS
> > and try ? If it works for you, I will try on Fedora11 too and we can
> > add a patch to lxc.sf.net/patches/lxc+usercr/.
> 
> Yes, adding -fPIC to CFLAGS in the user-cr Makefile and rebuilding
> allows the lxc build to succeed.

Okay, so after getting the kernel build issues worked around and
documented, I've gotten to part 4 "Checkpoint/restart a simple LXC
container" in the wiki.  It works!  A couple of minor issues with the
instructions:

> $ lxc-execute --name foo --rcfile lxc-no-netns.conf -- /bin/sleep 1000

The full path to the rcfile needs to be supplied or lxc-execute errors
out.  Also, it seems that the above command needs its own terminal or it
should be run in the background.


> $ lxc-checkpoint --name foo --statefile /root/lxc-foo.ckpt

Is it intentional that this fails if /root/lxc-foo.ckpt already exists?
