From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Tue, 13 Mar 2018 01:53:34 -0400
Message-ID: <20180313055334.hnxuxifv5rcrgb77__44443.5563906611$1520920587$gmane$org@madcap2.tricolour.ca>
References: <1520257393.10396.291.camel@linux.vnet.ibm.com>
	<20180305135008.po6lheqnmkqqo6q4@madcap2.tricolour.ca>
	<1520259854.10396.313.camel@linux.vnet.ibm.com>
	<20180308112104.z67wohdvjqemy7wy@madcap2.tricolour.ca>
	<1520532165.3605.51.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1520532165.3605.51.camel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Matthew Garrett <mjg59-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Peter Moody <peter-58wZ6BnGSNE@public.gmane.org>, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-integrity <linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2018-03-08 13:02, Mimi Zohar wrote:
> On Thu, 2018-03-08 at 06:21 -0500, Richard Guy Briggs wrote:
> > On 2018-03-05 09:24, Mimi Zohar wrote:
> > > On Mon, 2018-03-05 at 08:50 -0500, Richard Guy Briggs wrote:
> > > > On 2018-03-05 08:43, Mimi Zohar wrote:
> > > > > Hi Richard,
> > > > > =

> > > > > This patch has been compiled, but not runtime tested.
> > > > =

> > > > Ok, great, thank you.  I assume you are offering this patch to be
> > > > included in this patchset?
> > > =

> > > Yes, thank you.
> > > =

> > > > I'll have a look to see where it fits in the
> > > > IMA record.  It might be better if it were an AUDIT_CONTAINER_INFO
> > > > auxiliary record, but I'll have a look at the circumstances of the
> > > > event.  =

> > =

> > I had a look at the context of this record to see if adding the contid
> > field to it made sense.  I think the only records for which the contid
> > field makes sense are the two newly proposed records, AUDIT_CONTAINER
> > which introduces the container ID and the and AUDIT_CONTAINER_INFO which
> > documents the presence of the container ID in a process event (or
> > process-less network event).  All others should use the auxiliary record
> > AUDIT_CONTAINER_INFO rather than include the contid field directly
> > itself.  There are several reasons for this including record length, the
> > ability to filter unwanted records, the difficulty of changing the order
> > of or removing fields in the future.
> > =

> > Syscalls get this information automatically if the container ID is set
> > for a task via the AUDIT_CONTAINER_INFO auxiliary record.  Generally a
> > syscall event is one that uses the task's audit_context while a
> > standalone event uses NULL or builds a local audit_context that is
> > discarded immediately after the local use.
> > =

> > Looking at the two cases of AUDIT_INTEGRITY_RULE record generation, it
> > appears that they should be split into two distinct audit record types.
> > =

> > The record created in ima_audit_measurement() is a syscall record that
> > could possibly stand on its own since the subject attributes are
> > present.  If it remains a syscall auxiliary record it will automatically
> > have the AUDIT_CONTAINER_INFO record accompany it anyways.  If it is
> > decided to detach it (which would save cpu/netlink/disk bandwidth but is
> > not recommended due to not wanting to throw away any other syscall
> > information or other involved records (PATH, CWD, etc...) then a local
> > audit_context would be created for the AUDIT_INTEGRITY_RULE and
> > AUDIT_CONTAINERID_INFO records only and immediately discarded.
> > =

> > The record created in ima_parse_rule() is not currently a syscall record
> > since it is passed an audit_context of NULL and it has a very different
> > format that does not include any subject attributes (except subj_*=3D).
> > At first glance it appears this one should be a syscall accompanied
> > auxiliary record.  Either way it should have an AUDIT_CONTAINER_INFO
> > auxiliary record either by being converted to a syscall auxiliary record
> > by using current->audit_context rather than NULL when calling
> > audit_log_start(), or creating a local audit_context and calling
> > audit_log_container_info() then releasing the local context.  This
> > version of the record has additional concerns covered here:
> > https://github.com/linux-audit/audit-kernel/issues/52
> > =

> > Can you briefly describe the circumstances under which these two
> > different identically-numbered records are produced as a first step
> > towards splitting them into two distict records?
> =

> Agreed, the two uses should really be separated. =A0ima_parse_rule()
> generates audit messages, when the IMA policy is initially loaded,
> replaced, or extended, the policy rules are included in the audit log.
> When IMA is namespaced, there will be a host policy and namespace
> policies. =A0We'll need to be able differentiate between the host policy
> rules and IMA namespaced policy rules, and between IMA namespaced
> policy rules.

I would argue this type of message/record should be converted to an
accompanied syscall record, or have the subject attributes added to the
record so that it is clear what user/process initiated this action.  It
now occurs to me that to save audit communications and disk bandwidth,
one syscall record could accompany all the rule records, but if the list
is long enough it might overwhelm userspace audit event parsing code.
Steve?

Regardless, the ima_parse_rule() record format needs to be fixed to
address the non-standard use of "<" and ">" operators instead of the
standard "=3D" field/value separator.

> The audit messages produced by ima_audit_measurement() were originally
> upstreamed for forensics, and as seen by the FireEye blog are now used
> to augment existing security analytics. =A0These records are probably
> being used independently of any other audit records. =A0A single record
> is generated per file, per system. =A0With IMA namespacing, these
> records need to be generated once per file, per namespace as well. =A0In
> order to differentiate the records between the host and namespace, and
> between namespaces, these records should include the container id.

Ok, so this might be one circumstance where the container id field
could make sense to include it in the primary record, but it will
already be automatically getting an AUDIT_CONTAINER_INFO record by
virtue of being a syscall auxiliary record.  You say "These records are
probably being used independently of any other audit records.", but
unless you are certain these are not used by any other tools, it will
have to remain as a syscall auxiliary record.  This means it will
duplicate the container id info if the container id field is added to
the AUDIT_INTEGRITY_RULE record or cause your tools to need to be able
to parse audit *events* rather than just individual audit *records* to
get the associated container id if the container id field is not added
to the AUDIT_INTEGRITY_RULE.

> To disambiguate between these audit messages and the policy rule
> messages, we could rename these audit messages to AUDIT_INTEGRITY_IMA.

This makes sense to me, but will depend on other users of this record
type.  Since there are already two very different formats for this one
existing record type, changing the record type either doesn't matter if
nothing else has noticed or this is what triggered the examination of
this issue in the first place and should be fixed.

> > The four AUDIT_INTEGRITY _METADATA, _PCR, _DATA and _STATUS records
> > appear to be already properly covered for AUDIT_CONTAINER_INFO records
> > by being syscall auxiliary records.  The AUDIT_INTEGRITY_HASH record
> > appears to be unused.
> =

> Ok
> =

> Mimi

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
