From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Enhance checkpoint/restart Kconfig options
Date: Fri, 05 Jun 2009 12:01:00 -0700
Message-ID: <1244228460.12947.3185.camel@nimitz>
References: <20090604184504.F1BCB2F8@kernel> <m3iqjbix8u.fsf@pobox.com>
	<1244146621.20418.4912.camel@nimitz>  <m2zlcnfgst.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m2zlcnfgst.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2009-06-04 at 23:25 -0500, Nathan Lynch wrote:
> > Ahh, but there *isn't* a strict build dependency on them.  We just
> want
> > to make sure that if they're available that we enable them.  If we
> have
> > CONFIG_NET=n, then we certainly don't want to make CHECKPOINT
> depends on
> > it.
> 
> Sorry, I'm afraid I don't understand what you're saying here.
> 
> Here's a concrete example of what I'm talking about.
> 
> $ git checkout oren/ckpt-v16
> $ make ARCH=i386 i386_defconfig
> [ edit .config, enable CONFIG_CHECKPOINT and disable CONFIG_NET ]
> $ make ARCH=i386 -s vmlinux   # which should succeed
> [ apply your patch ]
> $ make ARCH=i386 -s vmlinux
> kernel/built-in.o: In function `free_nsproxy':
> (.text+0x1daaf): undefined reference to `__put_net'
> make: *** [.tmp_vmlinux1] Error 1

Kconfig is almost as retarded as me. :)  Thanks for the cluebat.

-- Dave
