From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] userns: Add a more complete capability subset test
	to commit_creds
Date: Sat, 15 Dec 2012 00:47:35 +0000
Message-ID: <20121215004735.GA14295@mail.hallyn.com>
References: <87txroxpgq.fsf@xmission.com> <87bodwxpcg.fsf@xmission.com>
	<20121215000338.GC13659@mail.hallyn.com>
	<87r4msrx6t.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87r4msrx6t.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> 
> >> When unsharing a user namespace we reduce our credentials to just what
> >> can be done in that user namespace.  This is a subset of the credentials
> >> we previously had.  Teach commit_creds to recognize this is a subset
> >> of the credentials we have had before and don't clear the dumpability flag.
> >> 
> >> This allows an unprivileged  program to do:
> >> unshare(CLONE_NEWUSER);
> >> fd = open("/proc/self/uid_map", O_RDWR);
> >> 
> >> Where previously opening the uid_map writable would fail because
> >> the the task had been made non-dumpable.
> >> 
> >> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >
> > Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >
> >> ---
> >>  kernel/cred.c |   26 +++++++++++++++++++++++++-
> >>  1 files changed, 25 insertions(+), 1 deletions(-)
> >> 
> >> diff --git a/kernel/cred.c b/kernel/cred.c
> >> index 48cea3d..993a7ea41 100644
> >> --- a/kernel/cred.c
> >> +++ b/kernel/cred.c
> >> @@ -455,6 +455,30 @@ error_put:
> >>  	return ret;
> >>  }
> >>  
> >
> > Do you think we need to warn that this can only be used for
> > commit_creds?  (i.e. if someone tried ot use this in some
> > other context, the 'creds are subset of target ns is a child
> > of current_ns' assumption would be wrong)
> 
> This function should be a general test valid at any time.
> 
> Except that I forgot the bit of the test that asks is the original cred
> the owner of the subset user namespace.

Ok, with that change that'll be fine :)

> I will respin this patch.

Cool, thanks.
