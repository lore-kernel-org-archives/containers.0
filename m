From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Use CAP_SYS_RESOURCE as magic for escaping user
	namespaces.
Date: Wed, 8 May 2013 10:21:07 -0500
Message-ID: <20130508152107.GA3975@austin.hallyn.com>
References: <1367913689-3423-1-git-send-email-Janne.Karhunen@gmail.com>
	<20130507171007.GB10806@austin.hallyn.com>
	<CAE=NcrakiaDPRXJTQz770JNcYw9xbBJcEfCHsap-MGhkT8z2gQ@mail.gmail.com>
	<87fvxy8wk2.fsf@xmission.com>
	<CAE=NcratxHJ1dzDVn3qNxTagcA+CWi4PM+0_sx-9HTBZH_ym_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAE=NcratxHJ1dzDVn3qNxTagcA+CWi4PM+0_sx-9HTBZH_ym_w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Janne Karhunen (janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Tue, May 7, 2013 at 9:38 PM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> 
> > So far it appears that we don't need a device namespace.  As for most
> > things the usual DAC permissions apply.
> 
> Serge, please note ;)

?

Here are some possibilities regarding devices:

1. ptys are already namespaced in their own way
2. loop is not namespaced, but easily could be.  The question is how to
   trigger a new namespace for them.  Maybe a loopfs with newinstance
   option :)
3. c 4 1 (/dev/tty1).  Right now containers handle this purely through
   obfuscation at the filename level, symlinking /dev/tty1 to a pty.
   We could namespace tasks at a tty level, so that c 4 1 either points
   to a provided open fd, or to nothing, in the new namespace.
4. Video cards could be handled by introducing virtual devices to
   replace the physical ones, OR they could be handled by passing the
   physical video card to a different X namespace (X being user, device,
   or something else).  Both have in the past been mentioned by Eric,
   and they're not mutually exclusive.

So, I object to a blanket "this capability changes the meaning of all
your other capabilities with respect to the hardware."  However, perhaps
we could do something like "pass this device to that user namespace, so
that any capabilities he has toward his user namespace will be allowed
against that device."

> > The exceptions that I am aware of where we need something extra are
> > cases where the device abstraction is simply insufficient and needs
> > to be improved.
> >
> > You can pass real network devices between network namespaces.
> 
> Have you considered passing things like frame buffer, input subsystem
> and/or modem(s)?

We have, but I'm not sure we've discussed (though I'm sure we've all
thought about) just passing straight to a user namespace.

-serge
