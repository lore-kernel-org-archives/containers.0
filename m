From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Fri, 18 May 2018 11:51:25 -0400
Message-ID: <20180518155125.ebj33f2xo2p2n4q4__5793.17690940133$1526658620$gmane$org@madcap2.tricolour.ca>
References: <1520257393.10396.291.camel@linux.vnet.ibm.com>
	<20180305135008.po6lheqnmkqqo6q4@madcap2.tricolour.ca>
	<1520259854.10396.313.camel@linux.vnet.ibm.com>
	<20180308112104.z67wohdvjqemy7wy@madcap2.tricolour.ca>
	<efb6c164-febe-67bb-43a9-795476c4902f@linux.vnet.ibm.com>
	<20180517213001.62caslkjwv575xgl@madcap2.tricolour.ca>
	<86df5c2c-9db3-21b9-b91b-30a4f53f9504@linux.vnet.ibm.com>
	<1526647996.3632.164.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1526647996.3632.164.camel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-integrity <linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2018-05-18 08:53, Mimi Zohar wrote:
> On Fri, 2018-05-18 at 07:49 -0400, Stefan Berger wrote:
> > On 05/17/2018 05:30 PM, Richard Guy Briggs wrote:
> =

> [...]
> =

> > >>> auxiliary record either by being converted to a syscall auxiliary r=
ecord
> > >>> by using current->audit_context rather than NULL when calling
> > >>> audit_log_start(), or creating a local audit_context and calling
> > >> ima_parse_rule() is invoked when setting a policy by writing it into
> > >> /sys/kernel/security/ima/policy. We unfortunately don't have the
> > >> current->audit_context in this case.
> > > Sure you do.  What process writes to that file?  That's the one we ca=
re
> > > about, unless it is somehow handed off to a queue and processed later=
 in
> > > a different context.
> > =

> > I just printk'd it again. current->audit_context is NULL in this case.
> =

> The builtin policy rules are loaded at __init. =A0Subsequently a custom
> policy can replace the builtin policy rules by writing to the
> securityfs file. =A0Is the audit_context NULL in both cases?

I wondered the same.

> > >> If so, which ones? We could probably refactor the current
> > >> integrity_audit_message() and have ima_parse_rule() call into it to =
get
> > >> those fields as well. I suppose adding new fields to it wouldn't be
> > >> considered breaking user space?
> > > Changing the order of existing fields or inserting fields could break
> > > stuff and is strongly discouraged without a good reason, but appending
> > > fields is usually the right way to add information.
> > >
> > > There are exceptions, and in this case, I'd pick the "more standard" =
of
> > > the formats for AUDIT_INTEGRITY_RULE (ima_audit_measurement?) and sti=
ck
> > > with that, abandoning the other format, renaming the less standard
> > > version of the record (ima_parse_rule?) and perhpas adopting that
> > > abandonned format for the new record type while using
> > > current->audit_context.
> =

> This sounds right, other than "type=3DINTEGRITY_RULE" (1805) for
> ima_audit_measurement(). =A0Could we rename type=3D1805 to be
> INTEGRITY_AUDIT or INTEGRITY_IMA_AUDIT? =A0The new type=3D1806 audit
> message could be named INTEGRITY_RULE or, if that would be confusing,
> INTEGRITY_POLICY_RULE.

I'm reluctant to change the macro/value.  Just use the existing
AUDIT_INTEGRITY_RULE        1805 as appropriate and create a new
AUDIT_INTEGRITY_AUDIT       1806.

> > 1806 would be in sync with INTEGRITY_RULE now for process related info. =

> > If this looks good, I'll remove the dependency on your local context =

> > creation and post the series.
> > =

> > The justification for the change is that the INTEGRITY_RULE, as produce=
d =

> > by ima_parse_rule(), is broken.
> =

> Post which series? =A0The IMA namespacing patch set? =A0This change should
> be upstreamed independently of IMA namespacing.
> =

> Mimi
> =


- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
