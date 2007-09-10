From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [DRAFT] Container mini-summit notes v0.01
Date: Mon, 10 Sep 2007 09:18:34 -0500
Message-ID: <20070910141834.GA5866@sergelap.austin.ibm.com>
References: <46DE9E1C.6010309@fr.ibm.com>
	<20070905135357.GE1403@sergelap.austin.ibm.com>
	<6599ad830709050700y278d653eu371375c2fc107ef@mail.gmail.com>
	<20070905143808.GG1403@sergelap.austin.ibm.com>
	<46DF35DA.1090102@cs.columbia.edu>
	<20070905235828.GA32475@sergelap.austin.ibm.com>
	<46DFBE60.6030404@fr.ibm.com>
	<20070906153243.GA15436@sergelap.austin.ibm.com>
	<m1wsv0x5sv.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1wsv0x5sv.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Masahiko Takahashi <masahiko-3NddpPZAyC0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> >> > then you should have taken CAP_SYS_MKNOD away from the container.
> >> 
> >> no serge, 
> >> 
> >> we want the container to be able to mknod()
> >
> > Someone give me one good reason why this is needed.
> 
> The picture that I see is still fuzzy, so I cannot say exactly what
> for a device namespace needs to take.  The practical issues is that we
> have virtual devices that when we migrate people will want to continue
> using.  ptys are the common case here, but there are loop devices
> and other virtual devices.
> 
> Doing things like changing the major/minor numbers on a device
> we currently have open during migration could be painful.
> 
> For non-virtual devices we can treat it as a device hot plug
> event, because we really cannot continue with the device open.
> For the virtual devices we can do better and so it is quite likely
> that we want to.
> 
> This isn't an important issue until we get to the point of dealing
> with migration however.

Sorry, I was focusing on the virtual server needs.

devpts is it's own fs so I was fully expecting to make it mountable
multiple times so a container can have it's own /dev/pts/0.  So what
other virtual devices would we want to be able to rec-reate for a
migrated application?  (I wonder (a) what gregkh will say about having
a device namespace, and (b) what the sysfs implications will be)

> >> >> Or mounts it from somewhere outside.
> >> > 
> >> > and CAP_SYS_MOUNT
> >> 
> >> and that also.
> >
> > Same here.  Restricting containers to user mounts - which include 
> > a great deal of things including fuse loopback etc - should be fine.
> 
> The last I looked at user mounts they implied nosuid and nodev.
> 
> Which leads to an interesting implication. sys_mknod support in
> a container does not appear to be fundamental, while device namespaces
> so we can keep virtual devices at their same major/minor numbers looks
> fundamental.
> 
> > But again, if everyone but me agrees on this, we can try to focus on
> > this instead of devpts this year.  Cedric, was this mentioned at the
> > kernel summit?  Was there any reaction to this idea?
> 
> We didn't go into much technical detail a kernel summit.  The goal
> was to stick to topic that were of general interest to most of the
> group.  Which was mostly kernel process related.  We did talk about
> our high level objectives and the biggest question was when will the
> container work be done?  No real objections were answered.
> 
> So for technical details we still need to discuss them on the appropriate
> mailing lists.
> 
> > This of course is also something that could be implemented pretty simply
> > as a container subsys defining the security_mknod hook, with the
> > whitelist defined through the task container interface.
> 
> Something to mention.  I keep thinking for the isolation aspects of this
> it may make sense to refactor the code behind the security hooks to
> be a table based implementation like netfilter.  Allowing code from
> multiple parties to be used together instead of the current all or
> nothing paradigm.
> 
> >> > Anyway if people really all agree on a per-container device whitelist,
> >> > I won't object.  Just seems like overkill to me.
> >> >>> Whereas devpts you do need namespaces for.
> >> >>> -serge
> 
> The practical question is what do we need to do to migrate applications
> that are using virtual devices.
> 
> >> let's get back on the mailing list !
> 
> Back.

Excellent.

> Eric

-serge
