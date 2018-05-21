From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Mon, 21 May 2018 13:21:08 -0400
Message-ID: <5705556.pzqfGOkdjC__34093.3636682623$1526923162$gmane$org@x2>
References: <1520257393.10396.291.camel@linux.vnet.ibm.com>
	<20180518155659.porewd6moctumkys@madcap2.tricolour.ca>
	<1526661264.3404.55.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-integrity <linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Friday, May 18, 2018 12:34:24 PM EDT Mimi Zohar wrote:
> On Fri, 2018-05-18 at 11:56 -0400, Richard Guy Briggs wrote:
> > On 2018-05-18 10:39, Mimi Zohar wrote:
> > > On Fri, 2018-05-18 at 09:54 -0400, Stefan Berger wrote:
> > > > On 05/18/2018 08:53 AM, Mimi Zohar wrote:
> > > [..]
> > > 
> > > > >>>> If so, which ones? We could probably refactor the current
> > > > >>>> integrity_audit_message() and have ima_parse_rule() call into it
> > > > >>>> to get
> > > > >>>> those fields as well. I suppose adding new fields to it wouldn't
> > > > >>>> be
> > > > >>>> considered breaking user space?
> > > > >>> 
> > > > >>> Changing the order of existing fields or inserting fields could
> > > > >>> break
> > > > >>> stuff and is strongly discouraged without a good reason, but
> > > > >>> appending
> > > > >>> fields is usually the right way to add information.
> > > > >>> 
> > > > >>> There are exceptions, and in this case, I'd pick the "more
> > > > >>> standard" of
> > > > >>> the formats for AUDIT_INTEGRITY_RULE (ima_audit_measurement?) and
> > > > >>> stick
> > > > >>> with that, abandoning the other format, renaming the less
> > > > >>> standard
> > > > >>> version of the record (ima_parse_rule?) and perhpas adopting that
> > > > >>> abandonned format for the new record type while using
> > > > >>> current->audit_context.
> > > > > 
> > > > > This sounds right, other than "type=INTEGRITY_RULE" (1805) for
> > > > > ima_audit_measurement().  Could we rename type=1805 to be
> > > > 
> > > > So do we want to change both? I thought that what
> > > > ima_audit_measurement() produces looks ok but may not have a good
> > > > name
> > > > for the 'type'. Now in this case I would not want to 'break user
> > > > space'.
> > > > The only change I was going to make was to what ima_parse_rule()
> > > > produces.
> > > 
> > > The only change for now is separating the IMA policy rules from the
> > > IMA-audit messages.
> > > 
> > > Richard, when the containerid is appended to the IMA-audit messages,
> > > would we make the audit type name change then?
> > 
> > No, go ahead and make the change now.  I'm expecting that the
> > containerid record will just be another auxiliary record and should not
> > affect you folks.
> 
> To summarize, we need to disambiguate the 1805, as both
> ima_parse_rule() and ima_audit_measurement() are using the same number
> with different formats.  The main usage of 1805 that we are aware of
> is ima_audit_measurement().  Yet the "type=" name for
> ima_audit_measurement() should be INTEGRITY_IMA_AUDIT, not
> INTEGRITY_RULE.
> 
> option 1: breaks both uses
> 1805 - INTEGRITY_IMA_AUDIT - ima_audit_measurement()
> 1806 - INTEGRITY_POLICY_RULE - ima_parse_rule()
> 
> option 2: breaks the most common usage
> 1805 - INTEGRITY_RULE - ima_parse_rule()
> 1806 - INTEGRITY_IMA_AUDIT - ima_audit_measurement()
> 
> option 3: leaves the most common usage with the wrong name, and breaks
> the other less common usage
> 1805 - INTEGRITY_RULE - ima_audit_measurement()
> 1806 - INTEGRITY_POLICY_RULE - ima_parse_rule()
> 
> So option 3 is the best option?

From a user space perspective, I don't care as long the event is well formed 
(No unnecessary untrusted string logging) and we have the required fields for 
searching: pid, uid, auid, tty, session, subj, comm, exe, & res. And the 
object is identifiable in the event.

-Steve
