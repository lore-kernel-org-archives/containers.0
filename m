From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 1/5] ima: extend clone() with IMA namespace support
Date: Tue, 25 Jul 2017 16:08:01 -0500
Message-ID: <20170725210801.GA5628__40323.626335203$1501016883$gmane$org@mail.hallyn.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-2-mkayaalp@linux.vnet.ibm.com>
	<20170725175317.GA727@mail.hallyn.com>
	<1501008554.3689.30.camel@HansenPartnership.com>
	<20170725190406.GA1883@mail.hallyn.com>
	<1501009739.3689.33.camel@HansenPartnership.com>
	<1501012082.27413.17.camel@linux.vnet.ibm.com>
	<645db815-7773-e351-5db7-89f38cd88c3d@linux.vnet.ibm.com>
	<20170725204622.GA4969@mail.hallyn.com>
	<1501016277.27413.50.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1501016277.27413.50.camel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 25, 2017 at 04:57:57PM -0400, Mimi Zohar wrote:
> On Tue, 2017-07-25 at 15:46 -0500, Serge E. Hallyn wrote:
> > On Tue, Jul 25, 2017 at 04:11:29PM -0400, Stefan Berger wrote:
> > > On 07/25/2017 03:48 PM, Mimi Zohar wrote:
> > > >On Tue, 2017-07-25 at 12:08 -0700, James Bottomley wrote:
> > > >>On Tue, 2017-07-25 at 14:04 -0500, Serge E. Hallyn wrote:
> > > >>>On Tue, Jul 25, 2017 at 11:49:14AM -0700, James Bottomley wrote:
> > > >>>>On Tue, 2017-07-25 at 12:53 -0500, Serge E. Hallyn wrote:
> > > >>>>>On Thu, Jul 20, 2017 at 06:50:29PM -0400, Mehmet Kayaalp wrote:
> > > >>>>>>
> > > >>>>>>From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > >>>>>>
> > > >>>>>>Add new CONFIG_IMA_NS config option.  Let clone() create a new
> > > >>>>>>IMA namespace upon CLONE_NEWNS flag. Add ima_ns data structure
> > > >>>>>>in nsproxy. ima_ns is allocated and freed upon IMA namespace
> > > >>>>>>creation and exit. Currently, the ima_ns contains no useful IMA
> > > >>>>>>data but only a dummy interface. This patch creates the
> > > >>>>>>framework for namespacing the different aspects of IMA (eg.
> > > >>>>>>IMA-audit, IMA-measurement, IMA-appraisal).
> > > >>>>>>
> > > >>>>>>Signed-off-by: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > >>>>>>
> > > >>>>>>Changelog:
> > > >>>>>>* Use CLONE_NEWNS instead of a new CLONE_NEWIMA flag
> > > >>>>>Hi,
> > > >>>>>
> > > >>>>>So this means that every mount namespace clone will clone a new
> > > >>>>>IMA namespace.  Is that really ok?
> > > >>>>Based on what: space concerns (struct ima_ns is reasonably small)?
> > > >>>>or whether tying it to the mount namespace is the correct thing to
> > > >>>>do.  On
> > > >>>Mostly the latter.  The other would be not so much space concerns =
as
> > > >>>time concerns.  Many things use new mounts namespaces, and we
> > > >>>wouldn't want multiple IMA calls on all file accesses by all of
> > > >>>those.
> > > >>>
> > > >>>>the latter, it does seem that this should be a property of either
> > > >>>>the mount or user ns rather than its own separate ns.  I could see
> > > >>>>a use where even a container might want multiple ima keyrings
> > > >>>>within the container (say containerised apache service with
> > > >>>>multiple tenants), so instinct tells me that mount ns is the
> > > >>>>correct granularity for this.
> > > >>>I wonder whether we could use echo 1 > /sys/kernel/security/ima/ne=
wns
> > > >>>as the trigger for requesting a new ima ns on the next
> > > >>>clone(CLONE_NEWNS).
> > > >>I could go with that, but what about the trigger being installing or
> > > >>updating the keyring?  That's the only operation that needs namespa=
ce
> > > >>separation, so on mount ns clone, you get a pointer to the old ima_=
ns
> > > >>until you do something that requires a new key, which then triggers=
 the
> > > >>copy of the namespace and installing it?
> > > >It isn't just the keyrings that need to be namespaced, but the
> > > >measurement list and policy as well.
> > > >
> > > >IMA-measurement, IMA-appraisal and IMA-audit are all policy based.
> > > >
> > > >As soon as the namespace starts, measurements should be added to the
> > > >namespace specific measurement list, not it's parent.
> > =

> > Shouldn't it be both?
> =

> The policy defines which files are measured. =A0The namespace policy
> could be different than it's parent's policy, and the parent's policy
> could be different than the native policy. =A0Basically, file
> measurements need to be added to the namespace measurement list,
> recursively, up to the native measurement list.

Yes, but if a task t1 is in namespace ns2 which is a child of namespace ns1,
and it accesses a file which ns1's policy says must be measured, then will
ns1's required measurement happen (and be appended to the ns1 measurement
list), whether or not ns2's policy requires it?
