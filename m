From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: fix compilation with CONFIG_UTS_NS=n
Date: Thu, 18 Jun 2009 17:32:13 -0500
Message-ID: <20090618223213.GA13179@us.ibm.com>
References: <20090617001723.GA9452@us.ibm.com>
	<4A3A6F61.5030401@cs.columbia.edu> <m3ws79h01p.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m3ws79h01p.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> 
> > I think it's useful to be able to
> >
> > 1) checkpoint on a system with !CONFIG_UTS_NS,  and -
> > 2) checkpoint on a system with CONFIG_UTS_NS and restart on a
> > system with !CONFIG_UTS_NS (as long as all tasks in the image
> > share a single uts-ns)
> 
> In principle I agree, but what confidence can we have that meaningful
> testing of such configurations (especially #2) will occur?

History says, low confidence.  So far just 1 is bad enough.  It's
taking a lot of my time on the LSM c/r (with the various combinations
of CONFIG_SECURITY, CONFIG_IPC_NS, and CONFIG_CHECKPOINT), and things
like CONFIG_IPC_NS consistently break c/r anyway.

So for 2 i'm tempted to say let's encode a sha1sum of the .config
into the checkpoint header.  We'll keep *trying* to support (2), and
userspace can trivially rewrite the header if it really wants to believe
we've succeeded.

And for 1, I agree - most distros ship with namespaces enabled
anyway, and one day I expect we'll get rid of those configs, so
I see no reason to support CONFIG_CHECKPOINT if any namespaces are
turned off.

In fact, I thought that last week Dave suggested that, and Nathan
was against it?  :)

-serge
