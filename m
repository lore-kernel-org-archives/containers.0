From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] namespaces: log namespaces per task
Date: Tue, 6 May 2014 14:50:42 +0000
Message-ID: <20140506145042.GH6508@ubuntumail>
References: <1399154328.2505.29.camel@dabdike.int.hansenpartnership.com>
	<20140505034814.GA27548@mail.hallyn.com>
	<20140505214818.GC6867@madcap2.tricolour.ca>
	<1399326698.2164.47.camel@dabdike.int.hansenpartnership.com>
	<20140505222758.GA6508@ubuntumail>
	<1399329001.2164.56.camel@dabdike.int.hansenpartnership.com>
	<20140505223638.GB6508@ubuntumail>
	<a09ed85b-d6ef-4472-853b-84057d5957c2@email.android.com>
	<20140506032732.GD6508@ubuntumail>
	<1399352350.2164.91.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1399352350.2164.91.camel-sFMDBYUN5F8GjUHQrlYNx2Wm91YjaHnnhRte9Li2A+AAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> On Tue, 2014-05-06 at 03:27 +0000, Serge Hallyn wrote:
> > Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> > > >> Right, but when the contaner has an audit namespace, that namespace
> > > >has
> > > >> a name,
> > > >
> > > >What ns has a name?
> > > 
> > > The netns for instance.
> > 
> > And what is its name?
> 
> As I think you know ip netns list will show you all of them.  The way

Ah.  Now I see, thanks :)  I never actually use that feature (other
than when debugging how mounts propagation affects how that's implemented)
which is why it completely did not occur to me that this might be what you
meant.

However these names are (a) not in the kernel, (b) not unique per-boot,
and (c) not applicable to other namespaces (without more userspace
tweaking).  So these are not a substitute for what Richard is proposing.

> they're applied is via mapped files in /var/run/netns/ which hold the
> names.
> 
> >   The only name I know that we could log in an
> > audit message is the /proc/self/ns/net inode number (which does not
> > suffice)
> 
> OK, so I think this is the confusion: You're thinking the container
> itself doesn't know what name the namespace has been given by the
> system, all it knows is the inode number corresponding to a file which
> it may or may not be able to see, right?  I'm thinking that the system
> that set up the container gave those files names and usually they're the
> same name for all the namespaces.  The point is that the orchestration
> system (whatever set up the container) will be responsible for the
> migration.  It will be the thing that has a unique handle for the
> container.

(Several things to reply to there but I'll pick just one,)

We are not looking for a unique name for a container, that's far too
coarse.  Within that container there may be many daemons which have
unshared their own namespaces, i.e. cgmanager unshared a mntns,
vsftpd unshared a netns, etc.  We want the namespace identified in
the audit messages.  We want, within an audit record for a system
boot, for each namespace to be *uniquely* identified.  I don't know
how many people are still doing capp/lspp type installs, but that's
the level I'm thinking at for this.  It's not syslog, it's audit.

> The handle is usually ascii representable, either a human
> readable name or some uuid/guid.  It's that handle that we should be
> using to prefix the audit message, so when you set up an audit
> namespace, it gets supplied with a prefix string corresponding to the
> well known name for the container.  This is the string we'd preserve
> across migration as part of the audit namespace state ... so the audit
> messages all correlate to the container wherever it's migrated to; no
> need to do complex tracking of changes to serial numbers.
> 
> > > >  The audit ns can be tied to 50 pid namespaces, and
> > > >we
> > > >want to log which pidns is responsible for something.
> > > >
> > > >If you mean the pidns has a name, that's the problem...  it does not,
> > > >it
> > > >only has a inode # which may later be re-use.
> > > 
> > > I still think there's a miscommunication somewhere: I believe you just need a stable id to tie the audit to, so why not just give the audit namespace a name like net?  The id would then be durable across migrations.
> > 
> > Maybe this is where we're confusing each other - I'm not talking
> > about giving the audit ns a name.  I'm talking about being able to
> > identify the other namespaces inside an audit message.  In a way
> > that (a) is unique across bare metals' entire uptime, and (b)
> > can be tracked across migrations.
> 
> OK, so that is different from what I'm thinking.  I'm thinking unique
> name for migrateable entity, you want a unique name for each component
> of the migrateable entity?  My instinct still tells me the orchestration
> system is going to have a unique identifier for each different sub
> container.
> 
> However, I have to point out that a serial number isn't what you want
> either if you really mean bare metal.  We do a lot of deployments where
> the containers run in a hypervisor, there the serial numbers won't be
> unique per box (only per vm) and we'll have to do vm correlation
> separately.  whereas a scheme which allows the orchestration system to
> supply the names would still be unique in that situation.
> 
> James
> 
> 
