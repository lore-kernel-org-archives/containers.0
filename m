From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: design of user namespaces
Date: Mon, 7 Jul 2008 10:24:06 -0500
Message-ID: <20080707152405.GA11250@us.ibm.com>
References: <m1zlpg27bv.fsf@frodo.ebiederm.org>
	<20080620140510.GA21720@us.ibm.com>
	<m1ve04q686.fsf@frodo.ebiederm.org>
	<20080620205508.GA8429@us.ibm.com>
	<m1d4mbg1ab.fsf@frodo.ebiederm.org>
	<20080630211325.GA27738@us.ibm.com>
	<m1od5iqcoq.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1od5iqcoq.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> 
> >> The very important points are that it is a remount of an existing mount
> >> so that we don't have to worry about corrupted filesystem attacks, and
> >> that authentication is performed at mount time.
> >
> > Conceptually that (making corrupted fs attacks a non-issue) is
> > wonderful.  Practically, I may be missing something:  When you say
> > remount, it seems you must either mean a bind mount or a remount.  If
> > remount, then that will want to change superblock flags.  If the
> > child userns(+child mntns) does a real remount, then that will change
> > the flags for the parent ns as well, right?
> >
> > If instead we do a bind mount we don't have that problem, but then the
> > fs can't be the one doing the user namespace work.
> >
> > I'm probably missing something.
> 
> Essentially I am creating a new mount operation that is a
> cousin of a remount.
> 
> Unlike a real remount you can't change the super flags.
> Unlike a bind mount you get the fs involved, and you pass in a string of flags
> that the fs can interpret in a standard way.
> 
> I expect the flags you pass in would be a subset of what is allowed
> in a normal remount. 
> 
> Which is why I was calling it nativemount.  Although usernsmount
> may be better.
> 
> Eric

Ah, ok.

Now you haven't started any sort of coding for this yet, right?  I'm
hoping to get some time later this week to think about/play with this.

-serge
