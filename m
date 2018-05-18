From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Fri, 18 May 2018 11:56:59 -0400
Message-ID: <20180518155659.porewd6moctumkys__24267.7004928284$1526658935$gmane$org@madcap2.tricolour.ca>
References: <1520257393.10396.291.camel@linux.vnet.ibm.com>
	<20180305135008.po6lheqnmkqqo6q4@madcap2.tricolour.ca>
	<1520259854.10396.313.camel@linux.vnet.ibm.com>
	<20180308112104.z67wohdvjqemy7wy@madcap2.tricolour.ca>
	<efb6c164-febe-67bb-43a9-795476c4902f@linux.vnet.ibm.com>
	<20180517213001.62caslkjwv575xgl@madcap2.tricolour.ca>
	<86df5c2c-9db3-21b9-b91b-30a4f53f9504@linux.vnet.ibm.com>
	<1526647996.3632.164.camel@linux.vnet.ibm.com>
	<ef567d60-42f7-0a87-8597-1ef381e15be0@linux.vnet.ibm.com>
	<1526654395.3632.196.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1526654395.3632.196.camel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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

On 2018-05-18 10:39, Mimi Zohar wrote:
> On Fri, 2018-05-18 at 09:54 -0400, Stefan Berger wrote:
> > On 05/18/2018 08:53 AM, Mimi Zohar wrote:
> =

> [..]
> =

> > >>>> If so, which ones? We could probably refactor the current
> > >>>> integrity_audit_message() and have ima_parse_rule() call into it t=
o get
> > >>>> those fields as well. I suppose adding new fields to it wouldn't be
> > >>>> considered breaking user space?
> > >>> Changing the order of existing fields or inserting fields could bre=
ak
> > >>> stuff and is strongly discouraged without a good reason, but append=
ing
> > >>> fields is usually the right way to add information.
> > >>>
> > >>> There are exceptions, and in this case, I'd pick the "more standard=
" of
> > >>> the formats for AUDIT_INTEGRITY_RULE (ima_audit_measurement?) and s=
tick
> > >>> with that, abandoning the other format, renaming the less standard
> > >>> version of the record (ima_parse_rule?) and perhpas adopting that
> > >>> abandonned format for the new record type while using
> > >>> current->audit_context.
> > > This sounds right, other than "type=3DINTEGRITY_RULE" (1805) for
> > > ima_audit_measurement(). =A0Could we rename type=3D1805 to be
> > =

> > So do we want to change both? I thought that what =

> > ima_audit_measurement() produces looks ok but may not have a good name =

> > for the 'type'. Now in this case I would not want to 'break user space'.
> > The only change I was going to make was to what ima_parse_rule() produc=
es.
> =

> The only change for now is separating the IMA policy rules from the
> IMA-audit messages.
> =

> Richard, when the containerid is appended to the IMA-audit messages,
> would we make the audit type name change then?

No, go ahead and make the change now.  I'm expecting that the
containerid record will just be another auxiliary record and should not
affect you folks.

> > > INTEGRITY_AUDIT or INTEGRITY_IMA_AUDIT? =A0The new type=3D1806 audit
> > > message could be named INTEGRITY_RULE or, if that would be confusing,
> > > INTEGRITY_POLICY_RULE.
> > =

> > For 1806, as we would use it in ima_parse_rule(), we could change that =

> > in your patch to INTEGRITY_POLICY_RULE. IMA_POLICY_RULE may be better =

> > for IMA to produce but that's inconsistent then.
> =

> Ok
> =

> > =

> > >
> > >> 1806 would be in sync with INTEGRITY_RULE now for process related in=
fo.
> > >> If this looks good, I'll remove the dependency on your local context
> > >> creation and post the series.
> > >>
> > >> The justification for the change is that the INTEGRITY_RULE, as prod=
uced
> > >> by ima_parse_rule(), is broken.
> > > Post which series? =A0The IMA namespacing patch set? =A0This change s=
hould
> > > be upstreamed independently of IMA namespacing.
> > =

> > Without Richard's local context patch it may just be one or two patches.
> =

> Richard, if we separate the ima_parse_rules() audit messages, changing
> the audit rule number now, without the call to audit_log_task_info(),
> would adding the call later be breaking userspace?

Userspace is arguably already broken due to two formats and one usage
that isn't an auxiliary record.  All that should be necessary for now is
to use a different record number and pass it current->audit_context
instead of NULL.

> Mimi

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
