From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC Part1 PATCH 00/20 v2] Add namespace support for audit
Date: Tue, 10 Dec 2013 20:36:48 +0000
Message-ID: <20131210203648.GA5835@mail.hallyn.com>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
	<529EE877.7030701@cn.fujitsu.com>
	<20131206221241.GD22445@mail.hallyn.com>
	<52A52599.3070502@cn.fujitsu.com> <20131209182619.GD6849@sergelap>
	<52A6CDE1.8090404@cn.fujitsu.com> <20131210165152.GA6028@sergelap>
	<1386705056.23829.13.camel@flatline.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1386705056.23829.13.camel-OjZBOOqb7SR7cYLChsl7DafLeoKvNuZc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric Paris (eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On Tue, 2013-12-10 at 10:51 -0600, Serge Hallyn wrote:
> > Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> > > On 12/10/2013 02:26 AM, Serge Hallyn wrote:
> > > > Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> > > >> On 12/07/2013 06:12 AM, Serge E. Hallyn wrote:
> > > >>> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> > > >>>> Hi
> > > >>>>
> > > >>>> On 10/24/2013 03:31 PM, Gao feng wrote:
> > > >>>>> Here is the v1 patchset: http://lwn.net/Articles/549546/
> > > >>>>>
> > > >>>>> The main target of this patchset is allowing user in audit
> > > >>>>> namespace to generate the USER_MSG type of audit message,
> > > >>>>> some userspace tools need to generate audit message, or
> > > >>>>> these tools will broken.
> > > >>>>>
> > > >>>>
> > > >>>> I really need this feature, right now,some process such as
> > > >>>> logind are broken in container becase we leak of this feature.
> > > >>>
> > > >>> Your set doesn't address loginuid though right?  How exactly do you
> > > >>> expect to do that?  If user violates MAC policy and audit msg is
> > > >>> sent to init user ns by mac subsys, you need the loginuid from
> > > >>> init_audit_ns.  where will that be stored if you allow updates
> > > >>> of loginuid in auditns?
> > > >>>
> > > >> This patchset doesn't include the loginuid part.
> > > >>
> > > >> the loginuid is stored in task as before.
> > > >> In my opinion, when task creates a new audit namespace, this task's
> > > >> loginuid will be reset to zero, so the children tasks can set their
> > > >> loginuid. Does this change break the MAC?
> > > > 
> > > > I think so, yes.  In an LSPP selinux environment, if the task
> > > > manages to trigger an selinux deny rule which is audited, then
> > > > the loginuid must make sense on the host.  Now presumably it
> > > > will get translated to the mapped host uid, and we can figure
> > > > out the host uid owning it through /etc/subuid.  But that adds
> > > > /etc/subuid as a new part of the TCB without any warning <shrug>
> > > > So in that sense, for LSPP, it breaks it.
> > > > 
> > > 
> > > Looks like my opinion is incorrect.
> > > 
> > > In the audit-next tree, Eric added a new audit feature to allow privileged
> > > user to disable AUDIT_LOGINUID_IMMUTABLE. after AUDIT_LOGINUID_IMMUTABLE
> > > is disabled, the privileged user can reset/set the loginuid of task. I
> > > think this way is safe since only privileged user can do the change.
> > > 
> > > So I will not change the loginuid part.
> > > 
> > > Thanks for your information Serge :)
> > 
> > Unfortunately this makes the patchset much less compelling :)  The
> > problem I was looking into is that a container running in a user
> > namespace cannot (bc he has ns_capable(CAP_AUDIT_*) but not
> > capable(CAP_AUDIT_*)) set loginuids at all.
> > 
> > Which from an LSPP pov is correct;  which is why I was hoping you were
> > going to have the audit namespaces be hierarchical, with a task in a
> > level 2 audit ns having two loginuids - one in his own auditns, and
> > one in the initial one.
> 
> Right now user namespace + audit is just total crud.  We all know
> this...  (I'm not sure pid is must better, but I digress)   All thoughts
> around loginuid in the kernel right this very moment only make sense in
> the initial user namespace and all permission checks are in the initial
> user namespace as well.
> 
> I think I'm a proponent of the hierarchical approach to audit
> namespaces.  An audit namespace would hold a reference to the
> pid/user/whatever namespace it was created in/with.  Each audit
> namespace should have it's own set of filter rules, etc.  Instead of
> just storing 'loginuid' we store 'loginuid+user namespace'.   When the

So long as the kernel stores the kuid_t (which the only sane thing to
do) that is a non-issue.

> kernel creates a record it should translate the loginuid to the
> namespace of the audit namespace and send the record.

Yup, that should go without saying.  Use kuid_t in kernel and translate
at the kernel-user boundary.

> It's a pretty major rewrite, but at least it makes sense.  Things like
> AVC's might show up in multiple audit logs, but in every log they would
> make sense to the admin of that namespace...
> 
> But what the hell do I know...

Exactly how it would all affect selinux.  I'm happy it seems we agree.

> Namespaces scare me...

-serge
