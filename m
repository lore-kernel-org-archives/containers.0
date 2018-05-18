From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Fri, 18 May 2018 12:50:28 -0400
Message-ID: <20180518165028.qjcuubxrqmsfg4vb__3044.39651449702$1526662172$gmane$org@madcap2.tricolour.ca>
References: <1520259854.10396.313.camel@linux.vnet.ibm.com>
	<20180308112104.z67wohdvjqemy7wy@madcap2.tricolour.ca>
	<efb6c164-febe-67bb-43a9-795476c4902f@linux.vnet.ibm.com>
	<20180517213001.62caslkjwv575xgl@madcap2.tricolour.ca>
	<86df5c2c-9db3-21b9-b91b-30a4f53f9504@linux.vnet.ibm.com>
	<1526647996.3632.164.camel@linux.vnet.ibm.com>
	<ef567d60-42f7-0a87-8597-1ef381e15be0@linux.vnet.ibm.com>
	<1526654395.3632.196.camel@linux.vnet.ibm.com>
	<20180518155659.porewd6moctumkys@madcap2.tricolour.ca>
	<1526661264.3404.55.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1526661264.3404.55.camel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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

On 2018-05-18 12:34, Mimi Zohar wrote:
> On Fri, 2018-05-18 at 11:56 -0400, Richard Guy Briggs wrote:
> > On 2018-05-18 10:39, Mimi Zohar wrote:
> > > On Fri, 2018-05-18 at 09:54 -0400, Stefan Berger wrote:
> > > > On 05/18/2018 08:53 AM, Mimi Zohar wrote:
> > > =

> > > [..]
> > > =

> > > > >>>> If so, which ones? We could probably refactor the current
> > > > >>>> integrity_audit_message() and have ima_parse_rule() call into =
it to get
> > > > >>>> those fields as well. I suppose adding new fields to it wouldn=
't be
> > > > >>>> considered breaking user space?
> > > > >>> Changing the order of existing fields or inserting fields could=
 break
> > > > >>> stuff and is strongly discouraged without a good reason, but ap=
pending
> > > > >>> fields is usually the right way to add information.
> > > > >>>
> > > > >>> There are exceptions, and in this case, I'd pick the "more stan=
dard" of
> > > > >>> the formats for AUDIT_INTEGRITY_RULE (ima_audit_measurement?) a=
nd stick
> > > > >>> with that, abandoning the other format, renaming the less stand=
ard
> > > > >>> version of the record (ima_parse_rule?) and perhpas adopting th=
at
> > > > >>> abandonned format for the new record type while using
> > > > >>> current->audit_context.
> > > > > This sounds right, other than "type=3DINTEGRITY_RULE" (1805) for
> > > > > ima_audit_measurement(). =A0Could we rename type=3D1805 to be
> > > > =

> > > > So do we want to change both? I thought that what =

> > > > ima_audit_measurement() produces looks ok but may not have a good n=
ame =

> > > > for the 'type'. Now in this case I would not want to 'break user sp=
ace'.
> > > > The only change I was going to make was to what ima_parse_rule() pr=
oduces.
> > > =

> > > The only change for now is separating the IMA policy rules from the
> > > IMA-audit messages.
> > > =

> > > Richard, when the containerid is appended to the IMA-audit messages,
> > > would we make the audit type name change then?
> > =

> > No, go ahead and make the change now.  I'm expecting that the
> > containerid record will just be another auxiliary record and should not
> > affect you folks.
> =

> To summarize, we need to disambiguate the 1805, as both
> ima_parse_rule() and ima_audit_measurement() are using the same number
> with different formats.=A0=A0The main usage of 1805 that we are aware of
> is ima_audit_measurement().=A0=A0Yet the "type=3D" name for
> ima_audit_measurement() should be INTEGRITY_IMA_AUDIT, not
> INTEGRITY_RULE.
> =

> option 1: breaks both uses
> 1805 - INTEGRITY_IMA_AUDIT - ima_audit_measurement()
> 1806 - INTEGRITY_POLICY_RULE - ima_parse_rule()
> =

> option 2: breaks the most common usage
> 1805 - INTEGRITY_RULE - ima_parse_rule()
> 1806 - INTEGRITY_IMA_AUDIT - ima_audit_measurement()
> =

> option 3: leaves the most common usage with the wrong name, and breaks
> the other less common usage
> 1805 - INTEGRITY_RULE - ima_audit_measurement()
> 1806 - INTEGRITY_POLICY_RULE - ima_parse_rule()
> =

> So option 3 is the best option?

Yes, I think so, but option 2 I would be willing to consider.  I'd like
to get Paul and Steve's opinions on this.

> Mimi

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
