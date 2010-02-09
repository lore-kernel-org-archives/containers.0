From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/9] use ckpt_err for architecture mismatch errors
Date: Mon, 8 Feb 2010 21:59:44 -0600
Message-ID: <20100209035944.GB9284@hallyn.com>
References: <1265680806-13295-1-git-send-email-serue@us.ibm.com>
	<1265680806-13295-6-git-send-email-serue@us.ibm.com>
	<4B70DBF9.30105@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B70DBF9.30105-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  arch/x86/kernel/checkpoint.c |    4 +++-
> >  checkpoint/restart.c         |   18 ++++++++++++++----
> >  2 files changed, 17 insertions(+), 5 deletions(-)
> > 
> 
> [...]
> 
> > diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> > index fcd07fa..9bb17fc 100644
> > --- a/checkpoint/restart.c
> > +++ b/checkpoint/restart.c
> > @@ -569,12 +569,14 @@ static int check_kernel_const(struct ckpt_const *h)
> >  		return -EINVAL;
> >  	if (h->uts_nodename_len != sizeof(uts->nodename))
> >  		return -EINVAL;
> > +#if 0
> >  	if (h->uts_release_len != sizeof(uts->release))
> >  		return -EINVAL;
> >  	if (h->uts_version_len != sizeof(uts->version))
> >  		return -EINVAL;
> >  	if (h->uts_machine_len != sizeof(uts->machine))
> >  		return -EINVAL;
> > +#endif
> 
> What is the purpose of this ?  I thought these sizes do not
> depends on the kernel bit-ness.

Jinkeys - yeah that shouldn't be there.

> >  	if (h->uts_domainname_len != sizeof(uts->domainname))
> >  		return -EINVAL;
> >  	/* rlimit */
> 
> [...]
> 
> Oren.
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
