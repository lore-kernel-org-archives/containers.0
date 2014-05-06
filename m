From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] namespaces: log namespaces per task
Date: Tue, 6 May 2014 17:59:20 -0400
Message-ID: <20140506215920.GD15100@madcap2.tricolour.ca>
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
Cc: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 14/05/05, James Bottomley wrote:
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
> it may or may not be able to see, right?

I guess if that container hasn't mounted /proc, it couldn't find out.
The same would be true of /proc/self/ns/{ic,mnt,net,pid,user,uts}_seq to
find out its namespace serial numbers, but that doesn't stop that
container from initiating an audit message with the information it
knows, which can be supplemented by information the kernel already knows
about it.

> I'm thinking that the system
> that set up the container gave those files names and usually they're the
> same name for all the namespaces.  The point is that the orchestration
> system (whatever set up the container) will be responsible for the
> migration.  It will be the thing that has a unique handle for the
> container.  The handle is usually ascii representable, either a human
> readable name or some uuid/guid.  It's that handle that we should be
> using to prefix the audit message,

It is now possible to send audit messages while in another non-init
namespace, so from there, it could record that handle and have the
namespace serial numbers from the kernel logged with that message.  This
would be recorded by the host audit daemon, not the container audit
daemon.  The container management system could talk to this host audit
daemon to re-assemble an audit record trail for that container.

> so when you set up an audit
> namespace, it gets supplied with a prefix string corresponding to the
> well known name for the container.  This is the string we'd preserve
> across migration as part of the audit namespace state ... so the audit
> messages all correlate to the container wherever it's migrated to; no
> need to do complex tracking of changes to serial numbers.

That is a further step: having a container have its own audit daemon.

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
> of the migrateable entity?

Yes.

>  My instinct still tells me the orchestration
> system is going to have a unique identifier for each different sub
> container.

So what is a sub container?  A nested container?  We still want to track
component namespaces of each nested container.

> However, I have to point out that a serial number isn't what you want
> either if you really mean bare metal.  We do a lot of deployments where
> the containers run in a hypervisor, there the serial numbers won't be
> unique per box (only per vm) and we'll have to do vm correlation
> separately.  whereas a scheme which allows the orchestration system to
> supply the names would still be unique in that situation.

Unique per _running kernel_ was my intention.  I don't care if it is
bare metal or not.

> James

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
