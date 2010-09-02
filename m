From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: 2.6.35: unshare(NEWNS) does not work inside a container anymore?
Date: Thu, 02 Sep 2010 13:20:45 +0400
Message-ID: <4C7F6C6D.5060107@msgid.tls.msk.ru>
References: <4C7CE137.5090009@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C7CE137.5090009-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

31.08.2010 15:02, Michael Tokarev wrote:
> I just noticed a regression - immediately after updating
> kernel from 2.6.32 to 2.6.35 (I skipped .33 and .34).
> Namely, unshare(CLONE_NEWNS) stopped workin from within
> a container, like this:
> 
> unshare(CLONE_NEWNS)              = -1 EINVAL (Invalid argument)
> 
> There's no other fancy stuff going on around, just plain
> unshare and exec a new shell.
> 
> What's wrong with 2.6.35 in this context?

So, after discussing this on IRC and doing some discovery,
it turned out to be new (in 2.6.35) cgroup subsystem --
block I/O controller (CONFIG_BLK_CGROUP).  This one does
not allow more than 1 level of nesting, so, for example,
it is impossible to create a subdirectory in another
cgroup dir in cgroupfs:

 mkdir /dev/cgroup/foo  -- this one succeeds, but
 mkdir /dev/cgroup/foo/bar -- this fails as long
as blkio mount option is enabled.  Once disabled, it
works again.

In 2.6.35 block/blk-cgroup.c, blkiocg_create() there's the
following code:

  /* Currently we do not support hierarchy deeper than two level (0,1) */
  if (parent != cgroup->top_cgroup)
          return ERR_PTR(-EINVAL);

In 2.6.36-tobe it were changed to

          return ERR_PTR(-EPERM);

but the issue remains anyway.  What is problematic here
is that blkio is different from all other cgroups in
this very respect (not allowing nesting), but there's
no indication of this fact anywhere.  At least, the
above quoted place warranrs a WARN() or WARN_ONCE()
to tell the user what's going on - or else it's very
difficult to debug.

Speaking of real solution, it looks like disallowing
nesting should be done in a different way.  Maybe
allow creation of a subcontainer but reset the limits
in there and catch attempts to set them, - I dunno.
Or, don't clone whole cgroup hierarchy on CLONE_NEWNS
only.

Current situation is too restrictive IMHO - blkio
controller is useful for a container like LXC, but
currently it implies that one can't create even a
new filesystem namespace within it.

Thanks.

/mjt
