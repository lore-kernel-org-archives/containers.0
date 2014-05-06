From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] namespaces: log namespaces per task
Date: Tue, 6 May 2014 17:41:29 -0400
Message-ID: <20140506214129.GC15100@madcap2.tricolour.ca>
References: <cover.1398176489.git.rgb@redhat.com>
	<1399154328.2505.29.camel@dabdike.int.hansenpartnership.com>
	<20140505034814.GA27548@mail.hallyn.com>
	<20140505214818.GC6867@madcap2.tricolour.ca>
	<1399326698.2164.47.camel@dabdike.int.hansenpartnership.com>
	<20140505222758.GA6508@ubuntumail>
	<1399329001.2164.56.camel@dabdike.int.hansenpartnership.com>
	<20140505223638.GB6508@ubuntumail>
	<a09ed85b-d6ef-4472-853b-84057d5957c2@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <a09ed85b-d6ef-4472-853b-84057d5957c2-2ueSQiBKiTY7tOexoI0I+QC/G2K4zDHf@public.gmane.org>
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
> On May 5, 2014 3:36:38 PM PDT, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> >Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> >> On Mon, 2014-05-05 at 22:27 +0000, Serge Hallyn wrote:
> >> > Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> >> > > On Mon, 2014-05-05 at 17:48 -0400, Richard Guy Briggs wrote:
> >> > > > On 14/05/05, Serge E. Hallyn wrote:
> >> > > > > Quoting James Bottomley
> >(James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> >> > > > > > On Tue, 2014-04-22 at 14:12 -0400, Richard Guy Briggs
> >wrote:
> >> > > > > > > Questions:
> >> > > > > > > Is there a way to link serial numbers of namespaces
> >involved in migration of a
> >> > > > > > > container to another kernel?  (I had a brief look at
> >CRIU.)  Is there a unique
> >> > > > > > > identifier for each running instance of a kernel?  Or at
> >least some identifier
> >> > > > > > > within the container migration realm?
> >> > > > > > 
> >> > > > > > Are you asking for a way of distinguishing an migrated
> >container from an
> >> > > > > > unmigrated one?  The answer is pretty much "no" because the
> >job of
> >> > > > > > migration is to restore to the same state as much as
> >possible.
> >> > > > > > 
> >> > > > > > Reading between the lines, I think your goal is to
> >correlate audit
> >> > > > > > information across a container migration, right?  Ideally
> >the management
> >> > > > > > system should be able to cough up an audit trail for a
> >container
> >> > > > > > wherever it's running and however many times it's been
> >migrated?
> >> > > > > > 
> >> > > > > > In that case, I think your idea of a numeric serial number
> >in a dense
> >> > > > > > range is wrong.  Because the range is dense you're
> >obviously never going
> >> > > > > > to be able to use the same serial number across a
> >migration.  However,
> >> > > > > 
> >> > > > > Ah, but I was being silly before, we can actually address
> >this pretty
> >> > > > > simply.  If we just (for instance) add
> >> > > > > /proc/self/ns/{ic,mnt,net,pid,user,uts}_seq containing the
> >serial number
> >> > > > > for the relevant ns for the task, then criu can dump this
> >info at
> >> > > > > checkpoint.  Then at restart it can dump an audit message per
> >task and
> >> > > > > ns saying old_serial=%x,new_serial=%x.  That way the audit
> >log reader
> >> > > > > can if it cares keep track.
> >> > > > 
> >> > > > This is the sort of idea I had in mind...
> >> > > 
> >> > > OK, but I don't understand then why you need a serial number. 
> >There are
> >> > > plenty of things we preserve across a migration, like namespace
> >name for
> >> > > instance.  Could you explain what function it performs because I
> >think I
> >> > > might be missing something.
> >> > 
> >> > We're looking ahead to a time when audit is namespaced, and a
> >container
> >> > can keep its own audit logs (without limiting what the host audits
> >of
> >> > course).  So if a container is auditing suspicious activity by some
> >> > task in a sub-namesapce, then the whole parent container gets
> >migrated,
> >> > after migration we want to continue being able to correlate the
> >namespaces.
> >> > 
> >> > We're also looking at audit trails on a host that is up for years. 
> >We
> >> > would like every namespace to be uniquely logged there.  That is
> >why
> >> > inode #s on /proc/self/ns/* are not sufficient, unless we add a
> >generation
> >> > # (which would end more complicated, not less, than a serial #).
> >> 
> >> Right, but when the contaner has an audit namespace, that namespace
> >has
> >> a name,
> >
> >What ns has a name?
> 
> The netns for instance.
> 
> >  The audit ns can be tied to 50 pid namespaces, and
> >we
> >want to log which pidns is responsible for something.
> >
> >If you mean the pidns has a name, that's the problem...  it does not,
> >it
> >only has a inode # which may later be re-use.
> 
> I still think there's a miscommunication somewhere: I believe you just
> need a stable id to tie the audit to, so why not just give the audit
> namespace a name like net?  The id would then be durable across
> migrations.

Audit does not have its own namespace (yet).  That idea is being
considered, but we would prefer to avoid it if it makes sense to tie it
in with an existing namespace.  The pid and user namespaces, being
heierarchical seem to make the most sense so far, but we are proceeding
very carefully to avoid creating a security nightmare in the process.

From the kernel's perspective, none of the namespaces have a name.  A
container concept of a group of namespaces may have been assigned one,
but that isn't apparent to the layer that is logging this information.

> >> which CRIU would migrate, so why not use that name for the
> >> log .. no need for numbers (unless you make the name a number, of
> >> course)?

There would certainly need to be a way to tie these namespace
identifiers to container names in log messages.

> >> James
> >
> >Sorry if I'm being dense...
> 
> No I think our assumptions are mismatched. I just can't figure out where.
> 
> James

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
