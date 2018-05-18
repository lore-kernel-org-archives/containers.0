From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Fri, 18 May 2018 13:01:46 -0400
Message-ID: <20180518170146.56u7krqfj7hxu55r@madcap2.tricolour.ca>
References: <1520257393.10396.291.camel@linux.vnet.ibm.com>
	<20180305135008.po6lheqnmkqqo6q4@madcap2.tricolour.ca>
	<1520259854.10396.313.camel@linux.vnet.ibm.com>
	<20180308112104.z67wohdvjqemy7wy@madcap2.tricolour.ca>
	<efb6c164-febe-67bb-43a9-795476c4902f@linux.vnet.ibm.com>
	<20180517213001.62caslkjwv575xgl@madcap2.tricolour.ca>
	<86df5c2c-9db3-21b9-b91b-30a4f53f9504@linux.vnet.ibm.com>
	<20180518154553.dy53m3os7aql3urd@madcap2.tricolour.ca>
	<7fdca0e0-19d5-1f08-8aa2-f295ad3a86de@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7fdca0e0-19d5-1f08-8aa2-f295ad3a86de-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-integrity <linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2018-05-18 12:49, Stefan Berger wrote:
> On 05/18/2018 11:45 AM, Richard Guy Briggs wrote:
> > On 2018-05-18 07:49, Stefan Berger wrote:
> > > On 05/17/2018 05:30 PM, Richard Guy Briggs wrote:
> > > > On 2018-05-17 10:18, Stefan Berger wrote:
> > > > > On 03/08/2018 06:21 AM, Richard Guy Briggs wrote:
> > > > > > On 2018-03-05 09:24, Mimi Zohar wrote:
> > > > > > > On Mon, 2018-03-05 at 08:50 -0500, Richard Guy Briggs wrote:
> > > > > > > > On 2018-03-05 08:43, Mimi Zohar wrote:
> > > > > > > > > Hi Richard,
> > > > > > > > > =

> > > > > > > > > This patch has been compiled, but not runtime tested.
> > > > > > > > Ok, great, thank you.  I assume you are offering this patch=
 to be
> > > > > > > > included in this patchset?
> > > > > > > Yes, thank you.
> > > > > > > =

> > > > > > > > I'll have a look to see where it fits in the
> > > > > > > > IMA record.  It might be better if it were an AUDIT_CONTAIN=
ER_INFO
> > > > > > > > auxiliary record, but I'll have a look at the circumstances=
 of the
> > > > > > > > event.
> > > > > > I had a look at the context of this record to see if adding the=
 contid
> > > > > > field to it made sense.  I think the only records for which the=
 contid
> > > > > > field makes sense are the two newly proposed records, AUDIT_CON=
TAINER
> > > > > > which introduces the container ID and the and AUDIT_CONTAINER_I=
NFO which
> > > > > > documents the presence of the container ID in a process event (=
or
> > > > > > process-less network event).  All others should use the auxilia=
ry record
> > > > > > AUDIT_CONTAINER_INFO rather than include the contid field direc=
tly
> > > > > > itself.  There are several reasons for this including record le=
ngth, the
> > > > > > ability to filter unwanted records, the difficulty of changing =
the order
> > > > > > of or removing fields in the future.
> > > > > > =

> > > > > > Syscalls get this information automatically if the container ID=
 is set
> > > > > > for a task via the AUDIT_CONTAINER_INFO auxiliary record.  Gene=
rally a
> > > > > > syscall event is one that uses the task's audit_context while a
> > > > > > standalone event uses NULL or builds a local audit_context that=
 is
> > > > > > discarded immediately after the local use.
> > > > > > =

> > > > > > Looking at the two cases of AUDIT_INTEGRITY_RULE record generat=
ion, it
> > > > > > appears that they should be split into two distinct audit recor=
d types.
> > > > > > =

> > > > > > The record created in ima_audit_measurement() is a syscall reco=
rd that
> > > > > > could possibly stand on its own since the subject attributes are
> > > > > > present.  If it remains a syscall auxiliary record it will auto=
matically
> > > > > > have the AUDIT_CONTAINER_INFO record accompany it anyways.  If =
it is
> > > > > > decided to detach it (which would save cpu/netlink/disk bandwid=
th but is
> > > > > > not recommended due to not wanting to throw away any other sysc=
all
> > > > > > information or other involved records (PATH, CWD, etc...) then =
a local
> > > > > > audit_context would be created for the AUDIT_INTEGRITY_RULE and
> > > > > > AUDIT_CONTAINERID_INFO records only and immediately discarded.
> > > > > What does 'detach it' mean? Does it mean we're not using
> > > > > current->audit_context?
> > > > Exactly.
> > > > =

> > > > > > The record created in ima_parse_rule() is not currently a sysca=
ll record
> > > > > > since it is passed an audit_context of NULL and it has a very d=
ifferent
> > > > > > format that does not include any subject attributes (except sub=
j_*=3D).
> > > > > > At first glance it appears this one should be a syscall accompa=
nied
> > > > > > auxiliary record.  Either way it should have an AUDIT_CONTAINER=
_INFO
> > > > > Do you have an example (pointer) to the format for a 'syscall acc=
ompanied
> > > > > auxiliary record'?
> > > > Any that uses current->audit_context (or recently proposed
> > > > audit_context() function) will be a syscall auxiliary record.  Well
> > > > formed record formats are <fieldname>=3D<value> and named as listed:
> > > > =

> > > > 	https://github.com/linux-audit/audit-documentation/wiki/SPEC-Writi=
ng-Good-Events
> > > > 	https://github.com/linux-audit/audit-documentation/blob/master/spe=
cs/fields/field-dictionary.csv
> > > > 	=

> > > > > > auxiliary record either by being converted to a syscall auxilia=
ry record
> > > > > > by using current->audit_context rather than NULL when calling
> > > > > > audit_log_start(), or creating a local audit_context and calling
> > > > > ima_parse_rule() is invoked when setting a policy by writing it i=
nto
> > > > > /sys/kernel/security/ima/policy. We unfortunately don't have the
> > > > > current->audit_context in this case.
> > > > Sure you do.  What process writes to that file?  That's the one we =
care
> > > > about, unless it is somehow handed off to a queue and processed lat=
er in
> > > > a different context.
> > > I just printk'd it again. current->audit_context is NULL in this case.
> > Oops, that sounds like some of the netfilter empty table
> > initializations, whereas usually rules have a user actor.
> =

> So it's a bug elsewhere not a 'feature?'

Er, it is a challenge we're aware of and have already solved a number of
them.

What happens if you boot with "audit=3D1" on the kernel command line?

> > > > > > audit_log_container_info() then releasing the local context.  T=
his
> > > > > > version of the record has additional concerns covered here:
> > > > > > https://github.com/linux-audit/audit-kernel/issues/52
> > > > > Following the discussion there and the concern with breaking user=
 space, how
> > > > > can we split up the AUDIT_INTEGRITY_RULE that is used in
> > > > > ima_audit_measurement() and ima_parse_rule(), without 'breaking u=
ser space'?
> > > > Arguably userspace is already broken by this wildly diverging pair =
of
> > > > formats for the same record.
> > > > =

> > > > > A message produced by ima_parse_rule() looks like this here:
> > > > > =

> > > > > type=3DINTEGRITY_RULE msg=3Daudit(1526566213.870:305): action=3D"=
dont_measure"
> > > > > fsmagic=3D"0x9fa0" res=3D1
> > > > > =

> > > > > in contrast to that an INTEGRITY_PCR record type:
> > > > > =

> > > > > type=3DINTEGRITY_PCR msg=3Daudit(1526566235.193:334): pid=3D1615 =
uid=3D0 auid=3D0
> > > > > ses=3D2 subj=3Dunconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1=
023
> > > > > op=3D"invalid_pcr" cause=3D"open_writers" comm=3D"scp"
> > > > > name=3D"/var/log/audit/audit.log" dev=3D"dm-0" ino=3D1962625 res=
=3D1
> > > > > =

> > > > > Should some of the fields from INTEGRITY_PCR also appear in INTEG=
RITY_RULE?
> > > > Not necessarily.  There are a number of records in the PCR record t=
hat
> > > > would be redundant when connected to a syscall record, but removing=
 them
> > > > is discouraged to avoid breaking parsers that expect them.
> > > > =

> > > > I don't see any need to touch the PCR record.
> > > I wasn't going to touch the PCR record.
> > > =

> > > =

> > > > > If so, which ones? We could probably refactor the current
> > > > > integrity_audit_message() and have ima_parse_rule() call into it =
to get
> > > > > those fields as well. I suppose adding new fields to it wouldn't =
be
> > > > > considered breaking user space?
> > > > Changing the order of existing fields or inserting fields could bre=
ak
> > > > stuff and is strongly discouraged without a good reason, but append=
ing
> > > > fields is usually the right way to add information.
> > > > =

> > > > There are exceptions, and in this case, I'd pick the "more standard=
" of
> > > > the formats for AUDIT_INTEGRITY_RULE (ima_audit_measurement?) and s=
tick
> > > > with that, abandoning the other format, renaming the less standard
> > > > version of the record (ima_parse_rule?) and perhpas adopting that
> > > > abandonned format for the new record type while using
> > > > current->audit_context.
> > > Since current->audit_context is NULL I built on your patch, but I am =
not
> > > sure whether it is justifyable to use that before your container id s=
eries
> > > is applied.
> > > =

> > > This is what ima_parse_rule() produces now after having it call
> > > audit_log_task_info() as well and by introducing 1806 for ima_parse_r=
ule()
> > > only ( https://lkml.org/lkml/2018/5/11/386 ):
> > > =

> > > type=3DUNKNOWN[1806] msg=3Daudit(1526643702.328:304): action=3D"dont_=
measure"
> > > fsmagic=3D"0x9fa0" res=3D1 ppid=3D1563 pid=3D1595 auid=3D0 uid=3D0 gi=
d=3D0 euid=3D0 suid=3D0
> > > fsuid=3D0 egid=3D0 sgid=3D0 fsgid=3D0 tty=3Dtty2 ses=3D2 comm=3D"cat"=
 exe=3D"/usr/bin/cat"
> > > subj=3Dunconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> > > =

> > > [before: type=3DINTEGRITY_RULE msg=3Daudit(1526566213.870:305):
> > > action=3D"dont_measure" fsmagic=3D"0x9fa0" res=3D1]
> > Since this appears to be a a user action, use current->audit_context
> > to make it a syscall auxiliary record rather than adding all these
> > redundant fields.
> =

> Sure, once we have a non-NULL pointer in current->audit_context I'd do th=
at.
> =

> > =

> > > For comparison the INTEGRITY_RULE:
> > > =

> > > type=3DINTEGRITY_RULE msg=3Daudit(1526642504.074:331): file=3D"/usr/b=
in/ssh" hash=3D"sha256:4abc2558424b9ca61c34af43169d9b9e174d7825bf60c9c76be3=
77549081db5b"
> > > ppid=3D1623 pid=3D1624 auid=3D0 uid=3D0 gid=3D0 euid=3D0 suid=3D0 fsu=
id=3D0 egid=3D0 sgid=3D0
> > > fsgid=3D0 tty=3Dtty2 ses=3D2 comm=3D"scp" exe=3D"/usr/bin/scp"
> > > subj=3Dunconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> > > =

> > > =

> > > 1806 would be in sync with INTEGRITY_RULE now for process related inf=
o. If
> > > this looks good, I'll remove the dependency on your local context cre=
ation
> > > and post the series.
> > What would be the macro name for 1806?
> =

> I currently work with AUDIT_INTEGRITY_POLICY_RULE.
> =

> =

> > =

> > > The justification for the change is that the INTEGRITY_RULE, as produ=
ced by
> > > ima_parse_rule(), is broken.
> > > =

> > >  =A0=A0=A0 Stefan
> > > =

> > > =

> > > > Does this help?
> > > > =

> > > > >   =A0=A0=A0 Stefan
> > > > > =

> > > > > > Can you briefly describe the circumstances under which these two
> > > > > > different identically-numbered records are produced as a first =
step
> > > > > > towards splitting them into two distict records?
> > > > > > =

> > > > > > The four AUDIT_INTEGRITY _METADATA, _PCR, _DATA and _STATUS rec=
ords
> > > > > > appear to be already properly covered for AUDIT_CONTAINER_INFO =
records
> > > > > > by being syscall auxiliary records.  The AUDIT_INTEGRITY_HASH r=
ecord
> > > > > > appears to be unused.
> > > > > > =

> > > > > > > > Can you suggest a procedure to test it?
> > > > > > > Like IMA-measurement and IMA-appraisal, IMA-audit is enabled =
based on
> > > > > > > policy. The example IMA policy, below, includes IMA-audit mes=
sages for
> > > > > > > files executed. 'cat' the policy to /sys/kernel/security/ima/=
policy.
> > > > > > > =

> > > > > > > /etc/ima/ima-policy:
> > > > > > > audit func=3DBPRM_CHECK
> > > > > > > =

> > > > > > > There's a FireEye blog titled "Extending Linux Executable Log=
ging With
> > > > > > > The Integrity Measurement Architecture"* that explains how to=
 augment
> > > > > > > their existing system security analytics with file hashes.
> > > > > > > =

> > > > > > > *=A0https://www.fireeye.com/blog/threat-research/2016/11/exte=
nding_linux
> > > > > > > _exec.html
> > > > > > > =

> > > > > > > =

> > > > > > > Mimi
> > > > > > > =

> > > > > > > > > If the containerid is defined, include it in the IMA-audi=
t record.
> > > > > > > > > =

> > > > > > > > > Signed-off-by: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > > > > > > > > ---
> > > > > > > > >     security/integrity/ima/ima_api.c | 3 +++
> > > > > > > > >     1 file changed, 3 insertions(+)
> > > > > > > > > =

> > > > > > > > > diff --git a/security/integrity/ima/ima_api.c b/security/=
integrity/ima/ima_api.c
> > > > > > > > > index 33b4458cdbef..41d29a06f28f 100644
> > > > > > > > > --- a/security/integrity/ima/ima_api.c
> > > > > > > > > +++ b/security/integrity/ima/ima_api.c
> > > > > > > > > @@ -335,6 +335,9 @@ void ima_audit_measurement(struct int=
egrity_iint_cache *iint,
> > > > > > > > >     	audit_log_untrustedstring(ab, algo_hash);
> > > > > > > > >     	audit_log_task_info(ab, current);
> > > > > > > > > +	if (audit_containerid_set(current))
> > > > > > > > > +		audit_log_format(ab, " contid=3D%llu",
> > > > > > > > > +				 audit_get_containerid(current));
> > > > > > > > >     	audit_log_end(ab);
> > > > > > > > >     	iint->flags |=3D IMA_AUDITED;
> > > > > > > > > -- =

> > > > > > > > > 2.7.5
> > > > > > > > > =

> > > > > > > > - RGB
> > > > > > - RGB
> > > > > > =

> > > > > > --
> > > > > > Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > > > > Sr. S/W Engineer, Kernel Security, Base Operating Systems
> > > > > > Remote, Ottawa, Red Hat Canada
> > > > > > IRC: rgb, SunRaycer
> > > > > > Voice: +1.647.777.2635, Internal: (81) 32635
> > > > > > =

> > > > - RGB
> > > > =

> > > > --
> > > > Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > > Sr. S/W Engineer, Kernel Security, Base Operating Systems
> > > > Remote, Ottawa, Red Hat Canada
> > > > IRC: rgb, SunRaycer
> > > > Voice: +1.647.777.2635, Internal: (81) 32635
> > > > =

> > - RGB
> > =

> > --
> > Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > Sr. S/W Engineer, Kernel Security, Base Operating Systems
> > Remote, Ottawa, Red Hat Canada
> > IRC: rgb, SunRaycer
> > Voice: +1.647.777.2635, Internal: (81) 32635
> > =

> =


- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
