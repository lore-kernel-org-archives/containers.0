From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 14/15] Destroy pid namespace on init's death
Date: Thu, 2 Aug 2007 14:13:35 -0500
Message-ID: <20070802191335.GA22634@sergelap.austin.ibm.com>
References: <20070731061917.GB17013@us.ibm.com>
	<20070731090721.GA110@tv-sign.ru>
	<20070801061616.GA5405@us.ibm.com>
	<20070801194811.GA196@tv-sign.ru> <20070802072958.GA729@us.ibm.com>
	<20070802154018.GA93@tv-sign.ru> <20070802172033.GA8011@us.ibm.com>
	<20070802173128.GA2616@tv-sign.ru>
	<20070802183608.GB15332@us.ibm.com>
	<20070802184953.GA316@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070802184953.GA316-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oleg Nesterov (oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org):
> On 08/02, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> >
> > Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
> > | 
> > | This means that we should take care about multi-thread init exit,
> > | otherwise the non-root user can crash the kernel.
> > | 
> > | >From reply to Kirill's message:
> > | 
> > | 	> Still. A non-root user does clone(CLONE_PIDNS), then clone(CLONE_THREAD),
> > 
> > Agree we should fix the crash. But we need CAP_SYS_ADMIN to clone
> > pid or other namespaces - this is enforced in copy_namespaces() and
> > unshare_nsproxy_namespaces()
> 
> Hmm. sys_unshare(CLONE_PIDNS) doesn't (and shouldn't) work anyway, but
> I don't see the CAP_SYS_ADMIN check in copy_process()->copy_namespaces()
> path.
> 
> Perhaps I just missed it (sorry, I already cleared my mbox, so I can't
> look at theses patches), but is it a good idea to require CAP_SYS_ADMIN?
> I think it would be nice if a normal user can create containers, no?

For pid namespaces I can't think of any reason why CAP_SYS_ADMIN should
be needed, since you can't hide processes that way.  Same for uts
namespaces.

However for ipc and mount namespaces I'd want to think about it some
more.  Any case I can think of right now where they'd be unsafe, is
unsafe anyway, so maybe it's fine...

-serge
