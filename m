From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Containers HOWTO?  (Where do I start?)
Date: Wed, 8 Dec 2010 16:11:43 -0600
Message-ID: <20101208221143.GA7952@hallyn.com>
References: <7E28E74ACE78074AAD1BDD3E455CF87493D3@US-EXCH1.sw.swsoft.com>
	<20101208150239.GC8316@hallyn.com>
	<7E28E74ACE78074AAD1BDD3E455CF874942D@US-EXCH1.sw.swsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7E28E74ACE78074AAD1BDD3E455CF874942D-w6YtkvcGFufufkSEj+1U85Z3qXmFLfmx@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Rob Landley (rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> But how does pivot_root enter into this when you haven't got an initrd to
> free?  I thought when you killed a container's init process that killed all

But pivot_root isn't just for initrd.  At this point I think both
libvirt-lxc and lxc.sf.net use pivot_root in favor of chroot for
creating containers.  Of course there are some stringent rules about the
pre-existing old (put) and new roots regarding sharing - you can best
see those in fs/namespace.c:pivot_root, i don't know that they're well
documented anywhere.

> the children and freed the resources, so how does pivot_root enter
> into this?  (You don't reparent existing processes, you span new ones,
> right?)

Right.  And you do the pivot_root only for the container, not the
whole system.  Sorry, I'm missing something about what you're saying
about killing the container.

-serge
